// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PlayerManager.sol";

contract BlockManager {
    PlayerManager public playerManager;
    
    uint256 public constant GRID_SIZE = 10;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE * GRID_SIZE;

    address public setOwner= 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public treasureHuntAddress;
    
    struct Block {
        bool isTreasure;
        bool isSupportPackage;
    }

    mapping(uint256 => Block) private blocks;

    // Constructor
    constructor(address _playerManager) {
        playerManager = PlayerManager(_playerManager);

        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i] = Block(false, false);
        }
    }

    // Create
    function createTreasure() external onlyTreasureHunt {
        for (uint256 i = 0; i < 1; i++) {
            uint256 position;

            do {
                position = random(i) % TOTAL_BLOCKS;
            } while (blocks[position].isTreasure);

            blocks[position].isTreasure = true;
        }
    }

    function createSupportPackage() external onlyTreasureHunt {
        for (uint256 i = 0; i < 15; i++) {
            uint256 position;

            do {
                position = random(i + 1) % TOTAL_BLOCKS;
            } while (blocks[position].isSupportPackage);

            blocks[position].isSupportPackage = true;
        }
    }
    // Random
    function random(uint256 salt) private view returns (uint256 result) {
        result = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            blockhash(block.number - 1),
            msg.sender,
            salt
        )));
    }
    // Blocks
    function resetSupportBlocks() external onlyTreasureHunt returns(bool) { // wen use need creates
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i].isSupportPackage = false;
        }
        return true;
    }

    function finishGame() external onlyTreasureHunt returns (bool) {
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i].isTreasure = false;
            blocks[i].isSupportPackage = false;
        }
        return true;
    }

    // Check
    function checkSupportPackage(address _player) public onlyTreasureHunt view  returns (bool) {
        return blocks[PlayerIndex(_player)].isSupportPackage;
    }

    function checkTreasure(address _player) public onlyTreasureHunt view returns (bool)  {
        return blocks[PlayerIndex(_player)].isTreasure;
    }

    // Index
    function PlayerIndex(address _player) public view returns (uint256) {
        (uint256 playerX, uint256 playerY) = playerManager.findPlayer(_player);
        return playerX * GRID_SIZE + playerY;
    }
    
    // New authorized
    function setTreasureHunt(address _treasureHunt) public onlyOwner {
        treasureHuntAddress = _treasureHunt;
    }
    
    function setNewOwner(address _newOwner) public onlyOwner {
        setOwner = _newOwner;
    }

    // Modifier
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
