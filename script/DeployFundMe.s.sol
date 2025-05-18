// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// imports
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperconfig = new HelperConfig();
        address ethUsdDataFeed = helperconfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMeContract = new FundMe(ethUsdDataFeed);
        vm.stopBroadcast();
        return fundMeContract;
    }
}
