# TreasureHuntGame Smart Contract

## Overview

The `TreasureHuntGame` is a decentralized game built on the Ethereum blockchain. It allows players to join a treasure hunt, move within the game, buy clues, and find locations. The game is managed by three main components: `PlayerManager`, `BlockManager`, and `TokenManager`.

## Features

- **Grid-Based Movement:** Players navigate a 32x32 grid to find treasures and support packages.
- **Token Integration:** Utilizes a custom ERC-20 token for transactions and rewards.
- **Clue System:** Players can buy clues to help find treasures.
- **Game Management:** Allows players to join the game, move, and check their status.
- **Game Status:** Provides current status of the game and determines the winner based on steps taken.

## Contract Address

The contract interacts with a custom ERC-20 token. Ensure that you provide the correct token address during deployment.


## Constructor

```solidity
constructor(address _tokenAddress, uint256 _clueCost, uint256 _supportPackageBlocks, uint256 _gameDuration)
```

### Compile and Deploy Smart Contracts

Compile the smart contracts by running the following command:

```sh
npx hardhat compile
```

deploy Sepolia
```sh
npx hardhat run scripts/deploy.js --network sepolia
```

console hardhat
```sh
npx hardhat console  --network sepolia
```

![Example](./images/example.png)
