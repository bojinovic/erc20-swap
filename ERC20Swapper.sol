// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;


import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Swapper } from "./interfaces/IERC20Swapper.sol";

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

contract ERC20Swapper is IERC20Swapper {

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

        // uint receivedAmount = _swapEtherToToken(token, minAmount);
        _swapEtherToToken(token, minAmount);

        uint erc20BalanceAfter = IERC20(token).balanceOf(msg.sender);
        uint receivedAmount = erc20BalanceAfter - erc20BalanceBefore;
        if (receivedAmount < minAmount) revert ReceivedLessTokens(receivedAmount, minAmount);

        uint ethBalanceAfter = address(this).balance;
        uint etherRemainder = ethBalanceAfter - ethBalanceBefore;
        if (etherRemainder > 0) {
            (bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
            if (sent == false) revert UnsuccesfulEtherSend(msg.sender, etherRemainder);
        }

        emit EtherSwappedForERC20(msg.sender, msg.value - etherRemainder, token, receivedAmount, etherRemainder);

        return receivedAmount;
    }


    
    function _swapEtherToToken(
        address token,
        uint256 minAmount
    ) internal returns (uint amountOut) {
        uint256 amountIn = msg.value;

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH9,
                tokenOut: token,
                fee: DEFAULT_POOL_FEE,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: minAmount,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle{value: amountIn}(params);
    }



    /// --------------------------------------- Implementation Details
    ISwapRouter public immutable swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint24 public constant DEFAULT_POOL_FEE = 3000;

    event EtherSwappedForERC20(address indexed swapper, uint etherAmount, address erc20, uint receivedAmount, uint etherRemainder);


    error ZeroTokenAmount();
    error ZeroEtherAmount();
    error ReceivedLessTokens(uint received, uint minAmount);
    error UnsuccesfulEtherSend(address recipient, uint amount);
}


