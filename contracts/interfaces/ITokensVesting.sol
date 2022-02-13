// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/**
 * @dev Interface of the TokensVesting contract.
 */
interface ITokensVesting {
    /**
     * @dev Returns the total amount of tokens in vesting plan.
     */
    function total() external view returns (uint256);

    /**
     * @dev Returns the total releasable amount of tokens.
     */
    function releasable() external view returns (uint256);

    /**
     * @dev Returns the total released amount of tokens.
     */
    function released() external view returns (uint256);

    /**
     * @dev Unlocks all releasable amount of tokens.
     *
     * Emits a {TokensReleased} event.
     */
    function releaseAll() external;

    function setPriceRange(uint8 participant, uint256 fromAmount, uint256 price) external;

    function setCrowdFundingParams(
        uint8   participant,
        uint256 genesisTimestamp,
        uint256 tgeAmountRatio,
        uint256 cliff,
        uint256 duration,
        uint256 basis,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 highest,
        uint256 lowest,
        bool    acceptOverCap,
        bool    allowRedeem
    ) external;

    function updatePriceRange(
        uint8 participant,
        uint256 index,
        uint256 fromAmount,
        uint256 price
    ) external;

    function getPriceForAmount(uint8 participant, uint256 amount) external view returns(uint256, uint256);
    function crowdFunding(uint8 participant) external payable;

    function addBeneficiary(
        address beneficiary,
        uint256 genesisTimestamp,
        uint256 totalAmount,
        uint256 tgeAmount,
        uint256 cliff,
        uint256 duration,
        uint8   participant,
        uint256 basis,
        uint256 price
    ) external;
}
