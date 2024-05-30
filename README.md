# ETH to ERC20 swapper

### Overview

Main (`ERC20Swapper`) contract calls an upgradeable Proxy which will delegate call into `UniswapV3Swapper` contract and perform the swap.

Reason for this is to separate the actual swap from the provider that is performing the swap.
If there are changes to the provider, or it becomes unresponsive, the protocol DAO could perform an upgrade.

For the users' safety, the `ERC20Swapper` always checks whether the user balances (ERC20 and ETH) are correct, and it doesn't depend on the swap providers for that. This contract cannot be upgraded, but it can be paused to have enough time for the swap provider to be upgraded.

### Project Info.

Dependencies: Foundry, and NodeJs.

#### Structure

- `./src/ERC20Swapper.sol` - main contract (owner, and users interact with it)
- `./src/swap-providers/UniswapV3Swapper.sol`
  - Uniswap V3 swapper (arb. integration example)

#### Testing & Deployment

Create and update `.env`:

```
cp .env.example .env
```

Testing (see: `./test/ERC20Swapper.t.sol`) - done using ETH mainnet fork:

```
rm -rf cache out
forge test --fork-url $RPC_URL --block-number 19974395 -vvvv
```

Deployment (see: `./script/ERC20Swapper_DeploymentProcedure`):

```
forge script ./script/ERC20Swapper_DeploymentProcedure.s.sol \
  --rpc-url $RPC_URL \
  --broadcast
```

**Contract Addresses (Sepolia)**:

- [`ERC20Swapper`]() - `a`
- [`Proxy`]() - `a`
- [`UniswapV3Swapper`]() - `a`

#### Notes:

- uniswap v3 version ....

```
source .env && anvil --rpc-url $RPC_URL --block-number $BLOCK_NUMBER
```

```
forge test --fork-url https://eth.llamarpc.com --block-number 19974395 -vvv
```
