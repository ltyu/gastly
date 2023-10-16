// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

contract RootPoolScript is Script {
    address targetGas = address(0);
    address wormholeRelayer = 0x28D8F1Be96f97C1387e94A53e00eCcFb4E75175a;
    // address gelato1Balance = ;
    function setUp() public {

    }

    function run() public {
        vm.broadcast();
    }
}
