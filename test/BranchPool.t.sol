// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BranchPool} from "../src/BranchPool.sol";

contract BranchPoolTest is Test {
    BranchPool public branchPool;
    address targetStable;

    function setUp() public {
        targetStable = 
        branchPool = new BranchPool();
    }

    function test_Increment() public {
        
    }
}
