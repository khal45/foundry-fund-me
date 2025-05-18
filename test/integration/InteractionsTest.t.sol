// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMeContract;
    address USER = makeAddr("user"); // address to use in my tests
    uint256 public constant STARTING_BALANCE = 10 ether; // starting balance for our user address

    function setUp() external {
        DeployFundMe deployFundMeContract = new DeployFundMe();
        fundMeContract = deployFundMeContract.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMeContract = new FundFundMe();
        vm.deal(address(fundFundMeContract), STARTING_BALANCE);
        fundFundMeContract.fundFundMe(address(fundMeContract));

        WithdrawFundMe withdrawFundMeContract = new WithdrawFundMe();
        withdrawFundMeContract.withdrawFundMe(address(fundMeContract));

        assert(address(fundMeContract).balance == 0);
    }
}
