// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BranchPool} from "../src/BranchPool.sol";
import {MockToken} from "../src/test/MockToken.sol";

contract BranchPoolTest is Test {
    BranchPool public branchPool;
    MockToken targetStable;
    address alice;
    function setUp() public {
        targetStable = new MockToken();
        branchPool = new BranchPool(targetStable);
        alice = address(7);
    }

    function test_depositTargetStable() public {
        targetStable.approve(address(branchPool), 1 ether);
        branchPool.depositStable(1 ether, alice);
        assertEq(targetStable.balanceOf(address(branchPool)), 1 ether);
    }
}
