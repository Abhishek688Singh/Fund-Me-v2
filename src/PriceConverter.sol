// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/*
sepolia eth -->0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
zk-sync -->0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
*/

// zk-sync has a hardtime with libraries

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeedAddress) public view returns (uint256) {
        //this FUNCTION return price of ** 1 ETH ** in USD
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 1e10); //PRICE IN USD
        //int256 answer IS A 8 DIGIT NUMBER.  1ETH IS 18 DIGITE NUMBER.
    }

    function getConversionRate(uint256 ethAmmount, AggregatorV3Interface priceFeedAddress)
        public
        view
        returns (uint256)
    {
        //this function converts the ETH ammount ** entered by user ** to USD
        uint256 oneEthPriceInUSD = getPrice(priceFeedAddress);
        uint256 totalEthPriceInUSD = (oneEthPriceInUSD * ethAmmount) / 1e18;
        return totalEthPriceInUSD;
    }
}
