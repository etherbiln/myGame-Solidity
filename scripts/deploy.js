const { ethers } = require("hardhat");

async function main() {
    const [deployer, player1, player2] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy PlayerManager
    const PlayerManager = await ethers.getContractFactory("PlayerManager");
    const playerManager = await PlayerManager.deploy();
    await playerManager.deployed();
    console.log("PlayerManager deployed to:", playerManager.address);

    // Deploy BlockManager with PlayerManager address
    const BlockManager = await ethers.getContractFactory("BlockManager");
    const blockManager = await BlockManager.deploy(playerManager.address);
    await blockManager.deployed();
    console.log("BlockManager deployed to:", blockManager.address);

    // Deploy MyToken with deployer's address as initial address
    const MyToken = await ethers.getContractFactory("HuntToken");
    const myToken = await MyToken.deploy();
    await myToken.deployed();
    console.log("HuntToken deployed to:", myToken.address);

    // Deploy TreasureHuntGame with PlayerManager, BlockManager, TokenManager, and MyToken addresses
    const TreasureHuntGame = await ethers.getContractFactory("TreasureHuntGame");
    
    const treasureHuntGame = await TreasureHuntGame.deploy(
        playerManager.address,
        blockManager.address,
        myToken.address
    );
    
    await treasureHuntGame.deployed();
    console.log("TreasureHuntGame deployed to:", treasureHuntGame.address);

    await treasureHuntGame.setNewAuthorized(deployer.address);
    console.log("Deployer now setNewAuthorized");

    await playerManager.setTreasureHunt(treasureHuntGame.address);
    console.log("TreasureHunt address set in PlayerManager");

    await blockManager.setTreasureHunt(treasureHuntGame.address);
    console.log("TreasureHunt address set in BlockManager");
}

// Run the setup script
main()
    .then(() => console.log("Deploy completed successfully"))
    .catch((error) => {
        console.error("Deploy failed with error:", error);
        process.exitCode = 1;
});
