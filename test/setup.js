const { ethers } = require("hardhat");

async function setupContracts() {
    const [deployer, player1, player2] = await ethers.getSigners();

    // Öncelikle PlayerManager'ı dağıtıyoruz
    const PlayerManager = await ethers.getContractFactory("PlayerManager");
    const playerManager = await PlayerManager.deploy();
    await playerManager.deployed();

    // Daha sonra BlockManager'ı dağıtıyoruz
    const BlockManager = await ethers.getContractFactory("BlockManager");
    const blockManager = await BlockManager.deploy(playerManager.address);
    await blockManager.deployed();

    // TokenManager'ı dağıtıyoruz
    const TokenManager = await ethers.getContractFactory("TokenManager");
    const tokenManager = await TokenManager.deploy(playerManager.address, blockManager.address);
    await tokenManager.deployed();

    // MyToken'ı dağıtıyoruz
    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy();
    await myToken.deployed();

    // Son olarak TreasureHuntGame'i dağıtıyoruz
    const TreasureHuntGame = await ethers.getContractFactory("TreasureHuntGame");
    const treasureHuntGame = await TreasureHuntGame.deploy(
        playerManager.address,
        blockManager.address,
        tokenManager.address,
        deployer.address // authorizedAddress olarak deployer'ı kullanıyoruz
    );
    await treasureHuntGame.deployed();

    return { deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame };
}

module.exports = setupContracts;
