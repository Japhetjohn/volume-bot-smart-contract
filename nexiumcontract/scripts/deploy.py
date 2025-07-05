from brownie import VolumeBot, accounts

def main():
    deployer = accounts[0]  # Local Ganache account
    print(f"🚀 Deploying VolumeBot from: {deployer}")
    
    volumebot = VolumeBot.deploy({"from": deployer})
    print(f"✅ VolumeBot deployed at: {volumebot.address}")