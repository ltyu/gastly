// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "wormhole-solidity-sdk/interfaces/IWormholeReceiver.sol";
import "./BasePool.sol";
import "./interface/IGelato1Balance.sol";
/**
 * This is the contract that will accept a crosschain request to credit a user
 * It subsequently deposits to 1Balance
 */

contract RootPool is IWormholeReceiver, BasePool {
    address public branchPool;
    address public wormholeRelayer;
    IGelato1Balance gelato1Balance;
    mapping(bytes32 => bool) seenDeliveryVaaHashes;

    constructor(address _targetStable, address _wormholeRelayer, address _gelato1Balance) {
        targetStable = IERC20(_targetStable);
        wormholeRelayer = _wormholeRelayer;
        gelato1Balance = IGelato1Balance(_gelato1Balance);
    }
    // Sets the branch Pool
    // @dev not admin for hackathon
    function setBranchPool(address _branchPool) public {
        branchPool = _branchPool;
    }

    function receiveWormholeMessages(
        bytes memory payload,
        bytes[] memory,
        bytes32 sourceAddress, // address that called 'sendPayloadToEvm' (HelloWormhole contract address)
        uint16 sourceChain,
        bytes32 deliveryHash
    ) external payable {
        require(msg.sender == address(wormholeRelayer), "Only relayer allowed");

        // Ensure no duplicate deliveries
        require(!seenDeliveryVaaHashes[deliveryHash], "Message already processed");
        seenDeliveryVaaHashes[deliveryHash] = true;

        (address receiver, uint256 amount) = abi.decode(payload, (address, uint256));
        bandwidth += amount;
        depositToRelayer(receiver, amount);
    }

    function depositToRelayer(address receiver, uint256 amount) internal {
        targetStable.approve(address(gelato1Balance), amount);
        gelato1Balance.depositToken(receiver, targetStable, amount);
    }
}