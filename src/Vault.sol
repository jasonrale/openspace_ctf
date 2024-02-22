// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VaultLogic {
    address public owner;
    bytes32 private password;

    constructor(bytes32 _password) {
        owner = msg.sender;
        password = _password;
    }

    function changeOwner(bytes32 _password, address newOwner) public {
        if (password == _password) {
            owner = newOwner;
        } else {
            revert("password error");
        }
    }
}

contract Vault {
    address public owner;
    VaultLogic logic;
    mapping(address => uint256) deposits;
    bool public canWithdraw = false;

    constructor(address _logicAddress) {
        logic = VaultLogic(_logicAddress);
        owner = msg.sender;
    }

    fallback() external {
        (bool result,) = address(logic).delegatecall(msg.data);
        if (result) {
            this;
        }
    }

    receive() external payable {}

    function deposit() public payable {
        deposits[msg.sender] += msg.value;
    }

    function isSolve() external view returns (bool) {
        if (address(this).balance == 0) {
            return true;
        }
    }

    function openWithdraw() external {
        if (owner == msg.sender) {
            canWithdraw = true;
        } else {
            revert("not owner");
        }
    }

    function withdraw() public {
        require(canWithdraw == true, "can't withdraw");

        if (deposits[msg.sender] >= 0) {
            (bool result,) = msg.sender.call{value: deposits[msg.sender]}("");
            if (result) {
                deposits[msg.sender] = 0;
            }
        }
    }
}
