// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockAggregatorV3Interface is AggregatorV3Interface {
    uint80 public roundId;
    int256 public price;
    uint256 public startedAt;
    uint256 public updatedAt;
    uint80 public answeredInRound;

    function setLatestRoundData(
        uint80 _roundId,
        int256 _price,
        uint256 _startedAt,
        uint256 _updatedAt,
        uint80 _answeredInRound
    ) public {
        roundId = _roundId;
        price = _price;
        startedAt = _startedAt;
        updatedAt = _updatedAt;
        answeredInRound = _answeredInRound;
    }

    function latestRoundData()
        public
        view
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (roundId, price, startedAt, updatedAt, answeredInRound);
    }

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        // For simplicity, we return the same data as latestRoundData() in this mock
        return (roundId, price, startedAt, updatedAt, answeredInRound);
    }

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "Mock Aggregator";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }
}
