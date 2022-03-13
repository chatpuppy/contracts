// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/AccessControlEnumerable.sol";
import "./lib/RandomConsumerBase.sol";
import "./lib/ItemFactoryManager.sol";
import "./ChatPuppyNFTCore.sol";

contract ChatPuppyNFTManager is
    AccessControlEnumerable,
    RandomConsumerBase,
    ItemFactoryManager
{
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant CAP_MANAGER_ROLE = keccak256("CAP_MANAGER_ROLE");
    bytes32 public constant CONTRACT_UPGRADER = keccak256("CONTRACT_UPGRADER");
    bytes32 public constant NFT_UPGRADER = keccak256("NFT_UPGRADER");

    ChatPuppyNFTCore public nftCore;
    uint256 private projectId = 0;
    uint256 public boxPrice = 0;

    // Mystery Box type
    EnumerableSet.UintSet private _supportedBoxTypes;

    mapping(uint256 => uint256[]) private _comboToBoxes;

    uint256 constant MAX_UNBOX_BLOCK_COUNT = 100;
    mapping(uint256 => uint256) private _tokenIdToUnboxBlockNumber;
    mapping(uint256 => uint256) private _randomnesses;
    mapping(uint256 => uint256) private _itemNextIds;

    event UnboxToken(uint256 indexed tokenId, uint256 boxType);
    event TokenFulfilled(uint256 indexed tokenId);

    constructor(
        address nftAddress_,
        address itemFactory_,
        address randomGenerator_,
        uint256 randomFee_,
        uint256 projectId_,
        uint256 boxPrice_
    )
        RandomConsumerBase(randomGenerator_, randomFee_)
        ItemFactoryManager(itemFactory_)
    {
        require(boxPrice_ > 0, "ChatPuppyNFTManager: box price can not be zero");
        require(projectId_ > 0, "ChatPuppyNFTManager: projectId must bigger than zero");
        projectId = projectId_;
        boxPrice = boxPrice_;

        nftCore = ChatPuppyNFTCore(nftAddress_);
        // ATTN. Deploy the NFTCore first, then update NFTCore's owner to deployed NFTManager contract

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
     * @dev update project id, while fetching random data, the input will be `projectId + tokenId`
     * to avoid same tokenId can not be duplicated in ChainlinkRandomGenerator contract
     */
    function updateProjectId(uint256 projectId_) external onlyRole(MANAGER_ROLE) {
        projectId = projectId_;
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
     * @dev Update ChainLink Random Generator
     */
    function updateRandomGenerator(address randomGenerator_) public onlyRole(CONTRACT_UPGRADER) {
        require(randomGenerator_ != address(0), "ChatPuppyNFTManager: randomGenerator_ is the zero address");
        _updateRandomGenerator(randomGenerator_);
    }

    /**
     * @dev Update ChainLink Random fee(LINK)
     */
    function updateRandomFee(uint256 randomFee_) public onlyRole(MANAGER_ROLE) {
        _updateRandomFee(randomFee_);
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

    function boxStatus(uint256 tokenId_) external view returns(uint8) {
        if(_tokenIdToUnboxBlockNumber[tokenId_] > uint256(0) && _tokenIdToUnboxBlockNumber[tokenId_] >= block.number - MAX_UNBOX_BLOCK_COUNT) return 2; // unboxing
        else if(_randomnesses[tokenId_] > uint256(0)) return 1; //unboxed
        else return 0; // can unbox
    }

    /**
     * @dev Unbox mystery box
     * This is a payable function
     */
    function unbox(uint256 tokenId_) public payable onlyExistedToken(tokenId_) onlyTokenOwner(tokenId_) onlyMysteryBox(tokenId_) {
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
            require(
                _tokenIdToUnboxBlockNumber[tokenId_] == uint256(0) || _tokenIdToUnboxBlockNumber[tokenId_] < block.number - MAX_UNBOX_BLOCK_COUNT,
                "NFT: token is unboxing"
            );
            _tokenIdToUnboxBlockNumber[tokenId_] = block.number;

            _takeRandomFee();
            randomGenerator.requestRandomNumber(projectId + tokenId_);
            emit UnboxToken(tokenId_, _boxType);
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
    function fulfillRandomness(uint256 tokenId_, uint256 randomness_) internal override(RandomConsumerBase) {
        tokenId_ = tokenId_ - projectId;
        (bytes32 _dna, uint256 _artifacts, ) = nftCore.tokenMetaData(tokenId_);
        _dna = bytes32(keccak256(abi.encodePacked(tokenId_, randomness_)));

        // uint256 _boxType = _getArtifactValue(_artifacts, 0, 8);
        // (uint256 _itemId) = itemFactory.getRandomItem(
        //     randomness_,
        //     _boxType
        // );

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
        //                 randomness_,
        //                 block.number,
        //                 // _itemType,
        //                 _itemId,
        //                 _artifactId,
        //                 i
        //             )
        //         )
        //     );

        //     add artifact value
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

        // delete _tokenIdToUnboxBlockNumber[tokenId_];
        // _randomnesses[tokenId_] = randomness_;

        // nftCore.updateTokenMetaData(tokenId_, _artifacts, _dna);
        // emit TokenFulfilled(tokenId_);
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
}