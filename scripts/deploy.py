from brownie import VolumeBot, ERC20Mock, accounts

def main():
    deployer = accounts.at("0x3d9fc2B5C5E02C0C955389302C4fe0362FA0a389", force=True)  # Ganache accounts[0]
    
    # Deploy mock ERC20 token
    token = ERC20Mock.deploy("Test Token", "TST", 10**18 * 1000, {"from": deployer, "gas_limit": 1000000})
    print(f"Token deployed at: {token.address}")

    # Deploy VolumeBot
    volume_bot = VolumeBot.deploy({"from": deployer, "gas_limit": 1000000})
    print(f"VolumeBot deployed at: {volume_bot.address}")

    # Confirm addresses
    print(f"Deployed contracts - Token: {token.address}, VolumeBot: {volume_bot.address}")

    return token, volume_bot