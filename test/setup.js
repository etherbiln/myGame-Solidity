const { ethers } = require("hardhat");

async function setupContracts() {
    const [deployer, player1, player2] = await ethers.getSigners();

    // Deploy PlayerManager contract
    const PlayerManager = await ethers.getContractFactory("PlayerManager");
    const playerManager = await PlayerManager.deploy();
    await playerManager.deployed();
    console.log("PlayerManager deployed at:", playerManager.address);

    // Deploy BlockManager contract with PlayerManager address
    const BlockManager = await ethers.getContractFactory("BlockManager");
    const blockManager = await BlockManager.deploy(playerManager.address);
    await blockManager.deployed();
    console.log("BlockManager deployed at:", blockManager.address);

    // Deploy MyToken contract
    const initialAddress = "0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d"; // Ensure this address is correct and has the right format
    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy(initialAddress);
    await myToken.deployed();
    console.log("MyToken deployed at:", myToken.address);

    // Deploy TokenManager contract with PlayerManager, BlockManager, and MyToken addresses
    const TokenManager = await ethers.getContractFactory("TokenManager");
    const tokenManager = await TokenManager.deploy(playerManager.address, blockManager.address, myToken.address);
    await tokenManager.deployed();
    console.log("TokenManager deployed at:", tokenManager.address);

    // Deploy TreasureHuntGame contract
    const TreasureHuntGame = await ethers.getContractFactory("TreasureHuntGame");
    const treasureHuntGame = await TreasureHuntGame.deploy(
        playerManager.address,
        blockManager.address,
        tokenManager.address,
        myToken.address
    );
    await treasureHuntGame.deployed();
    console.log("TreasureHuntGame deployed at:", treasureHuntGame.address);

    // Set authorized address
    try {
        await treasureHuntGame.setNewAuthorized(initialAddress);
        console.log("Deployer now set as authorized");
    } catch (error) {
        console.error("Error setting authorized address:", error);
    }

    // Set TreasureHunt address in TokenManager, PlayerManager, and BlockManager
    try {
        await tokenManager.setTreasureHunt(treasureHuntGame.address);
        console.log("TreasureHunt address set in TokenManager");
    } catch (error) {
        console.error("Error setting TreasureHunt address in TokenManager:", error);
    }

    try {
        await playerManager.setTreasureHunt(treasureHuntGame.address);
        console.log("TreasureHunt address set in PlayerManager");
    } catch (error) {
        console.error("Error setting TreasureHunt address in PlayerManager:", error);
    }

    try {
        await blockManager.setTreasureHunt(treasureHuntGame.address);
        console.log("TreasureHunt address set in BlockManager");
    } catch (error) {
        console.error("Error setting TreasureHunt address in BlockManager:", error);
    }

    return { deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame };
}

module.exports = setupContracts;
