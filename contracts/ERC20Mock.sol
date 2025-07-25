// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}