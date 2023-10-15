// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract BasePool {
    // stablecoin address that this contract holds (probably, USDC)
    IERC20 immutable targetStable;

    // total assets in this pool
    uint256 public assetAmount;

    // The max bridgable amount
    uint256 public bandwidth;

    function depositLiquidity(uint256 amount) external {
        assetAmount += amount;
        bandwidth += amount;
        targetStable.transferFrom(msg.sender, address(this), amount);

        // Updates the other pool's lastKnownBandwidth
    }
}