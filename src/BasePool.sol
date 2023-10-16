// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract BasePool {
    address immutable deployer;

    // stablecoin address that this contract holds (probably, USDC)
    IERC20 immutable targetStable;

    // total assets in this pool
    uint256 public assetAmount;

    // The max amount that this pool can transfer the other pool. Essentially should be the liquidity of the other pool.
    uint256 public bandwidth;

    modifier onlyDeployer() {
        require(msg.sender == deployer);
        _;
    }

    constructor() {
        deployer = msg.sender;
    }

    function depositLiquidity(uint256 amount) external {
        assetAmount += amount;
        targetStable.transferFrom(msg.sender, address(this), amount);

        // TODO Updates the other pool's lastKnownBandwidth
    }

    // @dev helper function to withdraw all liquidity. only used during hackathon to reclaim tokens
    function withdrawLiquidity() external onlyDeployer {
        
    }
}