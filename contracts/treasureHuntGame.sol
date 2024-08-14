// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TreasureHuntGame is Ownable {
    address ownerGameAddress = 0xAC0775EA1214Dd83c9e9951e6C476605d11ECEF6;
    MyToken public token;
    
    uint8 tokenDecimals = 18;
    
    uint256 public constant GRID_SIZE = 32;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE * GRID_SIZE;

    uint256 public totalBalance;
    uint256 public clueCost;
    uint256 public supportPackageBlocks;
    uint256 public totalPlayers;
    uint256 public gameStartTime;
    uint256 public gameDuration;

    struct Block {
        bool isTreasure;
        bool isSupportPackage;
    }

    struct Player {
        bool hasJoined;
        bool hasClue;
        uint x;
        uint y;
        uint stepsCount;
    }

    mapping (uint256 => Block) public blocks;
    mapping (address => Player) public players;

    address[] public playerAddresses;

    event GameStarted(uint256 startTime);
    event PlayerJoined(address player);
    event PlayerMoved(address player, uint x, uint y);
    event CluePurchased(address player);

    constructor(address _tokenAddress, uint256 _clueCost, uint256 _supportPackageBlocks, uint256 _gameDuration)Ownable(msg.sender) {
        token = MyToken(_tokenAddress);
        clueCost = _clueCost;
        supportPackageBlocks = _supportPackageBlocks;
        gameDuration = _gameDuration;
        
        // Initialize blocks with default values if necessary
        for (uint256 i = 0; i < TOTAL_BLOCKS; i++) {
            blocks[i] = Block(false, false);
        }
    }

    function joinGame() external {
        require(!players[msg.sender].hasJoined, "Player already joined");
        require(totalPlayers < 30, "Game is full");
        
        players[msg.sender] = Player(true, false, 0, 0, 0);
        playerAddresses.push(msg.sender);
        totalPlayers++;
        emit PlayerJoined(msg.sender);
    }

    function startGame() external onlyOwner {
        require(gameStartTime == 0, "Game already started");
        gameStartTime = block.timestamp;
        emit GameStarted(gameStartTime);
    }   

    function testDirection(string memory _direction) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_direction));
    }

    function movePlayer(string memory _direction) public onlyDuringGame onlyPlayer {
        require(players[msg.sender].stepsCount < 15, "Player has exceeded max steps!");

        uint256 x = players[msg.sender].x;
        uint256 y = players[msg.sender].y;
        uint256 newx = x;
        uint256 newy = y;

        bytes32 directionHash = keccak256(abi.encodePacked(_direction));

        bytes32 up = keccak256(abi.encodePacked("up"));
        bytes32 down = keccak256(abi.encodePacked("down"));
        bytes32 left = keccak256(abi.encodePacked("left"));
        bytes32 right = keccak256(abi.encodePacked("right"));

        if (directionHash == up) {
            newy = y + 1;
        } else if (directionHash == down) {
            newy = y - 1;
        } else if (directionHash == left) {
            newx = x - 1;
        } else if (directionHash == right) {
            newx = x + 1;
        } else {
            revert("Invalid direction");
        }
        require(newx < GRID_SIZE && newy < GRID_SIZE, "Out of bounds");

        if (blocks[newx * GRID_SIZE + newy].isTreasure) {
            revert("Player found treasure");
        } else if (blocks[newx * GRID_SIZE + newy].isSupportPackage) {
            revert("Player found support package");
        } else {
            players[msg.sender].x = newx;
            players[msg.sender].y = newy;
            players[msg.sender].stepsCount++;
            emit PlayerMoved(msg.sender, newx, newy);
        }
    }
    
    function findLocation() public view returns (uint256 x, uint256 y) {
        Player memory player = players[msg.sender];
        require(player.hasJoined, "Player has not joined the game");

        x = player.x;
        y = player.y;
    }

    function buyClue() external onlyDuringGame onlyPlayer {
        require(!players[msg.sender].hasClue, "Player already has a clue");

    // Update state variable before external call
        players[msg.sender].hasClue = true;

    // Perform the external call after state update
        require(token.transferFrom(msg.sender, ownerGameAddress, clueCost), "Clue purchase failed");

        emit CluePurchased(msg.sender);
   }

     modifier onlyDuringGame() {
        require(block.timestamp <= gameStartTime + gameDuration, "Game is over");
        _;
    }

    modifier onlyPlayer() {
        require(players[msg.sender].hasJoined, "Player not joined");
        _;
    }
}
