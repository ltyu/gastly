// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/interfaces/IERC20.sol";

// This is a pool contract used to hold USDC.
contract BranchPool {
    // stablecoin address that this contract holds (probably, USDC)
    IERC20 targetStable;

    constructor(IERC20 _targetStable) {
        targetStable = _targetStable;
    }
    // Swaps and deposit chain native token (eg. ftm on Fantom) and credit the receiver
    function depositNative(address receiver, uint256 amount, uint256 slippage) payable external {

    }

    // Swaps and deposit a specific token and credit the receiver
    function depositToken(address receiver, address token, uint256 amount, uint256 slippage) external {
        // TODO create an allowlist to prevent junk/low liquidity tokens
        // Calls uniswap to swap a target token for USDC from msg.sender
        
        // with the USDC amount, sends to wormhole to credit the receiver
    }

    // Deposits the stable and credit the receiver
    function depositStable(uint256 amount, address receiver) external {
        targetStable.transferFrom(msg.sender, address(this), amount);

        // with the USDC amount, sends to wormhole to credit the receiver

    }

    // TODO incase crosschain fails, consider a withdraw deposit function
}
