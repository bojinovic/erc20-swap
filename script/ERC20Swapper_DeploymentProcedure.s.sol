// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import {ERC20Swapper} from "../src/ERC20Swapper.sol";
import {UniswapV3Swapper} from "../src/swap-providers/UniswapV3Swapper.sol";

/// @title Deployment script
/// @author @bojinovic
contract ERC20Swapper_DeploymentProcedure is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PK"));

        address proxyAddress = Upgrades.deployUUPSProxy(
            "UniswapV3Swapper.sol",
            abi.encodeCall(UniswapV3Swapper.initialize, ())
        );

        ERC20Swapper erc20Swapper = new ERC20Swapper(proxyAddress);

        vm.stopBroadcast();
    }
}
