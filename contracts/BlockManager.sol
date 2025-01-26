// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PlayerManager.sol";
import "./random.sol";

/**
 * @title BlockManager
 * @dev Manages blocks for the Treasure Hunt game, including creating treasures and support packages in 3D grid.
 */
contract BlockManager {
    PlayerManager public playerManager;
    RandomNumberGenerator public randoms;

    uint256 public constant GRID_SIZE = 5;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE * GRID_SIZE * GRID_SIZE; // 3D Grid
    
    address public setOwner = 0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d;
    address public treasureHuntAddress;

    struct Block {
        bool isTreasure;
        bool isSupportPackage;
    }

    mapping(uint256 => Block) private blocks;

    /**
     * @dev Constructor initializes the BlockManager contract.
     * @param _playerManager The address of the PlayerManager contract.
     */
    constructor(address _playerManager) {
        playerManager = PlayerManager(_playerManager);
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i] = Block(false, false);
        }
    }

    // Create Functions

    /**
     * @dev Creates a treasure in a random block.
     */
    function createTreasure() external view onlyTreasureHunt {
        // uint256 position = randoms.getRandomNumberInRange(TOTAL_BLOCKS);
        // blocks[position].isTreasure = true;
    }

    /**
     * @dev Creates support packages in random blocks.
     */
    function createSupportPackage() external view onlyTreasureHunt {
        for (uint256 i = 0; i < 5; i++) {
           // uint256 position = randoms.getRandomNumberInRange(TOTAL_BLOCKS);
           // blocks[position].isSupportPackage = true;
        }
    }

    // Random Function

    /**
     * @dev Generates a pseudo-random number using block data and a salt.
     * @param salt The salt used for randomness.
     * @return result The generated random number.
     */

    // Block Management

    /**
     * @dev Resets all support packages.
     * @return bool indicating whether the reset was successful.
     */
    function resetSupportBlocks() external onlyTreasureHunt returns (bool) {
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i].isSupportPackage = false;
        }
        return true;
    }

    /**
     * @dev Finishes the game by resetting all blocks.
     * @return bool indicating whether the reset was successful.
     */
    function finishGame() external onlyTreasureHunt returns (bool) {
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i].isTreasure = false;
            blocks[i].isSupportPackage = false;
        }
        return true;
    }

    // Check Functions

    /**
     * @dev Checks if a player is on a support package block.
     * @param _player The address of the player.
     * @return bool indicating whether the player is on a support package block.
     */
    function checkSupportPackage(address _player) public view onlyTreasureHunt returns (bool) {
        return blocks[PlayerIndex(_player)].isSupportPackage;
    }

    /**
     * @dev Checks if a player is on a treasure block.
     * @param _player The address of the player.
     * @return bool indicating whether the player is on a treasure block.
     */
    function checkTreasure(address _player) public view onlyTreasureHunt returns (bool) {
        return blocks[PlayerIndex(_player)].isTreasure;
    }

    // Index Function

    /**
     * @dev Calculates the index of a player based on their 3D coordinates.
     * @param _player The address of the player.
     * @return uint256 The index of the player.
     */

    function PlayerIndex(address _player) public view returns (uint256) {
        (uint x,uint  y, uint z) = playerManager.findPlayer(_player);
        
        uint256 center = uint256(GRID_SIZE / 2); 
        uint256 offsetX = x + center;
        uint256 offsetY = y + center; 
        uint256 offsetZ = z + center; 

        require(
            offsetX >= 0 && offsetX < GRID_SIZE &&
            offsetY >= 0 && offsetY < GRID_SIZE &&
            offsetZ >= 0 && offsetZ < GRID_SIZE,
            "Coordinates out of bounds"
        );  
        
        return uint256(offsetZ) * GRID_SIZE * GRID_SIZE + uint256(offsetY) * GRID_SIZE + uint256(offsetX);
    }

    // Authorized Functions

    /**
     * @dev Sets the Treasure Hunt address.
     * @param _treasureHunt The address of the Treasure Hunt contract.
     */
    function setTreasureHunt(address _treasureHunt) public onlyOwner {
        treasureHuntAddress = _treasureHunt;
    }

    /**
     * @dev Sets a new owner address.
     * @param _newOwner The new owner address.
     */
    function setNewOwner(address _newOwner) public onlyOwner {
        setOwner = _newOwner;
    }

    // Modifiers

    modifier onlyPlayer(address _player) {
        require(playerManager.isPlayer(_player), "You are not a player");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == setOwner, "You are not authorized");
        _;
    }

    modifier onlyTreasureHunt {
        require(msg.sender == treasureHuntAddress, "You are not TreasureHunt address");
        _;
    }
}
