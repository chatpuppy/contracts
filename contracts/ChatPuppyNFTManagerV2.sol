// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/AccessControlEnumerable.sol";
import "./lib/ItemFactoryManager.sol";
import "./ChatPuppyNFTCore.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract ChatPuppyNFTManagerV2 is
    AccessControlEnumerable,
    VRFConsumerBaseV2,
    ItemFactoryManager
{
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant CAP_MANAGER_ROLE = keccak256("CAP_MANAGER_ROLE");
    bytes32 public constant CONTRACT_UPGRADER = keccak256("CONTRACT_UPGRADER");
    bytes32 public constant NFT_UPGRADER = keccak256("NFT_UPGRADER");

    ChatPuppyNFTCore public immutable nftCore;
    uint256 private projectId = 0;
    uint256 public boxPrice = 0;

    // Mystery Box type
    EnumerableSet.UintSet private _supportedBoxTypes;

    mapping(uint256 => uint256[]) private _comboToBoxes;

    uint256 constant MAX_UNBOX_BLOCK_COUNT = 100;
    mapping(uint256 => uint256[]) private _randomWords;// _randomnesses;
    mapping(uint256 => uint256) private _requestIds;
    mapping(uint256 => uint256) private _tokenIds;
    mapping(uint256 => uint256) private _itemNextIds;

    VRFCoordinatorV2Interface public COORDINATOR;
    LinkTokenInterface LINKTOKEN;
    uint256 public randomFee = 0;
    address public feeAccount;
    address private _vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    address private _link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    bytes32 private _keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 private _callbackGasLimit = 700000;
    uint16 private _requestConfirmations = 3; // Minimum confirmatons is 3
    uint64 private _subscriptionId;

    event UnboxToken(uint256 indexed tokenId, uint256 indexed requestId,  uint256 boxType);
    event TokenFulfilled(uint256 indexed tokenId);

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseTokenURI_,
        uint256 initialCap_,
        address itemFactory_,
        // uint256 projectId_,
        uint256 boxPrice_,
        uint64  subscriptionId_,
        address vrfCoordinator_,
        bytes32 keyHash_,
        address link_,
        uint32  callbackGasLimit_
    )   VRFConsumerBaseV2(vrfCoordinator_)
        ItemFactoryManager(itemFactory_)
    {
        require(boxPrice_ > 0, "ChatPuppyNFTManager: box price can not be zero");
        // require(projectId_ > 0, "ChatPuppyNFTManager: projectId must bigger than zero");
        // projectId = projectId_;
        boxPrice = boxPrice_;

        nftCore = new ChatPuppyNFTCore(
            name_,
            symbol_,
            baseTokenURI_,
            initialCap_
        );

        _supportedBoxTypes.add(1); // Mystery Box Type#1, Dragon
        _supportedBoxTypes.add(2); // Mystery Box Type#2, Weapon

        _addComboType(101); // Combo Box Type#101 (combo box's type must > 100)
        _addBoxTypeToCombo(101, 1); // Add box type#1 to comboBox#101
        _addBoxTypeToCombo(101, 2); // Add box type#2 to comboBox#101

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(CAP_MANAGER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(CONTRACT_UPGRADER, _msgSender());
        _setupRole(NFT_UPGRADER, _msgSender());

        // Initialize VRFRandomGenerator
		COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);
        LINKTOKEN = LinkTokenInterface(link_);
        _subscriptionId = subscriptionId_;
		_keyHash = keyHash_;
		_callbackGasLimit = callbackGasLimit_;
    }

    modifier onlySupportedBoxType(uint256 boxType_) {
        require(_supportedBoxTypes.contains(boxType_), "ChatPuppyNFTManager: unsupported box type");
        _;
    }

    modifier onlyTokenOwner(uint256 tokenId_) {
        require(nftCore.ownerOf(tokenId_) == _msgSender(), "ChatPuppyNFTManager: caller is not owner");
        _;
    }

    modifier onlyMysteryBox(uint256 tokenId_) {
        (bytes32 _dna, ,) = nftCore.tokenMetaData(tokenId_);
        require(_dna == 0, "ChatPuppyNFTManager: token is already unboxed");
        _;
    }

    modifier onlyExistedToken(uint256 tokenId_) {
        require(nftCore.exists(tokenId_), "ChatPuppyNFTManager: token does not exists");
        _;
    }

    function _getBitMask(uint256 lsbIndex_, uint256 length_) private pure returns (uint256) {
        return ((1 << length_) - 1) << lsbIndex_;
    }

    function _clearBits(
        uint256 data_,
        uint256 lsbIndex_,
        uint256 length_
    ) private pure returns (uint256) {
        return data_ & (~_getBitMask(lsbIndex_, length_));
    }

    function _getArtifactValue(
        uint256 artifacts_,
        uint256 lsbIndex_,
        uint256 length_
    ) private pure returns (uint256) {
        return (artifacts_ & _getBitMask(lsbIndex_, length_)) >> lsbIndex_;
    }

    function _addArtifactValue(
        uint256 artifacts_,
        uint256 lsbIndex_,
        uint256 length_,
        uint256 artifactValue_
    ) private pure returns (uint256) {
        return
            ((artifactValue_ << lsbIndex_) & _getBitMask(lsbIndex_, length_)) |
            _clearBits(artifacts_, lsbIndex_, length_);
    }

    function _addComboType(uint256 comboType_) private {
        require(comboType_ > 100);
        require(_supportedBoxTypes.add(comboType_));
    }

    function _addBoxTypeToCombo(uint256 comboType_, uint256 boxType_) private {
        require(comboType_ > 100);
        require(_supportedBoxTypes.contains(comboType_) && _supportedBoxTypes.contains(boxType_));
        require(comboType_ != boxType_);
        _comboToBoxes[comboType_].push(boxType_);
    }

    /**
     * @dev Transfer the ownership of NFT
     * @param newContract_ new owner address
     */
    function upgradeContract(address newContract_) external onlyRole(CONTRACT_UPGRADER) {
        nftCore.transferOwnership(newContract_);
    }

    /**
     * @dev Increase the cap of NFT
     */
    function increaseCap(uint256 amount_) external onlyRole(CAP_MANAGER_ROLE) {
        nftCore.increaseCap(amount_);
    }

    /**
     * @dev update NFT BaseURI
     */
    function updateBaseTokenURI(string memory baseTokenURI_) external onlyRole(MANAGER_ROLE) {
        nftCore.updateBaseTokenURI(baseTokenURI_);
    }

    /**
     * @dev update mystery box price
     */
    function updateBoxPrice(uint256 price_) external onlyRole(MANAGER_ROLE) {
        require(price_ > 0, "ChatPuppyNFTManager: box price can not be zero");
        boxPrice = price_;
    }

    /**
     * @dev pause NFT transaction
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        nftCore.pause();
    }

    /**
     * @dev restart NFT transaction
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        nftCore.unpause();
    }

    /**
     * @dev Update Item Factory
     */
    function updateItemFactory(address itemFactory_) public onlyRole(CONTRACT_UPGRADER) {
        require(itemFactory_ != address(0), "ChatPuppyNFTManager: itemFactory_ is the zero address");
        _updateItemFactory(itemFactory_);
    }

    /**
     * @dev Update ChainLink Random VRFCoordinatorV2
     */
    function updateVRFCoordinatorV2(address vrfCoordinator_) public onlyRole(CONTRACT_UPGRADER) {
        require(vrfCoordinator_ != address(0), "ChatPuppyNFTManager: vrfCoordinator_ is the zero address");
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);
    }

    function updateSubscriptionId(uint64 subscriptionId_) public onlyRole(CONTRACT_UPGRADER) {
        _subscriptionId = subscriptionId_;
    }

    function updateCallbackGasLimit(uint32 callbackGasLimit_) public onlyRole(CONTRACT_UPGRADER) {
        require(callbackGasLimit_ >= 100000, "ChatPuppyNFTManager: Suggest to set 100000 mimimum");
        _callbackGasLimit = callbackGasLimit_;
    }

    /**
     * @dev Withdraw ETH/BNB from NFTManager contracts
     */
    function withdraw(address to_, uint256 amount_) public onlyRole(MANAGER_ROLE) {
        require(to_ != address(0), "ChatPuppyNFTManager: withdraw address is the zero address");
        require(amount_ > uint256(0), "ChatPuppyNFTManager: withdraw amount is zero");
        uint256 balance = address(this).balance;
        require(balance >= amount_, "ChatPuppyNFTManager: withdraw amount must smaller than balance");
        (bool sent, ) = to_.call{value: amount_}("");
        require(sent, "ChatPuppyNFTManager: Failed to send Ether");
    }

    /**
     * Buy and mint
     */
    function buyAndMint(uint256 boxType_) public payable onlySupportedBoxType(boxType_) {
        require(msg.value >= boxPrice, "ChatPuppyNFTManager: payment is not enough");
        _mint(_msgSender(), boxType_);
    }

    /**
     * Buy set of mystery box and mint
     */
    function buyAndMintBatch(uint256 boxType_, uint256 amount_) public payable onlySupportedBoxType(boxType_) {
        require(amount_ > 0, "ChatPuppyNFTManager: amount_ is 0");
        require(msg.value >= boxPrice * amount_, "ChatPuppyNFTManager: Batch purchase payment is not enough");
        
        for (uint256 i = 0; i < amount_; i++) {
            buyAndMint(boxType_);
        }
    }

    /**
     * Buy, mint and unbox
     */
    function buyMintAndUnbox(uint256 boxType_) public payable onlySupportedBoxType(boxType_) {
        require(msg.value >= boxPrice, "ChatPuppyNFTManager: payment is not enough");
        uint256 _tokenId = _mint(_msgSender(), boxType_);
        unbox(_tokenId);
    }

    /**
     * @dev Mint NFT with boxType
     */
    function mint(address to_, uint256 boxType_) public onlyRole(MINTER_ROLE) onlySupportedBoxType(boxType_) {
        _mint(to_, boxType_);
    }

    /**
     * @dev Batch mint
     */
    function mintBatch(address to_, uint256 boxType_, uint256 amount_) external onlyRole(MINTER_ROLE) onlySupportedBoxType(boxType_) {
        require(amount_ > 0, "ChatPuppyNFTManager: amount_ is 0");
        require(nftCore.totalSupply() + amount_ <= nftCore.cap(), "cap exceeded");

        for (uint256 i = 0; i < amount_; i++) {
            _mint(to_, boxType_);
        }
    }

    function _mint(address to_, uint256 boxType_) private returns(uint256) {
        uint256 _tokenId = nftCore.mint(to_);
        (, uint256 _artifacts, ) = nftCore.tokenMetaData(_tokenId);

        // Add box type: size 1 byte
        _artifacts = _addArtifactValue(_artifacts, 0, 8, boxType_);

        nftCore.updateTokenMetaData(_tokenId, _artifacts);

        return(_tokenId);
    }

    function boxStatus(uint256 tokenId_) public view returns(uint8) {
        if(_requestIds[tokenId_] > uint256(0) && _randomWords[tokenId_].length == 0) return 2; // unboxing
        else if(_requestIds[tokenId_] > uint256(0) && _randomWords[tokenId_].length > 0) return 1; //unboxed
        else return 0; // can unbox
    }

    /**
     * @dev Unbox mystery box
     * This is a payable function
     */
    function unbox(uint256 tokenId_) public payable 
        onlyExistedToken(tokenId_) 
        onlyTokenOwner(tokenId_) 
        onlyMysteryBox(tokenId_) 
    {
        (, uint256 _artifacts, ) = nftCore.tokenMetaData(tokenId_);
        uint256 _boxType = _getArtifactValue(_artifacts, 0, 8);

        // Check if box is combo
        if (_boxType > 100) {
            uint256[] storage boxTypes = _comboToBoxes[_boxType];
            _boxType = boxTypes[0];
            _artifacts = _addArtifactValue(_artifacts, 0, 8, _boxType);
            nftCore.updateTokenMetaData(tokenId_, _artifacts);
            for (uint256 i = 1; i < boxTypes.length; i++) {
                _mint(_msgSender(), boxTypes[i]);
            }
        } else {
            require(boxStatus(tokenId_) == 0, "ChatPuppyNFTManager: token is unboxing or unboxed");

            _takeRandomFee();

            uint32 numWords_ = 1; // maximum 7 artifacts, plus rarity, need 8 random words

            uint256 requestId_ = COORDINATOR.requestRandomWords(
                _keyHash,
                _subscriptionId,
                _requestConfirmations,
                _callbackGasLimit,
                numWords_
            );
            _requestIds[tokenId_] = requestId_;
            _tokenIds[requestId_] = tokenId_;

            emit UnboxToken(tokenId_, requestId_, _boxType);
        }
    }

    /**
     * After unbox and requestRandomNumber, this fulfillRandomness callback function will be called automaticly 
     * and update random metadata for NFT
     * 
     * For getting random number by ChainLink VRF, refer to: https://docs.chain.link/docs/intermediates-tutorial/ 
     * 
     * ArtifactValue format:
     * 0~7: boxType, len=8, 0-255
     * 8~15: itemType, len=8, 0-255
     * 16~31: itemId, len=16, 0-65535
     * 32~47: Initial level, len=16, 0-65535
     * 48~63: Initial experience, len=16, 0-65535
     * 64~87: picId, len=24, the picture will save as itemId_picId.png, such as `3_12.png` it is the 12th pic in item#3
     * 88~95: artifactId_1, len=8
     * 96~111: artifactValue_1, len=16
     * 112~119: artifactId_2, len=8
     * 120~135: artifactValue_2, len=16
     * ...
     * Max store: (256 - 88) / 24 = 7 artifacts
     * 
     * dna format: 
     * dna = bytes32(keccak256(abi.encodePacked(tokenId_, randomness_)));
     * 
     */
    function randomWords(uint256 tokenId_) public view returns(uint256, uint256[] memory) {
        return (_requestIds[tokenId_], _randomWords[tokenId_]);
    }

    function fulfillRandomWords(uint256 requestId_, uint256[] memory randomWords_) internal override {
        uint256 tokenId_ = _tokenIds[requestId_];
        (bytes32 _dna, uint256 _artifacts, ) = nftCore.tokenMetaData(tokenId_);
        _dna = bytes32(keccak256(abi.encodePacked(tokenId_, randomWords_[0])));

        uint256 _boxType = _getArtifactValue(_artifacts, 0, 8);

        // ###### 这里有问题，打了注释后可以运行，否则错误。
        (uint256 _itemId, uint256 _itemType) = itemFactory.getRandomItem(
            randomWords_[0],
            _boxType
        );

        // _itemNextIds[_itemId] = _itemNextIds[_itemId] + 1;
        // _artifacts = _addArtifactValue(_artifacts, 8, 8, _itemType); // add itemType
        // _artifacts = _addArtifactValue(_artifacts, 16, 16, _itemId); // add itemId
        // _artifacts = _addArtifactValue(_artifacts, 32, 16, itemFactory.getItemInitialLevel(_itemType, _itemId)); // add level
        // _artifacts = _addArtifactValue(_artifacts, 48, 16, itemFactory.getItemInitialExperience(_itemType, _itemId)); // add exeperience
        // _artifacts = _addArtifactValue(_artifacts, 64, 24, _itemNextIds[_itemId]); // add item NextId, this is for pic image id

        // uint256 _artifactsLength = itemFactory.artifactsLength(_itemType);

        // for (uint256 i = 0; i < _artifactsLength; i++) {
        //     // add artifact id
        //     uint256 _artifactId = itemFactory.artifactIdAt(_itemType, i);

        //     _artifacts = _addArtifactValue(
        //         _artifacts,
        //         88 + i * 24,
        //         8,
        //         _artifactId
        //     );

        //     // Randome seed for artifact, it'll be same if in the same block, same item type and same item id
        //     uint256 _randomness = uint256(
        //         keccak256(
        //             abi.encodePacked(
        //                 randomWords_[0],
        //                 block.number,
        //                 _itemType,
        //                 _itemId,
        //                 _artifactId,
        //                 i
        //             )
        //         )
        //     );

        //     // add artifact value
        //     uint256 _artifactValue = itemFactory.getRandomArtifactValue(
        //         _randomness,
        //         _artifactId
        //     );
        //     _artifacts = _addArtifactValue(
        //         _artifacts,
        //         96 + i * 24,
        //         16,
        //         _artifactValue
        //     );
        // }

        _randomWords[tokenId_] = randomWords_;

        nftCore.updateTokenMetaData(tokenId_, _artifacts, _dna);
        emit TokenFulfilled(tokenId_);
    }

    // Box type and NFT metadata manager
    function addBoxType(uint256 boxType_) external onlyRole(MANAGER_ROLE) {
        require(boxType_ > 0 && boxType_ <= 100);
        bool success = _supportedBoxTypes.add(boxType_);
        require(success, "ChatPuppyNFTManager: box type is already supported");
    }

    function addComboType(uint256 comboType_) external onlyRole(MANAGER_ROLE) {
        _addComboType(comboType_);
    }

    function boxTypesIncombo(uint256 comboType_) external view returns (uint256[] memory) {
        return _comboToBoxes[comboType_];
    }

    function addBoxTypeToCombo(uint256 comboType_, uint256 boxType_) external onlyRole(MANAGER_ROLE) {
        _addBoxTypeToCombo(comboType_, boxType_);
    }

    function supportedBoxTypes() external view returns (uint256[] memory) {
        return _supportedBoxTypes.values();
    }

    function upgradeNFT(uint256 tokenId_, uint256 artifacts_) external onlyRole(NFT_UPGRADER) {
        nftCore.updateTokenMetaData(tokenId_, artifacts_);
    }

    function updateRandomFee(uint256 randomFee_) public onlyRole(MANAGER_ROLE) {
        randomFee = randomFee_;
    }

    function updateFeeAccount(address feeAccount_) public onlyRole(MANAGER_ROLE) {
        require(feeAccount_ != address(0), "ChatPuppyNFTManager: feeAccount can not be zero address");
        feeAccount = feeAccount_;
    }

    function _takeRandomFee() internal {
        if (randomFee > 0) {
            require(msg.value >= randomFee, "ChatPuppyNFTManager: insufficient fee");
            require(feeAccount != address(0), "ChatPuppyNFTManager: feeAccount is the zero address");
            (bool success, ) = address(feeAccount).call{value: msg.value}(new bytes(0));
            require(success, "ChatPuppyNFTManager: fee required");
        }
    }

}