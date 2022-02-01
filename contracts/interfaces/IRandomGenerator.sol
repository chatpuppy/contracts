// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IRandomGenerator {
    function requestRandomNumber(uint256 tokenId) external;

    function getResultByTokenId(uint256 tokenId) external view returns (uint256);
}