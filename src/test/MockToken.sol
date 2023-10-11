// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// this is a MOCK
contract MockToken is ERC20 {
    constructor()
        ERC20('Mock', 'MK')
    {
        _mint(msg.sender, 1000000000 * 10**18);
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}