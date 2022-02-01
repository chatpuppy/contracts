// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/RandomConsumerBase.sol";
import "./lib/Ownable.sol";

contract RandomTest is RandomConsumerBase, Ownable {
	uint256 public randomNumber;
	uint256 public tokenId;

	event RequestRandomness(uint256 tokenId);

	constructor(
		address randomGenerator_,
		uint256 randomFee_
	) RandomConsumerBase(randomGenerator_, randomFee_) {}

	function requestRandomness(uint256 tokenId_) public onlyOwner {
		_takeRandomFee();
		randomGenerator.requestRandomNumber(tokenId_);
		emit RequestRandomness(tokenId_);
	}

	// Callback function
	// After requestRandomness successfully, this fulfillRandomness function will be called and set the random number.
	// Then you can get this number from outside.
	function fulfillRandomness(uint256 tokenId_, uint256 randomness_) internal override(RandomConsumerBase) {
		randomNumber = randomness_;
		tokenId = tokenId_;
	}

	function updateRandomFee(uint256 randomFee_) public onlyOwner{
		_updateRandomFee(randomFee_);
	}
}