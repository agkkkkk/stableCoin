// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {SCEngine} from "../src/SCEngine.sol";
import {HelperConfig} from "./HeplerConfig.sol";

contract DeploySC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (StableCoin, SCEngine) {
        HelperConfig helperConfig = new HelperConfig();

        (address wethUsdPriceFeed, address weth, uint256 deployerKey) = helperConfig.activeNetworkConfig();

        tokenAddresses = [weth];
        priceFeedAddresses = [wethUsdPriceFeed];
        vm.startBroadcast();
        StableCoin sc = new StableCoin();
        SCEngine engine = new SCEngine(tokenAddresses, priceFeedAddresses, address(sc));

        sc.transferOwnership(address(engine));
        vm.stopBroadcast();
    }
}
