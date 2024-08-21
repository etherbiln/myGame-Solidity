// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PlayerManager.sol";

contract BlockManager {
    PlayerManager public playerManager;     
    uint256 public constant GRID_SIZE = 7;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE * GRID_SIZE;
    address public authorizedAddress = 0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d;

    struct Block {
        bool isTreasure;
        bool isSupportPackage;
    }

    mapping(uint256 => Block) public blocks;

    // Constructor
    constructor(address _playerManager) {
        playerManager = PlayerManager(_playerManager);

        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i] = Block(false, false);
        }

        // Create treasures and Support Packages at random locations
        createTreasure();
        createSupportPackage();
    }

    // CREATE Chainlink or other randomness can be added for secure random number generation
    function createTreasure() internal onlyAuthorized {
        for (uint256 i = 0; i < 5; i++) {
            uint256 position;

            do {
                position = random(i) % TOTAL_BLOCKS;
            } while (blocks[position].isTreasure);

            blocks[position].isTreasure = true;
        }
    }

    function createSupportPackage() internal  onlyAuthorized{
        for (uint256 i = 0; i < 10; i++) {
            uint256 position;

            do {
                position = random(i + 1) % TOTAL_BLOCKS;
            } while (blocks[position].isSupportPackage); 

            blocks[position].isSupportPackage = true;
        }
    }

    function random(uint256 salt) private onlyAuthorized view returns (uint256 result) {
        assembly {
            let data := mload(0x40)
            mstore(data, timestamp())
            mstore(add(data, 0x20), prevrandao())
            mstore(add(data, 0x40), caller())
            mstore(add(data, 0x60), salt)

            result := keccak256(data, 0x80)
        }
    }
    
    function resetGame() internal  onlyAuthorized returns(bool) {
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            if (blocks[i].isTreasure) {
                blocks[i].isTreasure = false;
            }
            if (blocks[i].isSupportPackage) {
                blocks[i].isSupportPackage = false;
            }
        }
        return true;
    }

    function finishGame() external onlyAuthorized returns (bool) {
        require(playerManager.finishGame(),"Error for Finis game!"); 
        for (uint256 i = 0; i <10; i++) {
            if ((blocks[i].isTreasure == true)) {
                blocks[i].isTreasure = false;
            }
            if (blocks[i].isSupportPackage) {
                blocks[i].isSupportPackage = false;
            }
        }
        return true;
    }

    // CHECK
    function checkSupportPackage(address _player) public onlyPlayer(_player) view returns (bool) {
        return blocks[PlayerIndex(_player)].isSupportPackage;        
    }

    function checkTreasure(address _player) public onlyPlayer(_player) view returns (bool)  {
        return blocks[PlayerIndex(_player)].isTreasure;
    }

    // GET
    function PlayerIndex(address _player) public view returns (uint256) {
        (uint256 playerX, uint256 playerY) = playerManager.findPlayer(_player);
        return playerX * GRID_SIZE + playerY;
    }

    function getPlayerBlockIndex() public view returns (Block memory) {
        (uint256 playerX, uint256 playerY) = playerManager.findPlayer(msg.sender);
        uint256 blockIndex = playerX * GRID_SIZE + playerY;
        return blocks[blockIndex];
    }

    function getPlayerBlockIndex(uint256 x, uint256 y) public view returns (Block memory) {
        uint256 blockIndex = x * GRID_SIZE + y;
        return blocks[blockIndex];
    }

    modifier onlyPlayer(address _player) {
        require(msg.sender == _player);
        (bool a,uint b) = playerManager.isPlayer(_player);
        require(a);
        _;
    }
    modifier onlyAuthorized{
        require (msg.sender == authorizedAddress);
        _;
    }
}
