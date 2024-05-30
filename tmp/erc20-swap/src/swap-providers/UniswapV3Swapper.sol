// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { ISwapRouter } from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import { TransferHelper } from '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

import { IERC20ProxiedSwapper } from "../interfaces/IERC20ProxiedSwapper.sol";


contract UniswapV3Swapper is IERC20ProxiedSwapper, Initializable, UUPSUpgradeable, OwnableUpgradeable {

    /// @dev swaps the `msg.value` Ether to at least `minAmount` of tokens in `address`, or reverts
    /// @param beneficiary The recipient of tokens
    /// @param token The address of ERC-20 token to swap
    /// @param minAmount The minimum amount of tokens transferred to msg.sender
    /// @return amountOut The actual amount of transferred tokens
    function swapEtherToToken(
        address beneficiary,
        address token,
        uint256 minAmount
    ) external payable returns (uint amountOut) {
        uint256 amountIn = msg.value;

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH9,
                tokenOut: token,
                fee: DEFAULT_POOL_FEE,
                recipient: beneficiary,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: minAmount,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle{value: amountIn}(params);

        emit UniswapEthToERC20TradeExecuted(msg.sender, amountIn, token, amountOut);
    }


    ///@dev no constructor in upgradable contracts. Instead we have initializers
   function initialize() public initializer {

      ///@dev as there is no constructor, we need to initialise the OwnableUpgradeable explicitly
       __Ownable_init(msg.sender);
   }

   ///@dev required by the OZ UUPS module
   function _authorizeUpgrade(address) internal override onlyOwner {}

    /// --------------------------------------- Implementation Details

    ISwapRouter public immutable swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint24 public constant DEFAULT_POOL_FEE = 3000;

    event UniswapEthToERC20TradeExecuted(address indexed swapper, uint etherAmount, address erc20, uint receivedAmount);
}