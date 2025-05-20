// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMeContract;
    uint256 public constant ETH_AMOUNT = 0.01 ether; // eth amount for testing fund functionalities
    address[] public accounts; // eth accounts for testing multiple funding operations
    address USER = makeAddr("user"); // address to use in my tests
    uint256 public constant STARTING_BALANCE = 10 ether; // starting balance for our user address
    uint256 constant GAS_PRICE = 1; // gas price to simulate withdrawing with gas on anvil

    function setUp() external {
        DeployFundMe deployFundMeContract = new DeployFundMe();
        fundMeContract = deployFundMeContract.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSDIsFiveDollars() public view {
        assertEq(fundMeContract.getMinimumUSD(), 5 * 1 ether, "minimum usd should be 5 dollars");
    }

    // // my own tests

    // function testOwnerIsDeployer() public view {
    //     // get getOwner
    //     // get the address of the deployer
    //     // assert they are equal
    //     assertEq(
    //         fundMeContract.getOwner(),
    //         address(this),
    //         "Owner should be the deployer"
    //     );
    // }

    // function testFundWithMinimumUsd() public {
    //     // call fund function with a value less than 5 dollars
    //     // expect it to revert
    //     vm.expectRevert(bytes("Value must be greater that 5 usd!"));
    //     fundMeContract.fund{value: 0.0001 ether}();
    // }

    // function testUpdateFundersArrayWithOneFunder() public {
    //     fundMeContract.fund{value: ETH_AMOUNT}();
    //     assertEq(
    //         address(this),
    //         fundMeContract.s_funders(0),
    //         "Funders array should be updated correctly"
    //     );
    // }

    // function testUpdateFundersArrayWithMultipleFunders() public {
    //     accounts.push(address(1));
    //     accounts.push(address(2));
    //     accounts.push(address(3));
    //     accounts.push(address(4));
    //     accounts.push(address(5));
    //     accounts.push(address(6));
    //     for (uint i = 0; i < accounts.length; i++) {
    //         vm.deal(accounts[i], 10 ether);
    //         vm.prank(accounts[i]);
    //         fundMeContract.fund{value: ETH_AMOUNT}();
    //     }
    //     assertEq(accounts.length, fundMeContract.getFundersLength());
    // }

    // rest of patrick's tutorial here
    function testOwnerIsMsgSender() public view {
        console.log(fundMeContract.getOwner());
        console.log(address(this));
        assertEq(fundMeContract.getOwner(), msg.sender, "Owner must be sender!");
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMeContract.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMeContract.fund();
    }

    function testFundUpdatesDataStructure() public {
        vm.prank(USER);
        fundMeContract.fund{value: ETH_AMOUNT}();
        uint256 amountFunded = fundMeContract.getAddressToAmountFunded(USER);
        assertEq(amountFunded, ETH_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMeContract.fund{value: ETH_AMOUNT}();
        address funder = fundMeContract.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMeContract.fund{value: ETH_AMOUNT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMeContract.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMeContract).balance;
        // Act
        vm.prank(fundMeContract.getOwner());
        fundMeContract.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMeContract).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // hoax(<some addtress>, ETH_AMOUNT)
            hoax(address(i), ETH_AMOUNT);
            fundMeContract.fund{value: ETH_AMOUNT}();
            // fund the fundMeContract
        }

        uint256 startingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMeContract).balance;

        // Act
        vm.startPrank(fundMeContract.getOwner());
        fundMeContract.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMeContract).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMeContract.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // hoax(<some addtress>, ETH_AMOUNT)
            hoax(address(i), ETH_AMOUNT);
            fundMeContract.fund{value: ETH_AMOUNT}();
            // fund the fundMeContract
        }

        uint256 startingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMeContract).balance;

        // Act
        vm.startPrank(fundMeContract.getOwner());
        fundMeContract.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMeContract).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMeContract.getOwner().balance);
    }
}
