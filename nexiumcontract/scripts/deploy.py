from brownie import VolumeBot, accounts, network, config
import os

def main():
    print(f"📡 Active Network: {network.show_active()}")

    # 🔐 Load deployer account
    if network.show_active() in ["development", "ganache-local"]:
        account = accounts[0]  # First Ganache account
    else:
        account = accounts.load("deployer_account")  # Or use private key method

    print(f"🚀 Deploying from: {account.address}")

    # 🚀 Deploy the contract
    deployed_contract = VolumeBot.deploy(
        {"from": account},
        publish_source=False  # Set to True if verifying on Etherscan
    )

    print(f"✅ Contract deployed at: {deployed_contract.address}")