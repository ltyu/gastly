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

    constructor(address _targetGas, address _wormholeRelayer, address _targetAddress, uint16 _targetChain) {
        targetGas = _targetGas;
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        targetAddress = _targetAddress;
        targetChain = _targetChain;

        // @dev hardcoded for hackathon
        bandwidth = 10 ether;
    }

    modifier onlyTokenMode {
        require(targetGas != address(0), "WrongCall");
        _;
    }

    // @dev Helper function to sets the branch Pool and target gas for hackathon use
    function setTargetGas(address _targetGas) public onlyDeployer {
        targetGas = _targetGas;
    }

    /**
     * Bridges native token to the Root chain
     * @param _amount how much to deposit into 1Balance on behalf of the receiver
     * @param _receiver address that will receive the 1Balance credit
     * @param _gasLimit gas limit to calculate the cost to execute the transaction on the Root
     * @dev when using native gas, the msg.value will be expectedGas + amount to bridge
     */
    function bridgeGas(uint256 _amount, address _receiver, uint256 _gasLimit) external payable {
        require(bandwidth >= _amount, "NoBandwidth");
        uint256 gasCost = quoteGasCost(_gasLimit);

        _amount += calculateFee(_amount);
        bandwidth -= _amount;

        require(msg.value >= _amount, "InsufficientValue");

        wormholeRelayer.sendPayloadToEvm{value: gasCost}(
            targetChain,
            targetAddress,
            abi.encode(_receiver, _amount), // payload
            0, // no receiver value needed since we're just passing a message
            _gasLimit
        );
    }

    /**
     * Bridges the configured ERC20 token to the Root chain
     * @param _amount how much to deposit into 1Balance on behalf of the receiver
     * @param _receiver address that will receive the 1Balance credit
     * @param _gasLimit gas limit to calculate the cost to execute the transaction on the Root
     * @dev when using native gas, the msg.value will be expectedGas + amount to bridge
     */
    function bridgeGasToken(uint256 _amount, address _receiver, uint256 _gasLimit) external payable onlyTokenMode {
        require(bandwidth >= _amount, "NoBandwidth");
        uint256 gasCost = quoteGasCost(_gasLimit);
        
        _amount += calculateFee(_amount);
        bandwidth -= _amount;

        IERC20(targetGas).safeTransferFrom(msg.sender, address(this), _amount);

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
    function calculateFee(uint256) public pure returns (uint256) {
        return 0; 
    }

    // Calculate crosschain delivery payment. Reverts if msg.sender is not enough
    function quoteGasCost(uint256 _gasLimit) internal returns (uint256 gasCost) {
        (gasCost, ) = wormholeRelayer.quoteEVMDeliveryPrice(targetChain, 0, _gasLimit);
        require(msg.value >= gasCost, "NoGas");
    }
}
