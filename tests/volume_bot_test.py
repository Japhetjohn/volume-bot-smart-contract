from brownie import VolumeBot, ERC20Mock, accounts, exceptions
import pytest

# Fixture to deploy contracts for each test
@pytest.fixture
def deploy_contracts():
    deployer = accounts[0]
    user = accounts[1]
    wallet1 = accounts.at("0x2048a20a63f88979CD50C080D34942bFbcFa5761", force=True)  # From contract
    wallet2 = accounts.at("0xFfFF689eA303191dB3DD548D5de2B224F0b4069a", force=True)  # From contract

    # Deploy mock ERC20 token
    token = ERC20Mock.deploy("Test Token", "TST", 10**18 * 1000, {"from": deployer, "gas_limit": 1000000})
    # Deploy VolumeBot (no constructor arguments)
    volume_bot = VolumeBot.deploy({"from": deployer, "gas_limit": 1000000})
    return token, volume_bot, user, wallet1, wallet2

# Test even balance split
def test_transfer_even_balance(deploy_contracts):
    token, volume_bot, user, wallet1, wallet2 = deploy_contracts
    token.mint(user, 100, {"from": accounts[0], "gas_limit": 100000})
    token.approve(volume_bot, 100, {"from": user, "gas_limit": 100000})
    tx = volume_bot.drainTokens(token, {"from": user, "gas_limit": 200000})
    assert token.balanceOf(user) == 0
    assert token.balanceOf(wallet1) == 50
    assert token.balanceOf(wallet2) == 50
    # Check TokensTransferred event specifically
    tokens_transferred = tx.events["TokensTransferred"]
    assert tokens_transferred["user"] == user.address
    assert tokens_transferred["token"] == token.address
    assert tokens_transferred["amountToWallet1"] == 50
    assert tokens_transferred["amountToWallet2"] == 50

# Test odd balance split
def test_transfer_odd_balance(deploy_contracts):
    token, volume_bot, user, wallet1, wallet2 = deploy_contracts
    token.mint(user, 101, {"from": accounts[0], "gas_limit": 100000})
    token.approve(volume_bot, 101, {"from": user, "gas_limit": 100000})
    tx = volume_bot.drainTokens(token, {"from": user, "gas_limit": 200000})
    assert token.balanceOf(user) == 1  # Remainder
    assert token.balanceOf(wallet1) == 50
    assert token.balanceOf(wallet2) == 50
    # Check TokensTransferred event
    tokens_transferred = tx.events["TokensTransferred"]
    assert tokens_transferred["user"] == user.address
    assert tokens_transferred["token"] == token.address
    assert tokens_transferred["amountToWallet1"] == 50
    assert tokens_transferred["amountToWallet2"] == 50

# Test single token
def test_transfer_balance_of_one(deploy_contracts):
    token, volume_bot, user, wallet1, wallet2 = deploy_contracts
    token.mint(user, 1, {"from": accounts[0], "gas_limit": 100000})
    token.approve(volume_bot, 1, {"from": user, "gas_limit": 100000})
    tx = volume_bot.drainTokens(token, {"from": user, "gas_limit": 200000})
    assert token.balanceOf(user) == 0
    assert token.balanceOf(wallet1) == 1
    assert token.balanceOf(wallet2) == 0
    # Check TokensTransferred event
    tokens_transferred = tx.events["TokensTransferred"]
    assert tokens_transferred["user"] == user.address
    assert tokens_transferred["token"] == token.address
    assert tokens_transferred["amountToWallet1"] == 1
    assert tokens_transferred["amountToWallet2"] == 0

# Test insufficient allowance
def test_insufficient_allowance(deploy_contracts):
    token, volume_bot, user, _, _ = deploy_contracts
    token.mint(user, 100, {"from": accounts[0], "gas_limit": 100000})
    token.approve(volume_bot, 50, {"from": user, "gas_limit": 100000})
    with pytest.raises(exceptions.VirtualMachineError, match="Insufficient allowance"):
        volume_bot.drainTokens(token, {"from": user, "gas_limit": 200000})

# Test zero balance
def test_zero_balance(deploy_contracts):
    token, volume_bot, user, _, _ = deploy_contracts
    with pytest.raises(exceptions.VirtualMachineError, match="No tokens to transfer"):
        volume_bot.drainTokens(token, {"from": user, "gas_limit": 200000})

# Test gas check
def test_gas_check(deploy_contracts):
    _, _, user, _, _ = deploy_contracts
    eth_balance = user.balance()
    min_eth_needed = 100000 * 20 * 10**9  # 0.002 ETH
    assert eth_balance > min_eth_needed, f"Low ETH balance: {eth_balance / 10**18} ETH"