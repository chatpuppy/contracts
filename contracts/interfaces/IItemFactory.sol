// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface IItemFactory {
    // function rarityDecimal() external view returns (uint256);

    function totalSupply(uint256 boxType) external view returns (uint256);

    function addItem(
        uint256 boxType,
        uint256 itemId,
        uint256 rarity,
        uint256 itemInitialLevel,
        uint256 itemInitialExperience
    ) external;

    function getRandomItem(uint256 randomness, uint256 boxType)
        external
        view
        returns (uint256 itemId);

    function getItemInitialLevel(uint256[] memory boxTypes, uint256[] memory itemIds)
        external
        view
        returns (uint256);

    function getItemInitialExperience(uint256[] memory boxTypes, uint256[] memory itemIds)
        external
        view
        returns (uint256);

    event ItemAdded(
        uint256 indexed boxType,
        uint256 indexed itemId,
        uint256 rarity,
        uint256 itemInitialLevel,
        uint256 itemInitialExperience
    );
}
