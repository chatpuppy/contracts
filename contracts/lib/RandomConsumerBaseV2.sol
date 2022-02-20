// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
import "./Context.sol";
// import "../interfaces/IRandomConsumer.sol";
// import "../interfaces/IRandomGenerator.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

abstract contract RandomConsumerBaseV2 is VRFConsumerBaseV2, Context {
    VRFCoordinatorV2Interface public COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    uint256 public randomFee = 0;
    address public feeAccount;
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

    function _updateVRFCoordinator(address vrfCoordinator_) internal {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);
    }

    function _updateSubscriptionId(uint64 subscriptionId_) internal {
        _subscriptionId = subscriptionId_;
    }

    function _updateCallbackGasLimit(uint32 callbackGasLimit_) internal {
        _callbackGasLimit = callbackGasLimit_;
    }

    function _updateRandomFee(uint256 randomFee_) internal {
        randomFee = randomFee_;
    }

    function _updateFeeAccount(address feeAccount_) internal {
        feeAccount = feeAccount_;
    }

    function _requestRandomWords(uint32 numWords_) internal returns(uint256 requestId_) {
        requestId_ = COORDINATOR.requestRandomWords(
            _keyHash,
            _subscriptionId,
            _requestConfirmations,
            _callbackGasLimit,
            numWords_
        );
    }
    function _takeRandomFee() internal {
        if (randomFee > 0) {
            require(msg.value >= randomFee, "RandomConsumerBaseV2: insufficient fee");
            require(feeAccount != address(0), "RandomConsumerBaseV2: feeAccount is the zero address");
            (bool success, ) = address(feeAccount).call{value: msg.value}(new bytes(0));
            require(success, "RandomConsumerBase: fee required");
        }
    }
}