// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../interface/IGelato1Balance.sol";

contract MockGelato1Balance is IGelato1Balance {
    mapping(address => mapping(address => uint256) ) public totalDepositedAmount;
    function depositToken(
        address _sponsor,
        IERC20 _token,
        uint256 _amount
    ) external {
        _depositToken(_sponsor, _token, _amount);
    }

    function _depositToken(address _sponsor, IERC20 _token, uint256 _amount) internal {
        totalDepositedAmount[_sponsor][address(_token)] += _amount;
        // Assumes we have not hitelisted fee-on-transfer tokens
        _token.transferFrom(msg.sender, address(this), _amount);
    }

    function depositNative(address _sponsor) external payable {
        totalDepositedAmount[_sponsor][address(0)] += msg.value;
        msg.sender.call{value: msg.value}("");
    }
}