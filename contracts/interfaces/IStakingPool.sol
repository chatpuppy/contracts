//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IStakingPool {
    event Staked(uint indexed knightId, address indexed account, uint amount, uint lockedMonths);
    event Unstaked(uint indexed knightId, address indexed account, uint amount);
    event Exited(address indexed account, uint totalBalance);
    event Claimed(uint indexed knightId, address indexed account, uint reward);

    struct StakingData {
        uint balance;
        uint APY;
        uint lastUpdatedTime;
        uint lockedTime;
        uint lockedMonths;
        uint reward;
    }

    /**
     * @notice Stake FARA crystals for farming knight EXP & FARA token.
     */
    function stake(uint knightId, uint amount, uint lockedMonths) external;

    /**
     * @notice Unstake FARA crystals from a knight.
     */
    function unstake(uint knightId, uint amount) external;

    /**
     * @notice Harvest all EXP and reward earned from a Knight.
     */
    function claim(uint knightId) external;

    /**
     * @notice Convert all accumulated exp from staking to knight's levels.
     */
    function convertExpToLevels(uint knightId, uint levelUpAmount) external;

    /**
     * @notice Gets EXP and FARA earned by a knight so far.
     */
    function earned(uint knightId, address account) external view returns (uint expEarned, uint tokenEarned);

    /**
     * @notice Gets total FARA staked of a Knight.
     */
    function balanceOf(uint knightId, address account) external view returns (uint);
}