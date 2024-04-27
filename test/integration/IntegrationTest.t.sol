// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithDrawFundMe} from "../../script/Interactions.s.sol";

contract IntegrationTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, START_BALANCE);
    }

    function testUserCanFundInteracitons() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithDrawFundMe withDrawFundMe = new WithDrawFundMe();
        withDrawFundMe.withDrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
