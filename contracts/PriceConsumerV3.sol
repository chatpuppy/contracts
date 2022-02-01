// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Binance Smart Chain
     * Aggregator: BNB/USD
     * Mainnet
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
    }

    /**
     * Returns the latest price
     */
    // function getLatestPrice() public view returns (int) {
    //     (
    //         uint80 roundID, 
    //         int price,
    //         uint startedAt,
    //         uint timeStamp,
    //         uint80 answeredInRound
    //     ) = priceFeed.latestRoundData();
    //     return price;
    // }

    // function getHistoricalPrice(uint80 roundId) public view returns (int256) {
    //     (
    //         uint80 id,
    //         int price,
    //         uint startedAt,
    //         uint timeStamp,
    //         uint80 answeredInRound
    //     ) = priceFeed.getRoundData(roundId);
    //     require(timeStamp > 0, "Round not complete");
    //     return price;
    // }
}