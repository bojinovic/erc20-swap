# rm -rf cache out
# forge test --fork-url  https://eth.llamarpc.com  --block-number 19974395 

rm -rf cache out
forge script ./script/ERC20Swapper_DeploymentProcedure.s.sol \
  --rpc-url "https://eth-sepolia.g.alchemy.com/v2/n27ojytJkBev3YoRXTVLkcNQiqgicLrv" \
  --broadcast
