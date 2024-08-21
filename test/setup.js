const { ethers } = require("hardhat");

async function setupContracts() {
    const [deployer, player1, player2] = await ethers.getSigners();

    const PlayerManager = await ethers.getContractFactory("PlayerManager");
    const playerManager = await PlayerManager.deploy();
    await playerManager.deployed();

    const BlockManager = await ethers.getContractFactory("BlockManager");
    const blockManager = await BlockManager.deploy(playerManager.address);
    await blockManager.deployed();

    const TokenManager = await ethers.getContractFactory("TokenManager");
    const tokenManager = await TokenManager.deploy(playerManager.address, blockManager.address);
    await tokenManager.deployed();

    const initialAddress = "0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d"; // Corrected format
    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy(initialAddress);

    await myToken.deployed();

    const TreasureHuntGame = await ethers.getContractFactory("TreasureHuntGame");
    const treasureHuntGame = await TreasureHuntGame.deploy(
        playerManager.address,
        blockManager.address,
        tokenManager.address,
        deployer.address
    );
    await treasureHuntGame.deployed();

    return { deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame };
}

module.exports = setupContracts;
