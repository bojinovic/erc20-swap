# ETH to ERC20 swapper

### Overview

Main (`ERC20Swapper`) contract calls an upgradeable Proxy which will delegate call into `UniswapV3Swapper` contract and perform the swap.

Reason for this is to separate the actual swap from the provider that is performing the swap.
If there are changes to the provider, or it becomes unresponsive, the protocol DAO could perform an upgrade.

For the users' safety, the `ERC20Swapper` always checks whether the user balances (ERC20 and ETH) are correct, and it doesn't depend on the swap providers for that. This contract cannot be upgraded, but it can be paused to have enough time to replace swap providers.

### Project Info.

Dependencies: Foundry, and NodeJs.

#### Structure

- `./src/ERC20Swapper.sol` - main contract (owner, and users interact with it)
- `./src/swap-providers/UniswapV3Swapper.sol` - Uniswap V3 swapper (arb. integration example)

#### Testing & Deployment

Create and update `.env`:

```
cp .env.example .env
```

Testing (see: `./test/ERC20Swapper.t.sol`) - done using ETH mainnet fork:

```
rm -rf cache out
forge test --fork-url $MAINNET_RPC_URL --block-number 19974395 -vvvv
```

Deployment (see: `./script/ERC20Swapper_DeploymentProcedure`):

```
forge script ./script/ERC20Swapper_DeploymentProcedure.s.sol \
  --rpc-url $RPC_URL \
  --broadcast
```

**Contract Addresses (Sepolia)**:

- [`ERC20Swapper`](https://sepolia.etherscan.io/address/0x4475c444ef2392486bcebe151602ce35ba23dc4f) - `0x4475c444ef2392486bcebe151602ce35ba23dc4f`
- [`Proxy`](https://sepolia.etherscan.io/address/0x8c52e026ae9bafc77f97dd1c0ef429c98bb40622) - `0x8c52e026ae9bafc77f97dd1c0ef429c98bb40622`
- [`UniswapV3Swapper`](https://sepolia.etherscan.io/address/0x2192064607c431bb52b8ac9d26767a644b72e47c) - `0x2192064607c431bb52b8ac9d26767a644b72e47c`

#### Notes:

- In the real scenario, the `UniswapV3Swapper` would be compiled using the same version as UniswapV3 (0.7.6).
