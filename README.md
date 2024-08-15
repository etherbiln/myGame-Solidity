# 🏴‍☠️ TreasureHuntGame 🏴‍☠️

## 🌟 Game Concept

**TreasureHuntGame** is a thrilling **decentralized, blockchain-based** treasure hunting adventure where players compete to find hidden treasures within a vast, mysterious virtual world. The game leverages **smart contracts** to manage player movements, block interactions, and token transactions, ensuring **transparency, fairness,** and **security**.

Each player navigates the virtual world, using **clues** and **strategies** to locate the treasure before others. The game is **time-bound**, adding a layer of **excitement** and **urgency**.

---

### 🚀 Key Features

- **🛡️ Decentralization:** The game operates on the blockchain, eliminating the need for a central authority and ensuring security and transparency.
- **⚔️ Competitive Play:** Players go head-to-head, racing to be the first to uncover the hidden treasure.
- **🧩 Clue Purchasing:** Players can buy clues using in-game tokens, increasing their chances of finding the treasure.
- **⏳ Time-Limited:** The game is designed with a specific duration in mind. Once the time is up, the game ends, and no further moves or clue purchases can be made.

---

### 🎮 How to Play

1. **Joining the Game:** Players join the game using the `joinGame` function.
2. **Starting the Game:** The game starts when an authorized person calls the `startGame` function.
3. **Player Movement:** Players navigate the game world using the `movePlayer` function.
4. **Clue Purchasing:** Players can purchase clues using the `buyClue` function to assist in locating the treasure.


### ROADMAP

![Example](./images/roadmap.png)

---

### 🚀 Compile and Deploy Smart Contracts

```sh
# Project Setup

To ensure the project runs correctly, you need to create a `.env` file with the following information:

This file should contain your private key and Infura project ID. Make sure to replace `your_private_key_here` and `your_infura_project_id_here` with your actual values.
```

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

![Example](./images/mygame.png)
