require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
// require('@chainlink/hardhat-chainlink');

require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: process.env.INFURA_SEPOLIA_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    arbitrum: {
      url: process.env.ARBITRUM_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    hardhat: {
      chainId: 1337,
      blockGasLimit: 30000000,
      gas: 12000000, 
    },
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/123abc123abc123abc123abc123abcde",
      accounts: [process.env.PRIVATE_KEY]
    },
    atletaOlympia: {
      url: "https://testnet-rpc.atleta.network",  // Insert your RPC URL Here
      accounts: [process.env.PRIVATE_KEY],
      chainId: 2340, //Insert your ChainID Here
    }
  },
};
