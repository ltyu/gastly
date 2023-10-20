// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BranchPool} from "../src/BranchPool.sol";
import {RootPool} from "../src/RootPool.sol";
import {MockToken} from "../src/test/MockToken.sol";
import {MockWormholeRelayer} from "../src/test/MockWormholeRelayer.sol";
import {MockGelato1Balance} from "../src/test/MockGelato1Balance.sol";

contract PoolTest is Test {
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
        branchPool = new BranchPool(address(targetStable), address(mockWormholeRelayer), address(0), 1);

        mockWormholeRelayer.setRootPool(address(rootPool));
        alice = address(7);

        targetStable.approve(address(rootPool), 1 ether);
        rootPool.depositLiquidity(1 ether);

        targetStable.approve(address(branchPool), 1 ether);
        branchPool.depositLiquidity(1 ether);

        // @dev these are manually set for now
        rootPool.setBandwidth(1 ether);
        branchPool.setBandwidth(1 ether);

        assertEq(targetStable.balanceOf(address(branchPool)), 1 ether);
        assertEq(branchPool.assetAmount(), 1 ether);
    }

    function test_lPTokenMint() public {
        assertEq(rootPool.balanceOf(address(this)), 1 ether);
    }

    function test_bridgeGasToken() public {
        targetStable.approve(address(branchPool), 1 ether);
        branchPool.bridgeGasToken{ value: 1 ether }(1 ether, alice, 500000);
        assertEq(targetStable.balanceOf(address(branchPool)), 2 ether);

        assertEq(branchPool.bandwidth(), 0);
    }

    function test_bridgeShouldIncreaseRootBandwidth() public {
        targetStable.approve(address(branchPool), 1 ether);

        branchPool.bridgeGasToken{ value: 1 ether }(1 ether, alice, 500000);

        assertEq(rootPool.bandwidth(), 2 ether);
    }

    function test_increaseGelato1Balance() public {
        targetStable.approve(address(branchPool), 1 ether);

        branchPool.bridgeGasToken{ value: 1 ether }(1 ether, alice, 500000);
        assertEq(mockGelato1Balance.totalDepositedAmount(alice, address(targetStable)), 1 ether);
    }

    function test_revertsOverBandwidth() public {
        targetStable.approve(address(branchPool), 1 ether);

        vm.expectRevert("NoBandwidth");
        branchPool.bridgeGasToken{ value: 1 ether }(2 ether, alice, 500000);
    }

    function test_revertsWithdrawLiquidityOnlyDeployer() public {
        vm.startPrank(alice);
        vm.expectRevert("onlyDeploy");
        branchPool.withdrawLiquidity(alice);
        vm.stopPrank();
    }

    function test_withdrawLiquidity() public {
        uint256 balanceBefore = targetStable.balanceOf(address(this));
        branchPool.withdrawLiquidity(address(this));
        uint256 balanceAfter = targetStable.balanceOf(address(this));

        assertEq(balanceBefore, balanceAfter - 1 ether);
    }

    function test_nativeGasRootMismatchAmount() public {
        branchPool = new BranchPool(address(0), address(mockWormholeRelayer), address(0), 1);
        rootPool.setBranchPool(address(branchPool), address(0));

        vm.expectRevert("NoDep");
        rootPool.depositLiquidity{value: 6 ether}(5 ether);
    }

    function test_revertUsingWrongBridgeGasFunction() public {
        branchPool = new BranchPool(address(0), address(mockWormholeRelayer), address(0), 1);
        rootPool.setBranchPool(address(branchPool), address(0));

        vm.expectRevert("WrongCall");
        branchPool.bridgeGasToken{ value: 1 ether }(2 ether, alice, 500000);
    }

    function test_nativeGasRoot() public {
        branchPool = new BranchPool(address(0), address(mockWormholeRelayer), address(0), 1);
        rootPool.setBranchPool(address(branchPool), address(0));

        // Successfully deposits eth
        uint256 balanceBefore = address(rootPool).balance;
        rootPool.depositLiquidity{value: 5 ether}(5 ether);
        uint256 balanceAfter = address(rootPool).balance;
        assertEq(balanceBefore, balanceAfter - 5 ether);

        branchPool.setBandwidth(5 ether);
        branchPool.bridgeGas{value: 5 ether}(alice, 500000);

        // Should be 4 ether because of gas costs
        assertEq(mockGelato1Balance.totalDepositedAmount(alice, address(0)), 4 ether);
    }

    function test_withdrawNativeLiquidity() public {
        branchPool = new BranchPool(address(0), address(mockWormholeRelayer), address(0), 1);
        rootPool.setBranchPool(address(branchPool), address(0));

        // Successfully deposits eth
        branchPool.depositLiquidity{value: 5 ether}(5 ether);

        uint256 balanceBefore = alice.balance;
        branchPool.withdrawLiquidity(alice);
        uint256 balanceAfter = alice.balance;
        assertEq(balanceBefore, balanceAfter - 5 ether);
    }
}
