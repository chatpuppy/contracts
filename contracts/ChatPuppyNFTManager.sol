// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/AccessControlEnumerable.sol";
import "./lib/RandomConsumerBase.sol";
import "./lib/ItemFactoryManager.sol";
import "./ChatPuppyNFTCore.sol";
import "./lib/Bitmask.sol";

contract ChatPuppyNFTManager is
    AccessControlEnumerable,
    RandomConsumerBase,
    ItemFactoryManager,
    Bitmask
{
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant CAP_MANAGER_ROLE = keccak256("CAP_MANAGER_ROLE");
    bytes32 public constant CONTRACT_UPGRADER = keccak256("CONTRACT_UPGRADER");
    bytes32 public constant NFT_UPGRADER = keccak256("NFT_UPGRADER");

    ChatPuppyNFTCore public nftCore;
    // uint256 private projectId = 0;
    uint256 public boxPrice = 0;
    address public feeAccount;

    // Mystery Box type
    EnumerableSet.UintSet private _supportedBoxTypes;
    mapping(uint256 => uint256[]) private _requestIds;
    // mapping(uint256 => uint256) private _tokenIds;
    mapping(uint256 => uint256[]) private _randomWords;
    uint256[] public boxTypes = [2, 3, 4, 5, 6, 7]; // NFT Trait types

    event UnboxToken(uint256 indexed tokenId, uint256 requestId);
    event TokenFulfilled(uint256 indexed tokenId);

    constructor(
        address nftAddress_,
        address itemFactory_,
        address randomGenerator_,
        uint256 randomFee_,
        // uint256 projectId_,
        uint256 boxPrice_
    )
        RandomConsumerBase(randomGenerator_, randomFee_)
        ItemFactoryManager(itemFactory_)
    {
        require(boxPrice_ > 0, "ChatPuppyNFTManager: box price can not be zero");
        // require(projectId_ > 0, "ChatPuppyNFTManager: projectId must bigger than zero");
        // projectId = projectId_;
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
     */
    function upgradeNFTCoreOwner(address newOwner_) external onlyRole(CONTRACT_UPGRADER) {
        nftCore.transferOwnership(newOwner_);
    }

    /**
     * @dev update nft core contract
     */
    function updateNFTCoreContract(address newAddress_) external onlyRole(CONTRACT_UPGRADER) {
        nftCore = ChatPuppyNFTCore(newAddress_);
    }

    /**
     * @dev Increase the cap of NFT
     */
    function increaseCap(uint256 amount_) external onlyRole(CAP_MANAGER_ROLE) {
        nftCore.increaseCap(amount_);
    }

    /**
     * @dev update project id, while fetching random data, the input will be `projectId + tokenId`
     * to avoid same tokenId can not be duplicated in ChainlinkRandomGenerator contract
     */
    // function updateProjectId(uint256 projectId_) external onlyRole(MANAGER_ROLE) {
    //     projectId = projectId_;
    // }

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
    function buyAndMint() public payable {
        require(msg.value >= boxPrice, "ChatPuppyNFTManager: payment is not enough");
        _mint(_msgSender());
    }

    /**
     * Buy set of mystery box and mint
     */
    function buyAndMintBatch(uint256 amount_) public payable {
        require(amount_ > 0, "ChatPuppyNFTManager: amount_ is 0");
        require(msg.value >= boxPrice * amount_, "ChatPuppyNFTManager: Batch purchase payment is not enough");
        
        for (uint256 i = 0; i < amount_; i++) {
            buyAndMint();
        }
    }

    /**
     * Buy, mint and unbox
     */
    function buyMintAndUnbox() public payable {
        require(msg.value >= boxPrice, "ChatPuppyNFTManager: payment is not enough");
        uint256 _tokenId = _mint(_msgSender());
        unbox(_tokenId, 6, false);
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
        // ######
        // if(_requestIds[tokenId_] > uint256(0) && _randomWords[tokenId_].length == 0) return 2; // unboxing
        // else if(_requestIds[tokenId_] > uint256(0) && _randomWords[tokenId_].length > 0) return 1; //unboxed
        // else return 0; // can unbox
    }

    function places(uint256 num) internal pure returns(uint256){
        uint32 maxPlaces = 50; // tokenId can not be more than 10**51 - 1
        uint256 _places = 0;
        for(uint32 i = 1; i <= maxPlaces; i++) {
            if(num >= 10**(i-1) && num <= 10**i - 1) {
                _places = i;
                break;
            }
        }
        return _places;
    }
    function getRequestId(uint256 index, uint256 tokenId) internal pure returns (uint256 requestId_) {
        requestId_ = uint256(index) * 10**(places(tokenId)) + tokenId;
    }

    function getIndexTokenId(uint256 requestId_) internal pure returns(uint256 index_, uint256 tokenId_) {
        index_ = uint256(requestId_ / 10**(places(requestId_) - 1));
        tokenId_ = requestId_ % 10**(places(requestId_) - 1);
    }

    /**
     * @dev Unbox mystery box
     * This is a payable function
     */
    function unbox(uint256 tokenId_, uint256 count_, bool test_) public payable 
        onlyExistedToken(tokenId_) 
        onlyTokenOwner(tokenId_) 
        onlyMysteryBox(tokenId_) 
    {
        require(boxStatus(tokenId_) == 0, "ChatPuppyNFTManager: token is unboxing or unboxed");
        require(boxTypes.length > 0, "ChatPuppyNFTManager: boxTypes is not set");        
       
        _takeRandomFee();
        
        uint256 numWords_ = boxTypes.length; // maximum 6 traits

        uint256[] memory _request = new uint256[](numWords_);
        
        uint256 i = 1;
        uint256 requestId_ = 0;
        while(i <= count_) {
            requestId_ = getRequestId(i, tokenId_); // The requestId_ can not be multiple
            randomGenerator.requestRandomNumber(requestId_);
            if(test_) _request[i - 1] = requestId_; // 这条语句与requestRandomNumber不能一起用
            emit UnboxToken(tokenId_, requestId_);
            i++;
        }
        _requestIds[tokenId_] = _request;
        _randomWords[tokenId_] = new uint256[](numWords_);

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
    function randomWords(uint256 tokenId_) public view returns(uint256[] memory, uint256[] memory) {
        return (_requestIds[tokenId_], _randomWords[tokenId_]);
    }

    function fulfillRandomness(uint256 requestId_, uint256 randomness_) internal override(RandomConsumerBase) {
        (uint256 index_, uint256 tokenId_) = getIndexTokenId(requestId_);

        // // Check if all 6 randomness is got
        // _randomWords[tokenId_][index_ - 1] = randomness_;

        // uint256 count = 0;
        // for(uint256 i = 0; i < boxTypes.length; i ++) if(_randomWords[tokenId_][i] > 0) count++;
        // if(count < boxTypes.length) return; // Don't do anythin

        // (bytes32 _dna, uint256 _artifacts, ) = nftCore.tokenMetaData(tokenId_);
        // _dna = bytes32(keccak256(abi.encodePacked(tokenId_, _randomWords[tokenId_][0])));

        // uint256[] memory _itemIds = new uint256[](boxTypes.length);
        // for(uint256 i = 0; i < boxTypes.length; i++) {
        //     uint256 _itemId = itemFactory.getRandomItem(
        //         _randomWords[tokenId_][i],
        //         boxTypes[i]
        //     );
        //     _itemIds[i] = _itemId;
        //     _artifacts = _addArtifactValue(_artifacts, i * 8, 8, _itemId); // add itemId
        // }
        // _artifacts = _addArtifactValue(_artifacts, boxTypes.length * 8, 16, itemFactory.getItemInitialLevel(boxTypes, _itemIds)); // add level
        // _artifacts = _addArtifactValue(_artifacts, boxTypes.length * 8 + 16, 16, itemFactory.getItemInitialExperience(boxTypes, _itemIds)); // add exeperience

        // nftCore.updateTokenMetaData(tokenId_, _artifacts, _dna);
        // emit TokenFulfilled(tokenId_);
    }

    function supportedBoxTypes() external view returns (uint256[] memory) {
        return _supportedBoxTypes.values();
    }

    function upgradeNFT(uint256 tokenId_, uint256 artifacts_) external onlyRole(NFT_UPGRADER) {
        nftCore.updateTokenMetaData(tokenId_, artifacts_);
    }

    function updateFeeAccount(address feeAccount_) public onlyRole(MANAGER_ROLE) {
        require(feeAccount_ != address(0), "ChatPuppyNFTManager: feeAccount can not be zero address");
        feeAccount = feeAccount_;
    }

    function updateBoxTypes(uint256[] calldata boxTypes_) external onlyRole(MANAGER_ROLE) {
        boxTypes = boxTypes_;
    }

    function updateTokenURI(uint256 tokenId_, string calldata uri_) external onlyRole(NFT_UPGRADER) {
        nftCore.updateTokenURI(tokenId_, uri_);
    }

}