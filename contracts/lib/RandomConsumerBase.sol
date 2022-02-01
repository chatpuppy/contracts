// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
import "./Context.sol";
import "../interfaces/IRandomConsumer.sol";
import "../interfaces/IRandomGenerator.sol";

abstract contract RandomConsumerBase is Context, IRandomConsumer {
    IRandomGenerator public randomGenerator;
    uint256 public randomFee;

    event UpdateRandomGenerator(address randomGenerator);
    event UpdateRandomFee(uint256 randomFee);

    constructor(address randomGenerator_, uint256 randomFee_) {
        _updateRandomGenerator(randomGenerator_);
        _updateRandomFee(randomFee_);
    }

    function _updateRandomGenerator(address randomGenerator_) internal {
        randomGenerator = IRandomGenerator(randomGenerator_);
        emit UpdateRandomGenerator(randomGenerator_);
    }

    function fulfillRandomness(uint256 tokenId_, uint256 randomness_)
        internal
        virtual;

    function rawFulfillRandomness(uint256 tokenId_, uint256 randomness_)
        external
    {
        require(_msgSender() == address(randomGenerator), "RandomConsumerBase: only selected generator can call this method");
        fulfillRandomness(tokenId_, randomness_);
    }

    function _updateRandomFee(uint256 randomFee_) internal {
        randomFee = randomFee_;
        emit UpdateRandomFee(randomFee_);
    }

    function _takeRandomFee() internal {
        if (randomFee > 0) {
            require(msg.value >= randomFee, "RandomConsumerBase: insufficient fee");
            (bool success, ) = address(randomGenerator).call{value: msg.value}(
                new bytes(0)
            );
            require(success, "RandomConsumerBase: fee required");
        }
    }
}