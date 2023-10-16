// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "wormhole-solidity-sdk/interfaces/IWormholeRelayer.sol";
import "./BasePool.sol";

// This is a pool contract used to hold USDC.
contract BranchPool is BasePool {
    using SafeERC20 for IERC20;

    // target pool contract
    address public immutable targetAddress;

    // target pool contract chain
    uint16 public immutable targetChain;

    // Relayer to send message cross chain
    IWormholeRelayer public immutable wormholeRelayer;

    constructor(address _targetStable, address _wormholeRelayer, address _targetAddress, uint16 _targetChain) {
        targetGas = _targetStable;
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        targetAddress = _targetAddress;
        targetChain = _targetChain;

        // @dev hardcoded for now
        bandwidth = 10 ether;
    }

    // @dev Helper function to sets the branch Pool and target gas for hackathon use
    function setTargetGas(address _targetGas) public {
        targetGas = _targetGas;
    }

    // Deposits the stable and credit the receiver cross-chain
    function bridgeGas(uint256 _amount, address _receiver, uint256 _gasLimit) external payable {
        // Check if theres enough bandwidth
        require(bandwidth >= _amount, "NoBandwidth");

        // Calculate fee using root pool bandwidth
        // e.g. if utilization is 100%, require that the fee be 50%
        _amount += calculateFee(_amount);

        // Calculate crosschain delivery payment
        (uint256 gasCost, ) = wormholeRelayer.quoteEVMDeliveryPrice(targetChain, 0, _gasLimit);
        require(msg.value >= gasCost, "NoGas");

        bandwidth -= _amount;

        if (targetGas == address(0)) {
            require(msg.value >= _amount, "NoValue");
        } else {
            IERC20(targetGas).safeTransferFrom(msg.sender, address(this), _amount);
        }

        wormholeRelayer.sendPayloadToEvm{value: gasCost}(
            targetChain,
            targetAddress,
            abi.encode(_receiver, _amount), // payload
            0, // no receiver value needed since we're just passing a message
            _gasLimit
        );
    }

    // Fee curve based on RootPool utilization
    // @dev currently doesn't do anything for the hackathon to reduce token cost
    function calculateFee(uint256 _amount) public pure returns (uint256) {
        return 0; 
    }
    
}
