// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BranchPool} from "../src/BranchPool.sol";
import {RootPool} from "../src/RootPool.sol";
import {MockToken} from "../src/test/MockToken.sol";
import {MockWormholeRelayer} from "../src/test/MockWormholeRelayer.sol";
import {MockGelato1Balance} from "../src/test/MockGelato1Balance.sol";

contract BranchPoolTest is Test {
    RootPool rootPool;
    BranchPool branchPool;
    MockWormholeRelayer mockWormholeRelayer;
    MockToken targetStable;
    MockGelato1Balance mockGelato1Balance;
    address alice;
    function setUp() public {
        targetStable = new MockToken();
        mockWormholeRelayer = new MockWormholeRelayer();
        mockGelato1Balance = new MockGelato1Balance();
        rootPool = new RootPool(address(targetStable), address(mockWormholeRelayer), address(mockGelato1Balance));
        branchPool = new BranchPool(address(targetStable), address(mockWormholeRelayer), 1);

        mockWormholeRelayer.setRootPool(address(rootPool));
        alice = address(7);

        targetStable.approve(address(rootPool), 1 ether);
        rootPool.depositLiquidity(1 ether);

        targetStable.approve(address(branchPool), 1 ether);
        branchPool.depositLiquidity(1 ether);

        assertEq(targetStable.balanceOf(address(branchPool)), 1 ether);
        assertEq(branchPool.assetAmount(), 1 ether);
    }

    function test_bridgeTargetStable() public {
        targetStable.approve(address(branchPool), 1 ether);
        branchPool.bridgeGas(1 ether, alice);
        assertEq(targetStable.balanceOf(address(branchPool)), 2 ether);
        assertEq(branchPool.bandwidth(), 0);
    }

    function test_bridgeShouldIncreaseRootBandwidth() public {
        targetStable.approve(address(branchPool), 1 ether);

        branchPool.bridgeGas(1 ether, alice);

        assertEq(rootPool.bandwidth(), 2 ether);
    }

    function test_increaseGelato1Balance() public {
        targetStable.approve(address(branchPool), 1 ether);

        branchPool.bridgeGas(1 ether, alice);
        assertEq(mockGelato1Balance.totalDepositedAmount(alice, address(targetStable)), 1 ether);
    }

    function test_revertsOverBandwidth() public {
        targetStable.approve(address(branchPool), 1 ether);

        vm.expectRevert("No bandwidth");
        branchPool.bridgeGas(2 ether, alice);
    }
}
