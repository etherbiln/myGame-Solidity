// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockManager {
    uint256 public constant GRID_SIZE = 32;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE * GRID_SIZE;

    struct Block {
        bool isTreasure;
        bool isSupportPackage;
    }

    mapping (uint256 => Block) public blocks;

    constructor() {
        // Initialize blocks with default values if necessary
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i] = Block(false, false);
        }
    }

    function checkTreasure(uint256 x, uint256 y) public view returns (bool) {
        return blocks[x * GRID_SIZE + y].isTreasure;
    }

    function checkSupportPackage(uint256 x, uint256 y) public view returns (bool) {
        return blocks[x * GRID_SIZE + y].isSupportPackage;
    }
}
