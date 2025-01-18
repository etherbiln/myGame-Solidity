const { ethers } = require("hardhat");

async function main() {
  // Deploying the contract
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Subscription ID, genellikle Chainlink VRF'nin abone numarasını alırsınız.
  const subscriptionId = 1; // Buraya gerçek Subscription ID'nizi girin

  // Contract Factory'yi alıyoruz
  const RandomNumberGenerator = await ethers.getContractFactory("RandomNumberGenerator");

  // Contract'ı dağıtıyoruz
  const randomNumberGenerator = await RandomNumberGenerator.deploy(subscriptionId);
  console.log("RandomNumberGenerator contract deployed to:", randomNumberGenerator.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
