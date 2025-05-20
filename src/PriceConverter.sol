// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface dataFeed) internal view returns (uint256) {
        (, int256 answer,,,) = dataFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 _amount, AggregatorV3Interface dataFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(dataFeed);
        uint256 ethAmountInUSD = (ethPrice * _amount) / 1 ether;
        return ethAmountInUSD;
    }
}
