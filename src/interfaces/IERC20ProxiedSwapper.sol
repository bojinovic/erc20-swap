// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

/// @title IERC20ProxiedSwapper
/// @author @bojinovic
/// @notice Helper interface for interacting with swap provider's proxy/implementation
interface IERC20ProxiedSwapper {
    /// @dev swaps the `msg.value` Ether to at least `minAmount` of tokens in `address`, or reverts
    /// @param beneficiary The recipient of tokens
    /// @param token The address of ERC-20 token to swap
    /// @param minAmount The minimum amount of tokens transferred to msg.sender
    /// @return amountOut The actual amount of transferred tokens
    function swapEtherToToken(
        address beneficiary,
        address token,
        uint minAmount
    ) external payable returns (uint amountOut);
}
