// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "wormhole-solidity-sdk/interfaces/IWormholeReceiver.sol";
import "./BasePool.sol";

/**
 * This is the contract that will accept a crosschain request to credit a user
 * It subsequently deposits to 1Balance
 */

contract RootPool is IWormholeReceiver, BasePool {
    address public branchPool;
    
    constructor(address _targetStable) {
        targetStable = IERC20(_targetStable);
    }
    // Sets the branch Pool
    // @dev not admin for hackathon
    function setBranchPool(address _branchPool) public {
        branchPool = _branchPool;
    }

    function receiveWormholeMessages(
        bytes memory payload,
        bytes[] memory,
        bytes32 sourceAddress,
        uint16 sourceChain,
        bytes32 deliveryHash
    ) external payable {
        (address receiver, uint256 amount) = abi.decode(payload, (address, uint256));

        bandwidth += amount;
        lastKnownRootBandwidth -= amount;

        depositTo1Balance(receiver);
    }

    function depositTo1Balance(address receiver) internal {

    }
}