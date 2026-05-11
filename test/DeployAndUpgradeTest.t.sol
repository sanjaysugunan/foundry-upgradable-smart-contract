// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public OWNER = makeAddr("owner");

    address public proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run(); // right now, points to box v1
    }

    function testBoxWorks() public view {
        uint256 expectedValue = 1;
        assertEq(expectedValue, BoxV1(proxy).version());
    }

    function testProxyStartsAsBox1() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(1); // this function doesn't exist in box v1, so it should revert
    }

    function testUpgrades() public {
        BoxV2 boxV2 = new BoxV2();
        upgrader.upgradeBox(proxy, address(boxV2)); // proxy now points to box v2
        uint256 expectedNumber = 2;
        assertEq(BoxV2(proxy).version(), expectedNumber);

        BoxV2(proxy).setNumber(42);
        assertEq(BoxV2(proxy).getNumber(), 42);
    }
}
