// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// import "./lib/RandomConsumerBase.sol";
import "./lib/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomTestV2 is VRFConsumerBaseV2, Ownable {
  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;

  // Rinkeby coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address private _vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

  // Rinkeby LINK token contract. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address private _link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  bytes32 private _keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

  uint32 private _callbackGasLimit = 100000;

  // The default is 3, but you can set this higher.
  uint16 private _requestConfirmations = 3;

  uint64 private _subscriptionId;
  uint256[] private _randomWords;
  uint256 public requestId;

	constructor(
		uint64 	subscriptionId_,
		address vrfCoordinator_,
		bytes32 keyHash_,
		address link_,
		uint32	callbackGasLimit_
	) VRFConsumerBaseV2(vrfCoordinator_) {
		COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);
    LINKTOKEN = LinkTokenInterface(link_);
    _subscriptionId = subscriptionId_;
		_keyHash = keyHash_;
		_callbackGasLimit = callbackGasLimit_;
	}

	function requestRandomness(uint32 numWords_) public onlyOwner {
		// require(numWords_ <= VRFCoordinatorV2.MAX_NUM_WORDS, "RandomGenerator: exceeds VRFCoordinatorV2.MAX_NUM_WORDS");
		requestId = COORDINATOR.requestRandomWords(
      _keyHash,
      _subscriptionId,
      _requestConfirmations,
      _callbackGasLimit,
      numWords_
    );
	}

	function fulfillRandomWords(uint256 requestId_, uint256[] memory randomWords_) internal override {
		_randomWords = randomWords_;
		requestId = requestId_;
	}

	function randomWords() public view returns(uint256[] memory) {
		return _randomWords;
	}

}