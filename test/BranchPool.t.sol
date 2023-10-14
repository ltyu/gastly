// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BranchPool} from "../src/BranchPool.sol";
import {RootPool} from "../src/RootPool.sol";
import {MockToken} from "../src/test/MockToken.sol";
import {MockWormholeRelayer} from "../src/test/MockWormholeRelayer.sol";

contract BranchPoolTest is Test {
    RootPool rootPool;
    BranchPool branchPool;
    MockWormholeRelayer mockWormholeRelayer;
    MockToken targetStable;
    address alice;
    function setUp() public {
        targetStable = new MockToken();
        rootPool = new RootPool(address(targetStable));
        mockWormholeRelayer = new MockWormholeRelayer(address(rootPool));
        branchPool = new BranchPool(address(targetStable), address(mockWormholeRelayer), 1);
        alice = address(7);

        targetStable.approve(address(rootPool), 1 ether);
        rootPool.depositLiquidity(1 ether);

        targetStable.approve(address(branchPool), 1 ether);
        branchPool.depositLiquidity(1 ether);

        rootPool.setLastKnownRootBandwidth(1 ether);
        branchPool.setLastKnownRootBandwidth(1 ether);
        assertEq(targetStable.balanceOf(address(branchPool)), 1 ether);
        assertEq(branchPool.assetAmount(), 1 ether);
        assertEq(branchPool.bandwidth(), 1 ether);
    }

    function test_bridgeTargetStable() public {
        targetStable.approve(address(branchPool), 1 ether);
        branchPool.bridgeGas(1 ether, alice);
        assertEq(targetStable.balanceOf(address(branchPool)), 2 ether);
        assertEq(branchPool.bandwidth(), 0);
    }

    function test_bridgeShouldCreditOnRoot() public {
        targetStable.approve(address(branchPool), 1 ether);
        branchPool.bridgeGas(1 ether, alice);

        assertEq(rootPool.bandwidth(), 2 ether);
        assertEq(rootPool.lastKnownRootBandwidth(), 0);

    }
}
