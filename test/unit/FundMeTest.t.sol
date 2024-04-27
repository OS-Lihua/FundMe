// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundmeTest is Test {
    FundMe fundMe;

    /// 创建 一个调用者
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    // setUp 的调用者是 user
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        /// 为 URER 附加初始 的 ETH value
        vm.deal(USER, START_BALANCE);
    }

    function testMinDallerisFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testFundMeOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithOutEnoughETH() public {
        vm.expectRevert(); // 下一行应该回滚
        // assert(This ts fails / revert)
        fundMe.fund();
    }

    function testFundUpdateFundDataStructure() public {
        vm.prank(USER); // the next tx will send by USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayFunders() public {
        vm.prank(USER); // the next tx will send by USER
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER); //vm.prank(msg.sender);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithDrawWithASingleFunderCheaper() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // action
        vm.prank(fundMe.getOwner());
        fundMe.CheapWithDraw();

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithDrawFromMultipleFunders() public funded {
        uint160 startingFunderIndex = 1;
        uint160 numsOfFunders = 10;
        for (uint160 i = startingFunderIndex; i <= 10; ++i) {
            // vm.prank
            // vm.deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // action
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // assert
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.getOwner().balance
        );
    }
}

// user -> FundmeTest -> Fundme
// user -> FundmeTest -> DeployFundme -> Fundme
