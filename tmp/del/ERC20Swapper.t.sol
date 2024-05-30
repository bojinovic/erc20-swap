// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { ERC20Swapper } from "../src/ERC20Swapper.sol";

contract ERC20Swapper_Test is Test {
    ERC20Swapper internal erc20Swapper;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        erc20Swapper = new ERC20Swapper();
        tokenInfo.push(TokenInfo({token: DAI, price: 3850, decimals: 18}));
        tokenInfo.push(TokenInfo({token: USDC, price: 3850, decimals: 6}));

    }

    function test_swaps(uint etherAmount, uint extraAmount) public {
        etherAmount = 1 + etherAmount%10;
        uint weiAmount = uint(etherAmount) * 1 ether;

        extraAmount = extraAmount % (10**15);
        weiAmount += extraAmount;

        for (uint i; i < tokenInfo.length; ++i) {


            uint minAmount = etherAmount * tokenInfo[i].price * (10 ** tokenInfo[i].decimals);
            console2.log("token:", tokenInfo[i].token, "minAmount", minAmount);



            vm.startPrank(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
            uint received = erc20Swapper.swapEtherToToken{value: weiAmount}(tokenInfo[i].token, minAmount);


            assertGt(received, minAmount);

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


    struct TokenInfo {
        address token;
        uint price;
        uint decimals;
    }

    TokenInfo[] tokenInfo;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

}
