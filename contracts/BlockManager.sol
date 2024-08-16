
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/PlayerManager.sol";

contract BlockManager {
    uint256 public constant GRID_SIZE = 7;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE * GRID_SIZE;

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

    // CREATE Chainlink can be added for random number generation!
    function createTreasure() private {
        for (uint256 i = 0; i < 5; i++) {
            uint256 x;
            uint256 y;
            uint256 position;

            do {
                x = random(i) % GRID_SIZE;
                y = random(x + i) % GRID_SIZE;
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
                x = random(i) % GRID_SIZE;
                y = random(x + i) % GRID_SIZE;
                position = x * GRID_SIZE + y;
            } while (blocks[position].isSupportPackage); // Ensure unique positions

            blocks[position].isSupportPackage = true;
        }
    }

    function random(uint256 salt) private view returns (uint256 result) {
        assembly {
            let data := mload(0x40)
            mstore(data, timestamp())
            mstore(add(data, 0x20), prevrandao())
            mstore(add(data, 0x40), caller())
            mstore(add(data, 0x60), salt) // salt değeri

            // keccak256 ile hash'le ve GRID_SIZE ile mod al
            result := mod(keccak256(data, 0x80), GRID_SIZE)
        }
    }

    // CHECK
    function checkFind() public view returns(uint256){
        PlayerManager  playerManager;
        (uint256 playerX, uint256 playerY) = playerManager.findLocation(msg.sender);
        return  playerX * GRID_SIZE + playerY;
    }

    function checkSupportPackage() public view returns (bool) {
        return blocks[checkFind()].isSupportPackage;        
    }

    function checkTreasure() public view returns (bool)  {
        return blocks[checkFind()].isTreasure;
    }

    // GET
    function getBlock() public view returns  (Block memory) {
        PlayerManager  playerManager;
        (uint256 playerX, uint256 playerY) =  playerManager.findLocation(msg.sender);
        uint256 blockIndex = playerX * GRID_SIZE + playerY;
        return blocks[blockIndex];
    }

    function getBlock(uint256 x,uint256 y) public view returns (Block memory) {
        uint256 blockIndex = x * GRID_SIZE + y;
        return blocks[blockIndex];
    }
    
    // MODIFIERS

}
