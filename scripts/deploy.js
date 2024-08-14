const hre = require("hardhat");

async function main() {
  // Get the contract factories
  const PlayerManager = await hre.ethers.getContractFactory("PlayerManager");
  const BlockManager = await hre.ethers.getContractFactory("BlockManager");
  const TokenManager = await hre.ethers.getContractFactory("TokenManager");
  const TreasureHuntGame = await hre.ethers.getContractFactory("TreasureHuntGame");

  // Deploy the PlayerManager contract
  console.log("Deploying PlayerManager...");
  const playerManager = await PlayerManager.deploy();
  await playerManager.deployed();
  console.log("PlayerManager deployed to:", playerManager.address);

  // Deploy the BlockManager contract
  console.log("Deploying BlockManager...");
  const blockManager = await BlockManager.deploy();
  await blockManager.deployed();
  console.log("BlockManager deployed to:", blockManager.address);

  // Define the token contract address (ensure this is a valid deployed token contract address)
  const tokenAddress = "0x7261ef9CB6b9509FF02E595f23411339ef8Ab09D";  // Update this with actual token contract address
  
  // Define clueCost and supportPackageBlocks as per your requirements
  const clueCost = hre.ethers.utils.parseUnits("10", 18); // Example: 10 tokens with 18 decimals
  const gameDuration = 3600; // Example: Game duration of 1 hour (3600 seconds)

  // Deploy the TokenManager contract
  console.log("Deploying TokenManager...");
  const tokenManager = await TokenManager.deploy(tokenAddress, clueCost);
  await tokenManager.deployed();
  console.log("TokenManager deployed to:", tokenManager.address);

  // Deploy the TreasureHuntGame contract with references to other contracts
  console.log("Deploying TreasureHuntGame...");
  
  const treasureHuntGame = await TreasureHuntGame.deploy(
    tokenManager.address, // TokenManager's address
    clueCost, 
    gameDuration
  );
  
  await treasureHuntGame.deployed();
  console.log("TreasureHuntGame deployed to:", treasureHuntGame.address);

  // Link the PlayerManager, BlockManager, and TokenManager to TreasureHuntGame
  console.log("Setting up contract integrations...");

  // Ensure these functions exist in the TreasureHuntGame contract
  try {
    await treasureHuntGame.setPlayerManager(playerManager.address);
    await treasureHuntGame.setBlockManager(blockManager.address);
    await treasureHuntGame.setTokenManager(tokenManager.address);
    console.log("Contracts successfully integrated!");
  } catch (error) {
    console.error("Error setting up contract integrations:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:", error);
    process.exit(1);
  });
