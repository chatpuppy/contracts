// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface IRandomConsumer {
    function rawFulfillRandomness(uint256 tokenId_, uint256 randomness_)
        external;
}