// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/**
 * Connext xtoken that allows LP to bridge their tokens to another chain
 * The goal of this functionality is to allow LPs to claim their collateral in another chain, and help rebalance Pools.
 * 
 * Each token is worth 1:1 of the collateral. 
 */
contract LPXToken is ERC20 {
    constructor() ERC20("Gastly LP Token", "GAS-LP"){}

    // @dev anyone can mint, but this should be limited to Connext in Prod
    function mint(address account, uint256 value) external {
        _mint(account, value);
    }

    function burn(address account, uint256 value) external {
        _burn(account, value);
    }
}