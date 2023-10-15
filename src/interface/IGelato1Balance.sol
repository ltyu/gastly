pragma solidity ^0.8.13;
import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IGelato1Balance {
    function depositToken(
        address _sponsor,
        IERC20 _token,
        uint256 _amount
    ) external;
}