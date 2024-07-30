// scripts/deploy.js

const hre = require("hardhat");

async function main() {
  // Get the contract factories
  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const TreasureHuntGame = await hre.ethers.getContractFactory("TreasureHuntGame");

  // Deploy MyToken contract
  const initialSupply = hre.ethers.utils.parseUnits("1000000", 18); // Example initial supply
  const myToken = await MyToken.deploy(initialSupply);
  await myToken.deployed();
  console.log("MyToken deployed to:", myToken.address);

  // Define the parameters for TreasureHuntGame
  const clueCost = hre.ethers.utils.parseUnits("100", 18); // Example clue cost
  const supportPackageBlocks = 5; // Example support package blocks
  const gameDuration = 3600; // Example game duration in seconds (1 hour)

  // Deploy TreasureHuntGame contract
  const treasureHuntGame = await TreasureHuntGame.deploy(myToken.address, clueCost, supportPackageBlocks, gameDuration);
  await treasureHuntGame.deployed();
  console.log("TreasureHuntGame deployed to:", treasureHuntGame.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
