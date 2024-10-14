// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PlayerManager.sol";

/**
 * @title BlockManager
 * @dev Manages blocks for the Treasure Hunt game, including creating treasures and support packages.
 */
contract BlockManager {
    PlayerManager public playerManager;

    uint256 public constant GRID_SIZE = 10;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE * GRID_SIZE;
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
    function createTreasure() external onlyTreasureHunt {
        for (uint256 i = 0; i < 1; i++) {
            uint256 position;
            do {
                position = random(i) % TOTAL_BLOCKS;
            } while (blocks[position].isTreasure);
            blocks[position].isTreasure = true;
        }
    }

    /**
     * @dev Creates support packages in random blocks.
     */
    function createSupportPackage() external onlyTreasureHunt {
        for (uint256 i = 0; i < 15; i++) {
            uint256 position;
            do {
                position = random(i + 1) % TOTAL_BLOCKS;
            } while (blocks[position].isSupportPackage);
            blocks[position].isSupportPackage = true;
        }
    }

    // Random Function

    /**
     * @dev Generates a pseudo-random number using block data and a salt.
     * @param salt The salt used for randomness.
     * @return result The generated random number.
     */
    function random(uint256 salt) private view returns (uint256 result) {
        result = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            blockhash(block.number - 1),
            msg.sender,
            salt
        )));
    }

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
     * @dev Calculates the index of a player based on their coordinates.
     * @param _player The address of the player.
     * @return uint256 The index of the player.
     */
    function PlayerIndex(address _player) public view returns (uint256) {
        (uint256 playerX, uint256 playerY) = playerManager.findPlayer(_player);
        return playerX * GRID_SIZE + playerY;
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
