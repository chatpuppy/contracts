//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IRewardDistributor {
    /**
     * @notice Distribute reward earned from Staking Pool
     */
    function distributeReward(address account, uint amount) external;
}