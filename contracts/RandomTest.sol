// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/RandomConsumerBase.sol";
import "./lib/Ownable.sol";
import "./lib/Bitmask.sol";

contract RandomTest is RandomConsumerBase, Ownable, Bitmask {
	uint256 public seed;
	mapping(uint256 => uint256[]) public randomNumbers;

	event RequestRandomness(uint256 tokenId);

	constructor(
		address randomGenerator_,
		uint256 randomFee_
	) RandomConsumerBase(randomGenerator_, randomFee_) {}

	function getRandoms(uint256 tokenId_) public onlyOwner {
		_takeRandomFee();
		randomGenerator.requestRandomNumber(tokenId_);
		emit RequestRandomness(tokenId_);
	}

	function fulfillRandomness(uint256 tokenId_, uint256 randomness_) internal override(RandomConsumerBase) {
		seed = randomness_;
		uint256[] memory randomnesses = getRandomnesses(randomness_);
		randomNumbers[tokenId_] = new uint256[](6);
		for(uint256 i = 0; i < 6; i++) {
			randomNumbers[tokenId_][i] = randomnesses[i];
		}
	}

	function getData(uint256 tokenId_) public view returns(uint256, uint256[] memory) {
		return (seed, randomNumbers[tokenId_]);
	}
}