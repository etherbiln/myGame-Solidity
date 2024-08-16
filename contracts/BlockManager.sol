// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/PlayerManager.sol";

contract BlockManager {
    uint256 public constant GRID_SIZE = 7;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE * GRID_SIZE;
    PlayerManager public playerManager;

    struct Block {
        bool isTreasure;
        bool isSupportPackage;
    }

    mapping(uint256 => Block) public blocks;

    constructor() {
        // Initialize blocks with default values if necessary
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i] = Block(false, false);
        }

        // Create treasures and SupportPackage at random locations
        createTreasure();
        createSupportPackage();
    }

    // CREATE
    function createTreasure() private {
        for (uint256 i = 0; i < 5; i++) {
            uint256 x;
            uint256 y;
            uint256 position;

            do {
                x = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, i))) % GRID_SIZE; // or block.difficulty
                y = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, x, i))) % GRID_SIZE;
                position = x * GRID_SIZE + y;
            } while (blocks[position].isTreasure); // Ensure unique positions

            blocks[position].isTreasure = true;
        }
    }

    function createSupportPackage() private {
        for (uint256 i = 0; i < 5; i++) {
            uint256 x;
            uint256 y;
            uint256 position;

            do {
                x = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, i))) % GRID_SIZE;
                y = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, x, i))) % GRID_SIZE;
                position = x * GRID_SIZE + y;
            } while (blocks[position].isSupportPackage); // Ensure unique positions

            blocks[position].isSupportPackage = true;
        }
    }

    // CHECK
    function checkSupportPackage() public view returns (bool) {
        (uint256 playerX, uint256 playerY) = playerManager.findLocation(msg.sender);
        uint256 blockIndex = playerX * GRID_SIZE + playerY;

        return blocks[blockIndex].isSupportPackage;        
    }

    function checkTreasure() public view returns (bool) {
        (uint256 playerX, uint256 playerY) = playerManager.findLocation(msg.sender);
        uint256 blockIndex = playerX * GRID_SIZE + playerY;

        return blocks[blockIndex].isTreasure;
    }

    // GET
    function getBlock() public view returns (Block memory) {
        (uint256 playerX, uint256 playerY) =  playerManager.findLocation(msg.sender);
        uint256 blockIndex = playerX * GRID_SIZE + playerY;
        return blocks[blockIndex];
    }

    function getBlock(uint256 x,uint256 y) public view returns (Block memory) {
        uint256 blockIndex = x * GRID_SIZE + y;
        return blocks[blockIndex];
    }
}
