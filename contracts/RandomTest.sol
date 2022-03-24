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

	// function places(uint256 num) internal pure returns(uint256){
	// 		uint32 maxPlaces = 50; // tokenId can not be more than 10**51 - 1
	// 		uint256 _places = 0;
	// 		for(uint32 i = 1; i <= maxPlaces; i++) {
	// 				if(num >= 10**(i-1) && num <= 10**i - 1) {
	// 						_places = i;
	// 						break;
	// 				}
	// 		}
	// 		return _places;
	// }
	// function getRequestId(uint256 index, uint256 tokenId) internal pure returns (uint256 requestId_) {
	// 		requestId_ = uint256(index) * 10**(places(tokenId)) + tokenId;
	// }

	// function getIndexTokenId(uint256 requestId_) internal pure returns(uint256 index_, uint256 tokenId_) {
	// 		index_ = uint256(requestId_ / 10**(places(requestId_) - 1));
	// 		tokenId_ = requestId_ % 10**(places(requestId_) - 1);
	// }
}