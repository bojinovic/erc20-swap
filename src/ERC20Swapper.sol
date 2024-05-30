// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Swapper} from "./interfaces/IERC20Swapper.sol";
import {IERC20ProxiedSwapper} from "./interfaces/IERC20ProxiedSwapper.sol";

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract ERC20Swapper is IERC20Swapper, Ownable2Step {
    /// @dev `msg.sender` becomes initial owner of `Ownable2Step`
    constructor(address swappingProxyAddress) Ownable(msg.sender) {
        swappingProxy = IERC20ProxiedSwapper(swappingProxyAddress);
    }

    /// @dev swaps the `msg.value` Ether to at least `minAmount` of tokens in `address`, or reverts
    /// @param token The address of ERC-20 token to swap
    /// @param minAmount The minimum amount of tokens transferred to msg.sender
    /// @return The actual amount of transferred tokens
    function swapEtherToToken(
        address token,
        uint minAmount
    ) external payable returns (uint) {
        if (msg.value == 0) revert ZeroEtherAmount();
        if (minAmount == 0) revert ZeroTokenAmount();

        uint erc20BalanceBefore = IERC20(token).balanceOf(msg.sender);
        uint ethBalanceBefore = address(this).balance - msg.value;

        swappingProxy.swapEtherToToken{value: msg.value}(
            msg.sender,
            token,
            minAmount
        );

        uint erc20BalanceAfter = IERC20(token).balanceOf(msg.sender);
        uint receivedAmount = erc20BalanceAfter - erc20BalanceBefore;
        if (receivedAmount < minAmount)
            revert ReceivedLessTokens(receivedAmount, minAmount);

        uint ethBalanceAfter = address(this).balance;
        uint etherRemainder = ethBalanceAfter - ethBalanceBefore;
        if (etherRemainder > 0) {
            (bool sent, ) = msg.sender.call{value: msg.value}("");
            if (sent == false)
                revert UnsuccesfulEtherSend(msg.sender, etherRemainder);
        }

        emit EtherSwappedForERC20(
            msg.sender,
            msg.value - etherRemainder,
            token,
            receivedAmount,
            etherRemainder
        );

        return receivedAmount;
    }

    // -------------- Implementation details

    IERC20ProxiedSwapper public immutable swappingProxy;

    event EtherSwappedForERC20(
        address indexed swapper,
        uint etherAmount,
        address erc20,
        uint receivedAmount,
        uint etherRemainder
    );

    error ZeroTokenAmount();
    error ZeroEtherAmount();
    error ReceivedLessTokens(uint received, uint minAmount);
    error UnsuccesfulEtherSend(address recipient, uint amount);
}
