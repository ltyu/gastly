// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "wormhole-solidity-sdk/interfaces/IWormholeRelayer.sol";
import "./BasePool.sol";

// This is a pool contract used to hold USDC.
contract BranchPool is BasePool {
    using SafeERC20 for IERC20;

    uint256 constant GAS_LIMIT = 50_000;

    // target pool contract
    address immutable targetAddress;

    // target pool contract chain
    uint16 immutable targetChain;

    // Relayer to send message cross chain
    IWormholeRelayer public immutable wormholeRelayer;

    constructor(address _targetStable, address _wormholeRelayer, uint16 _targetChain) {
        targetGas = _targetStable;
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        targetChain = _targetChain;
    }

    // Deposits the stable and credit the receiver cross-chain
    function bridgeGas(uint256 _amount, address _receiver) external payable {
        // Check if theres enough bandwidth
        require(bandwidth >= _amount, "No bandwidth");

        // Calculate fee using root pool bandwidth
        // e.g. if utilization is 100%, require that the fee be 50%
        _amount += calculateFee();

        // Calculate crosschain delivery payment
        (uint256 gasCost, ) = wormholeRelayer.quoteEVMDeliveryPrice(targetChain, 0, GAS_LIMIT);
        require(msg.value >= gasCost);

        bandwidth -= _amount;

        if (targetGas == address(0)) {
            require(msg.value >= _amount);
        } else {
            IERC20(targetGas).safeTransferFrom(msg.sender, address(this), _amount);
        }

        bytes memory payload = abi.encode(_receiver, _amount);
        wormholeRelayer.sendPayloadToEvm{value: gasCost}(
            targetChain,
            targetAddress,
            payload, // payload
            0, // no receiver value needed since we're just passing a message
            GAS_LIMIT
        );
    }

    // @dev currently doesn't do anything for the hackathon to reduce token cost
    function calculateFee() public returns (uint256) {
    }
}
