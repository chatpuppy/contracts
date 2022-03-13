// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./Context.sol";
import "./Ownable.sol";
import "./EnumerableSet.sol";
import "../interfaces/IItemFactory.sol";

contract ItemFactory is Ownable, IItemFactory {
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private _supportedBoxTypes; // BoxType

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
    mapping(uint256 => Items) public _items;

    constructor() {
        // Mystery Box
        _supportedBoxTypes.add(1); // #1
        _supportedBoxTypes.add(2); // #2
    }

    modifier onlySupportedBoxType(uint256 boxType_) {
        require(
            _supportedBoxTypes.contains(boxType_),
            "ItemFactory: unsupported box type"
        );
        _;
    }

    function supportedBoxTypes() external view returns (uint256[] memory) {
        return _supportedBoxTypes.values();
    }

    function totalSupply(uint256 boxType_) external view returns (uint256) {
        return _items[boxType_].itemIds.length;
    }

    function addBoxType(uint256 boxType_) external onlyOwner {
        require(_supportedBoxTypes.add(boxType_), "ItemFactory::addBoxType box type is already supported");
    }

    function getItemRarity(uint256 boxType_, uint256 itemId_) external view returns(uint256) {
        return _items[boxType_].itemIdToRarity[itemId_].rarity;
    }

    function getItemTotalRarity(uint256 boxType_) external view returns(uint256) {
        return _items[boxType_].totalRarity;
    }

    function getItemInitialLevel(uint256[] memory boxTypes_, uint256[] memory itemIds_) external view returns(uint256) {
        uint256 totalLevel = 0;
        for(uint256 i = 0; i < itemIds_.length; i++) {
            totalLevel = totalLevel + _items[boxTypes_[i]].itemInitialLevel[itemIds_[i]];
        }
        return totalLevel;
    }

    function getItemInitialExperience(uint256[] memory boxTypes_, uint256[] memory itemIds_) external view returns(uint256) {
        uint256 totalExperience = 0;
        for(uint256 i = 0; i < itemIds_.length; i++) {
            totalExperience = totalExperience + _items[boxTypes_[i]].itemInitialExperience[itemIds_[i]];
        }
        return totalExperience;
    }

    function addItem(
        uint256 boxType_,
        uint256 itemId_,
        uint256 rarity_,
        uint256 itemInitialLevel_,
        uint256 itemInitialExperience_
    ) external
        onlyOwner
        onlySupportedBoxType(boxType_)
    {
        require(itemId_ > uint256(0), "ItemFactory::addItem itemId_ is 0");
        require(rarity_ > uint256(0), "ItemFactory::addItem rarity_ is 0");

        Items storage _itemsForSpecificType = _items[boxType_];
        require(
            _itemsForSpecificType.itemIdToRarity[itemId_].rarity == uint256(0),
            "ItemFactory: itemId_ is already existed"
        );

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

        emit ItemAdded(
            boxType_,
            itemId_,
            rarity_,
            itemInitialLevel_,
            itemInitialExperience_
        );
    }

    function getRandomItem(uint256 randomness_, uint256 boxType_) public view
        onlySupportedBoxType(boxType_)
        returns (uint256 _itemId) {
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
                break;
            }
        }
    }
}