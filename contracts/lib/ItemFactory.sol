// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./Context.sol";
import "./Ownable.sol";
import "./EnumerableSet.sol";
import "../interfaces/IItemFactory.sol";

contract ItemFactory is Ownable, IItemFactory {
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private _supportedBoxTypes; // BoxType
    EnumerableSet.UintSet private _supportedItemTypes; // ItemType

    struct RarityInfo {
        uint256 zeroIndex;
        uint256 rarity;
    }

    // Items for specific type
    struct Items {
        uint256 totalRarity;
        uint256[] itemIds;
        mapping(uint256 => RarityInfo) itemIdToRarity;
        mapping(uint256 => uint256) itemInitialLevel;
        mapping(uint256 => uint256) itemInitialExperience;
    }

    struct Range {
        uint256 start;
        uint256 end;
    }

    mapping(uint256 => Items) private _items;
    mapping(uint256 => EnumerableSet.UintSet) private _artifactIds;
    mapping(uint256 => Range) private _artifactRanges;
    mapping(uint256 => uint256) private _itemTypes;


    constructor() {
        // Mystery Box
        _supportedBoxTypes.add(1); // #1
        _supportedBoxTypes.add(2); // #2

        // ItemType
        _supportedItemTypes.add(1); // ItemType#1, ChatPuppy NFT group#1
        _supportedItemTypes.add(2); // ItemType#2, ChatPuppy NFT group#2, TODO

        /*
            6 types of eyes, artifact#1
            4 types of ear-ornament, artifact#2
            6 types of mouths, artifact#3
            6 types of caps, artifact#4
            6 types of cloths, artifact#5
            6 types of background colors, artifact#6
            6 types of skin colors, artifact#7
        */
        _addTypeArtifact(1, 1, 0, 5);  // ItemType#1，Artifact#1, 0-5
        _addTypeArtifact(1, 2, 6, 10); // ItemType#1, Artifact#2, 6-10
        _addTypeArtifact(1, 3, 11, 16); // ItemType#1, Artifact#3, 11-16
        _addTypeArtifact(1, 4, 17, 22); // ItemType#1, Artifact#4, 17-22
        _addTypeArtifact(1, 5, 23, 28); // ItemType#1, Artifact#5, 23-28
        _addTypeArtifact(1, 6, 29, 34); // ItemType#1, Artifact#6, 29-34
        _addTypeArtifact(1, 7, 35, 40); // ItemType#1, Artifact#7, 35-40
    }

    modifier onlySupportedBoxType(uint256 boxType_) {
        require(
            _supportedBoxTypes.contains(boxType_),
            "ItemFactory: unsupported box type"
        );
        _;
    }

    modifier onlySupportedItemType(uint256 itemType_) {
        require(
            _supportedItemTypes.contains(itemType_),
            "ItemFactory: unsupported item type"
        );
        _;
    }

    function _addTypeArtifact(
        uint256 itemType_,
        uint256 artifactId_,
        uint256 artifactStart_,
        uint256 artifactEnd_
    ) private {
        require(artifactEnd_ >= artifactStart_, "ItemFactory: artifactEnd is smaller than artifactStart");
        require(_artifactIds[itemType_].add(artifactId_), "ItemFactory: _artifactIds contains artifactId_");
        _artifactRanges[artifactId_].start = artifactStart_;
        _artifactRanges[artifactId_].end = artifactEnd_;
    }

    function supportedBoxTypes() external view returns (uint256[] memory) {
        return _supportedBoxTypes.values();
    }

    function supportedItemTypes() external view returns (uint256[] memory) {
        return _supportedItemTypes.values();
    }

    function totalSupply(uint256 boxType_) external view returns (uint256) {
        return _items[boxType_].itemIds.length;
    }

    function artifactsLength(uint256 itemType_) external view returns (uint256) {
        return _artifactIds[itemType_].length();
    }

    function artifactIdAt(uint256 itemType_, uint256 index_) external view returns (uint256) {
        return _artifactIds[itemType_].at(index_);
    }

    function getRandomArtifactValue(uint256 randomness_, uint256 artifactId_) external view returns (uint256) {
        Range memory _artifactRange = _artifactRanges[artifactId_];
        require(_artifactRange.end >= _artifactRange.start, "ItemFactory::getRandomArtifactValue artifact length must be greater than 0");
        return (randomness_ % (_artifactRange.end - _artifactRange.start + 1) + _artifactRange.start);
    }

    function addBoxType(uint256 boxType_) external onlyOwner {
        require(_supportedBoxTypes.add(boxType_), "ItemFactory::addBoxType box type is already supported");
    }

    function addItemType(uint256 itemType_) external onlyOwner {
        require(_supportedItemTypes.add(itemType_), "ItemFactory::addItemType item type is already supported");
    }

    function addTypeArtifact(uint256 itemType_, uint256 artifactId_, uint256 artifactStart_, uint256 artifactEnd_)
        public onlyOwner onlySupportedItemType(itemType_) {
        require(
            artifactEnd_ >= artifactStart_,
            "ItemFactory::addTypeArtifact artifactStart should smaller than artifactEnd"
        );
        _addTypeArtifact(itemType_, artifactId_, artifactStart_, artifactEnd_);
    }

    function getItemRarity(uint256 boxType_, uint256 itemId_) external view returns(uint256) {
        return _items[boxType_].itemIdToRarity[itemId_].rarity;
    }

    function getItemTotalRarity(uint256 boxType_) external view returns(uint256) {
        return _items[boxType_].totalRarity;
    }

    function getItemInitialLevel(uint256 boxType_, uint256 itemId_) external view returns(uint256) {
        return _items[boxType_].itemInitialLevel[itemId_];
    }

    function getItemInitialExperience(uint256 boxType_, uint256 itemId_) external view returns(uint256) {
        return _items[boxType_].itemInitialExperience[itemId_];
    }

    function addItem(
        uint256 boxType_,
        uint256 itemType_,
        uint256 itemId_,
        uint256 rarity_,
        uint256 itemInitialLevel_,
        uint256 itemInitialExperience_
    ) external
        onlyOwner
        onlySupportedBoxType(boxType_)
        onlySupportedItemType(itemType_)
    {
        require(itemId_ > uint256(0), "ItemFactory::addItem itemId_ is 0");
        require(rarity_ > uint256(0), "ItemFactory::addItem rarity_ is 0");

        Items storage _itemsForSpecificType = _items[boxType_];
        require(
            _itemsForSpecificType.itemIdToRarity[itemId_].rarity == uint256(0),
            "ItemFactory: itemId_ is already existed"
        );

        // Add item type mapping
        _itemTypes[itemId_] = itemType_;

        // Update artifacts for current type
        _itemsForSpecificType.itemIds.push(itemId_);

        // Update rarity info for item
        _itemsForSpecificType.itemIdToRarity[itemId_].zeroIndex = _itemsForSpecificType.totalRarity;
        _itemsForSpecificType.itemIdToRarity[itemId_].rarity = rarity_;

        // Update total rarity
        _itemsForSpecificType.totalRarity += rarity_;

        // Update initial level and experience
        _itemsForSpecificType.itemInitialLevel[itemId_] = itemInitialLevel_;
        _itemsForSpecificType.itemInitialExperience[itemId_] = itemInitialExperience_;

        emit ItemAdded(boxType_, itemType_, itemId_, rarity_, itemInitialLevel_, itemInitialExperience_);
    }

    function getRandomItem(uint256 randomness_, uint256 boxType_) public view
        onlySupportedBoxType(boxType_)
        returns (uint256 _itemId, uint256 _itemType) {
        Items storage _itemsForSpecificType = _items[boxType_];
        require(
            _itemsForSpecificType.totalRarity > 0,
            "ItemFactory: add items for this type before using function"
        );

        uint256 _randomNumber = randomness_ % _itemsForSpecificType.totalRarity;

        for (uint256 i = 0; i < _itemsForSpecificType.itemIds.length; i++) {
            RarityInfo storage _rarityInfo = _itemsForSpecificType
                .itemIdToRarity[_itemsForSpecificType.itemIds[i]];

            if (_rarityInfo.zeroIndex <= _randomNumber && _randomNumber < _rarityInfo.zeroIndex + _rarityInfo.rarity) {
                _itemId = _itemsForSpecificType.itemIds[i];
                _itemType = _itemTypes[_itemId];
                break;
            }
        }
    }
}