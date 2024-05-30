// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import { ERC20Swapper } from "../src/ERC20Swapper.sol";
import { UniswapV3Swapper } from "../src/swap-providers/UniswapV3Swapper.sol";

contract ERC20Swapper_Test is Test {

    function setUp() public virtual {

        address proxyAddress = Upgrades.deployUUPSProxy(
            "UniswapV3Swapper.sol",
            abi.encodeCall(UniswapV3Swapper.initialize, ())
        );

        erc20Swapper = new ERC20Swapper(proxyAddress);

        tokenInfo.push(TokenInfo({token: DAI, price: 3700, decimals: 18}));
        tokenInfo.push(TokenInfo({token: USDC, price: 3700, decimals: 6}));
        tokenInfo.push(TokenInfo({token: ARB, price: 3000, decimals: 18}));
    }

    function test_swaps(uint etherAmount, uint extraAmount) public {
        etherAmount = 1;
        uint weiAmount = uint(etherAmount) * 1 ether;

        extraAmount = extraAmount % (10**15);
        // weiAmount += extraAmount;

        for (uint i; i < tokenInfo.length; ++i) {


            uint minAmount = (weiAmount * tokenInfo[i].price * (10 ** tokenInfo[i].decimals)) / 10**18;
            console2.log("token:", tokenInfo[i].token, "minAmount", minAmount);

            vm.startPrank(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
            uint received = erc20Swapper.swapEtherToToken{value: weiAmount}(tokenInfo[i].token, minAmount);


            //assertGt(received, minAmount);

            console2.log(received, minAmount);
        }
    }


    // function test_1() public {
    //     uint etherValue = 10**18 + 1;
    //     uint minAmount = 3850*10**18;

    //     vm.startPrank(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    //     uint received = erc20Swapper.swapEtherToToken{value: etherValue}(DAI, minAmount);

    //     console2.log(received, minAmount);
    // }

    ERC20Swapper internal erc20Swapper;

    struct TokenInfo {
        address token;
        uint price;
        uint decimals;
    }

    TokenInfo[] tokenInfo;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant ARB = 0xB50721BCf8d664c30412Cfbc6cf7a15145234ad1;

}
