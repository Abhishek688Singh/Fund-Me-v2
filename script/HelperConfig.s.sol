// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockAggregatorV3Interface.sol";

// START READING THE CODE FROM BOTTOM

contract HelperConfig is Script {
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    //used to store the details of *ACTIVE NETWORK*
    NetworkConfig public activeNetworkConfig;

    //struct to store the details of *NETWORK* in one place
    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainNetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    //return details of priceFeedAddress on sepolia network
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43});
        return sepoliaConfig;
    }

    //return details of priceFeedAddress on Eth MainNet network
    function getMainNetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainNetEthConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainNetEthConfig;
    }

    //return details of priceFeedAddress on Anvil network (Local)
    //1. we deploy mock
    //2. return the address of mock
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //if a network is already assigned return that value
        //it means mock is already deployed in past
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        //Deployment of mock
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMAL, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockV3Aggregator)});
        return anvilConfig;
    }
}
