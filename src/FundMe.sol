// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// imports
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;
    // state variables
    uint256 private constant MINIMUM_USD = 5 * 1 ether;
    address private immutable i_owner;
    address[] public s_funders;
    mapping(address => uint256) public s_addressToAmountFunded;
    AggregatorV3Interface s_dataFeed;

    error NotContractOwner();

    modifier FundeMe__allowOnlyOwner() {
        if (msg.sender != i_owner) revert NotContractOwner();
        _;
    }

    constructor(address dataFeed) {
        i_owner = msg.sender;
        s_dataFeed = AggregatorV3Interface(dataFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_dataFeed) >= MINIMUM_USD,
            "Value must be greater that 5 usd!"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_dataFeed.version();
    }

    function cheaperWithdraw() public FundeMe__allowOnlyOwner {
        // reset the s_addressToAmountFunded
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        // withdraw the funds
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Failed to withdraw eth!");
    }

    function withdraw() public FundeMe__allowOnlyOwner {
        // reset the s_addressToAmountFunded
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        // withdraw the funds
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Failed to withdraw eth!");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    /**
     * view / pure functions (Getters)
     */

    // getter function to get the length of the funders array to use in my test
    function getFundersLength() public view returns (uint256) {
        return s_funders.length;
    }

    function getMinimumUSD() public pure returns (uint256) {
        return MINIMUM_USD;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }
}
