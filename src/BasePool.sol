// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "xERC20/solidity/contracts/XERC20.sol";

contract BasePool {
    using SafeERC20 for IERC20;

    // The token that lps receive to allow them to bridge to other chains
    address public immutable lpXToken;

    address public immutable deployer;

    // stablecoin address that this contract holds (probably, USDC). if address(0), then native gas is expected.
    // @dev can be immutable post-hackathon
    address public targetGas;

    // total assets in this pool
    uint256 public assetAmount;

    // The max amount that this pool can transfer the other pool. Essentially should be the liquidity of the other pool.
    uint256 public bandwidth;

    modifier onlyDeployer() {
        require(msg.sender == deployer, "onlyDeploy");
        _;
    }

    constructor(address _lpXToken) {
        deployer = msg.sender;
        lpXToken = _lpXToken;
    }

    function depositLiquidity(uint256 amount) payable external {
        assetAmount += amount;
        if (targetGas == address(0)) {
            require(msg.value == amount, "NoDep");
        } else {
            require(msg.value == 0, "DepGt0");
            IERC20(targetGas).safeTransferFrom(msg.sender, address(this), amount);
        }

        XERC20(lpXToken).mint(msg.sender, amount);
        
        // TODO Updates the other pool's lastKnownBandwidth
    }

    // Withdraws and burn an amount of collateral
    function withdrawLiquidty(uint256 amount) external {
        assetAmount -= amount;
        XERC20(lpXToken).burn(msg.sender, amount);
        
        // @dev this only handles native token transfer for now
        (bool success, ) = address(msg.sender).call{value: amount}("");
        require(success, "WithdrawFail");
    }

    // @dev helper function to withdraw all liquidity. only used during hackathon to reclaim tokens
    function emergencyWithdrawLiquidity(address receiver) external onlyDeployer {
        if (targetGas == address(0)) { 
            (bool success, ) = receiver.call{ value: address(this).balance }("");
            require(success, "withdrawLiquidityFailed");
        } else {
            IERC20(targetGas).safeTransfer(receiver, IERC20(targetGas).balanceOf(address(this)));
        }
    }

    // @dev helper function to set bandwidth. only used during hackathon to reduce cross-chain gas cost.
    function setBandwidth(uint256 _bandwidth) external onlyDeployer {
        bandwidth = _bandwidth;
    }
}