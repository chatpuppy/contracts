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
    // uint256 private projectId = 0;
    uint256 public boxPrice = 0;

    // Mystery Box type
    EnumerableSet.UintSet private _supportedBoxTypes;

    mapping(uint256 => uint256[]) private _randomWords;// _randomnesses;
    mapping(uint256 => uint256) private _requestIds;
    mapping(uint256 => uint256) private _tokenIds;

    VRFCoordinatorV2Interface public COORDINATOR;
    uint256 public randomFee = 0;
    address public feeAccount;
    bytes32 private _keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    uint32 private _callbackGasLimit = 500000;
    uint16 private _requestConfirmations = 3; // Minimum confirmatons is 3
    uint64 private _subscriptionId;

    uint256[] public boxTypes = [2, 3, 4, 5, 6, 7]; // NFT Trait types

    event UnboxToken(uint256 indexed tokenId, uint256 indexed requestId);
    event TokenFulfilled(uint256 indexed tokenId);

    constructor(
        address nftAddress_,
        address itemFactory_,
        uint256 boxPrice_,
        uint64  subscriptionId_,
        address vrfCoordinator_,
        bytes32 keyHash_,
        uint32  callbackGasLimit_,
        uint16  requestConfirmations_
    )   VRFConsumerBaseV2(vrfCoordinator_)
        ItemFactoryManager(itemFactory_)
    {
        require(boxPrice_ > 0, "ChatPuppyNFTManager: box price can not be zero");
        boxPrice = boxPrice_;

        nftCore = ChatPuppyNFTCore(nftAddress_);

        _supportedBoxTypes.add(1); // Mystery Box Type#1, Dragon
        _supportedBoxTypes.add(2); // Mystery Box Type#2, Weapon

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(CAP_MANAGER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(CONTRACT_UPGRADER, _msgSender());
        _setupRole(NFT_UPGRADER, _msgSender());

        // Initialize VRFRandomGenerator
		COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);

        _subscriptionId = subscriptionId_;
		_keyHash = keyHash_;
		_callbackGasLimit = callbackGasLimit_;
        _requestConfirmations = requestConfirmations_;
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

    function updateKeyHash(bytes32 keyHash_) public onlyRole(CONTRACT_UPGRADER) {
        _keyHash = keyHash_;
    }

    function updateSubscriptionId(uint64 subscriptionId_) public onlyRole(CONTRACT_UPGRADER) {
        _subscriptionId = subscriptionId_;
    }

    function updateCallbackGasLimit(uint32 callbackGasLimit_) public onlyRole(CONTRACT_UPGRADER) {
        require(callbackGasLimit_ >= 100000, "ChatPuppyNFTManager: Suggest to set 100000 mimimum");
        _callbackGasLimit = callbackGasLimit_;
    }

    function updateRequestConfirmations(uint16 requestConfirmations_) public onlyRole(CONTRACT_UPGRADER) {
        _requestConfirmations = requestConfirmations_;        
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
        _mint(_msgSender());
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
        uint256 _tokenId = _mint(_msgSender());
        unbox(_tokenId);
    }

    /**
     * @dev Mint NFT with boxType
     */
    function mint(address to_) public onlyRole(MINTER_ROLE) {
        _mint(to_);
    }

    /**
     * @dev Batch mint
     */
    function mintBatch(address to_, uint256 amount_) external onlyRole(MINTER_ROLE) {
        require(amount_ > 0, "ChatPuppyNFTManager: amount_ is 0");
        require(nftCore.totalSupply() + amount_ <= nftCore.cap(), "cap exceeded");

        for (uint256 i = 0; i < amount_; i++) {
            _mint(to_);
        }
    }

    function _mint(address to_) private returns(uint256) {
        return nftCore.mint(to_);
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
        require(boxStatus(tokenId_) == 0, "ChatPuppyNFTManager: token is unboxing or unboxed");
        require(boxTypes.length > 0, "ChatPuppyNFTManager: boxTypes is not set");

        _takeRandomFee();

        uint32 numWords_ = uint32(boxTypes.length); // maximum 6 traits

        uint256 requestId_ = COORDINATOR.requestRandomWords(
            _keyHash,
            _subscriptionId,
            _requestConfirmations,
            _callbackGasLimit,
            numWords_
        );
        _requestIds[tokenId_] = requestId_;
        _tokenIds[requestId_] = tokenId_;

        emit UnboxToken(tokenId_, requestId_);
    }

    /**
     * After unbox and requestRandomNumber, this fulfillRandomness callback function will be called automaticly 
     * and update random metadata for NFT
     * 
     * For getting random number by ChainLink VRF, refer to: https://docs.chain.link/docs/intermediates-tutorial/ 
     * 
     * ArtifactValue format:
     * 0~7: boxType#1(trait#1), len=8, 0-255
     * 8~15: boxType#2, len=8, 0-255
     * 16~23: boxType#3, len=8, 0-255
     * 24~31: boxType#4, len=8, 0-255
     * 32~39: boxType#5, len=8, 0-255
     * 40~47: boxType#6, len=8, 0-255
     * 48~63: level, len=16, 0-65535
     * 64~79: experience, len=16, 0-65535
     * 
     * dna format: 
     * dna = bytes32(keccak256(abi.encodePacked(tokenId_, randomness_)));
     * 
     */
    // ###### DEBUG
    function randomWords(uint256 tokenId_) public view returns(uint256, uint256[] memory) {
        return (_requestIds[tokenId_], _randomWords[tokenId_]);
    }

    function fulfillRandomWords(uint256 requestId_, uint256[] memory randomWords_) internal override {
        uint256 tokenId_ = _tokenIds[requestId_];
        (bytes32 _dna, uint256 _artifacts, ) = nftCore.tokenMetaData(tokenId_);
        _dna = bytes32(keccak256(abi.encodePacked(tokenId_, randomWords_[0])));

        uint256[] memory _itemIds = new uint256[](boxTypes.length);
        for(uint256 i = 0; i < boxTypes.length; i++) {
            uint256 _itemId = itemFactory.getRandomItem(
                randomWords_[i],
                boxTypes[i]
            );
            _itemIds[i] = _itemId;
            _artifacts = _addArtifactValue(_artifacts, i * 8, 8, _itemId); // add itemId
        }
        _artifacts = _addArtifactValue(_artifacts, boxTypes.length * 8, 16, itemFactory.getItemInitialLevel(boxTypes, _itemIds)); // add level
        // 这里面有bug, 上面都OK
        _artifacts = _addArtifactValue(_artifacts, boxTypes.length * 8 + 16, 16, itemFactory.getItemInitialExperience(boxTypes, _itemIds)); // add exeperience

        _randomWords[tokenId_] = randomWords_;

        nftCore.updateTokenMetaData(tokenId_, _artifacts, _dna);
        emit TokenFulfilled(tokenId_);
    }

    // Box type and NFT metadata manager
    function addBoxType(uint256 boxType_) external onlyRole(MANAGER_ROLE) {
        bool success = _supportedBoxTypes.add(boxType_);
        require(success, "ChatPuppyNFTManager: box type is already supported");
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

    function updateBoxTypes(uint256[] calldata boxTypes_) external onlyRole(MANAGER_ROLE) {
        boxTypes = boxTypes_;
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