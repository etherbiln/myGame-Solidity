const hre = require("hardhat");

async function main() {
  // Compile the contracts
  await hre.run('compile');

  // Get the contract factories
  const PlayerManager = await hre.ethers.getContractFactory("PlayerManager");
  const BlockManager = await hre.ethers.getContractFactory("BlockManager");
  const TokenManager = await hre.ethers.getContractFactory("TokenManager");
  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const TreasureHuntGame = await hre.ethers.getContractFactory("TreasureHuntGame");

  // Deploy the contracts
  const playerManager = await PlayerManager.deploy();
  await playerManager.deployed();
  console.log("PlayerManager deployed to:", playerManager.address);

  const blockManager = await BlockManager.deploy(playerManager.address);
  await blockManager.deployed();
  console.log("BlockManager deployed to:", blockManager.address);

  const tokenManager = await TokenManager.deploy(playerManager.address, blockManager.address);
  await tokenManager.deployed();
  console.log("TokenManager deployed to:", tokenManager.address);

  const initialAddress = "0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d"; // Corrected format
  const myToken = await MyToken.deploy(initialAddress);
  await myToken.deployed();
  console.log("MyToken deployed to:", myToken.address);

  const treasureHuntGame = await TreasureHuntGame.deploy(playerManager.address, blockManager.address, tokenManager.address, myToken.address);
  await treasureHuntGame.deployed();
  console.log("TreasureHuntGame deployed to:", treasureHuntGame.address);
}

// Run the main function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
