// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//  处于anvil时，部署模拟合约供我们使用
//  在不同的链上地址跟踪合约

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant ININIAL_PRICE = 2000e8;
    NetWorkConfig public activeNetWorkConfig;

    struct NetWorkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetWorkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetWorkConfig = getMainEthConfig();
        } else {
            activeNetWorkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetWorkConfig memory) {
        NetWorkConfig memory config = NetWorkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return config;
    }

    function getOrCreateAnvilEthConfig() public returns (NetWorkConfig memory) {
        if(activeNetWorkConfig.priceFeed != address(0)){
            return activeNetWorkConfig;
        }
        // 部署 mock 合约
        // 返回 mock 合约地址
        vm.startBroadcast();
        MockV3Aggregator mockV3PriceFeed = new MockV3Aggregator(
            DECIMALS,
            ININIAL_PRICE
        );
        vm.stopBroadcast();

        NetWorkConfig memory config = NetWorkConfig({
            priceFeed: address(mockV3PriceFeed)
        });
        return config;
    }

    function getMainEthConfig() public pure returns (NetWorkConfig memory) {
        NetWorkConfig memory config = NetWorkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return config;
    }
}
