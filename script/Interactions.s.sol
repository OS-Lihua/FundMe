// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentDeployMent) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployMent)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployMent = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        fundFundMe(mostRecentDeployMent);
    }
}

contract WithDrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function withDrawFundMe(address mostRecentDeployMent) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployMent)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployMent = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withDrawFundMe(mostRecentDeployMent);
    }
}
