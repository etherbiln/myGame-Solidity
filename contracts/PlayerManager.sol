// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PlayerManager {        
    struct Player {
        bool hasJoined;
        bool hasClue;
        uint x;
        uint y;
        uint stepsCount;
    }

    address[] public playerAddresses;  // Store player addresses in an array
    uint256 public totalPlayers;  // Track total players

    mapping(address => Player) public players;

    event PlayerJoined(address player);
    event PlayerMoved(address player, uint x, uint y);

    // Constructor
    constructor() {}

    // JOIN
    function joinGame(address _player) external {
        require(!players[_player].hasJoined, "Player already joined");
        require(totalPlayers < 30, "Game is full");
        
        players[_player] = Player(true, false, 0, 0, 0);
        playerAddresses.push(_player);
        totalPlayers++;
        
        emit PlayerJoined(_player);
    }
    
    // Show all players
    function showPlayers() public view returns(address[] memory) {
        return playerAddresses;
    }

    // MOVE
    function movePlayer(address _player, string memory _direction) external {
        require(players[_player].hasJoined, "Player not joined");
        require(players[_player].stepsCount < 15, "Player has exceeded max steps!");

        uint256 x = players[_player].x;
        uint256 y = players[_player].y;
        uint256 newx = x;
        uint256 newy = y;

        bytes32 directionHash = keccak256(abi.encodePacked(_direction));

        if (directionHash == keccak256(abi.encodePacked("up"))) {
            newy = y + 1;
        } else if (directionHash == keccak256(abi.encodePacked("down"))) {
            newy = y - 1;
        } else if (directionHash == keccak256(abi.encodePacked("left"))) {
            newx = x - 1;
        } else if (directionHash == keccak256(abi.encodePacked("right"))) {
            newx = x + 1;
        } else {
            revert("Invalid direction");
        }

        // Ensure new coordinates are within bounds
        // require(newx < BlockManager.GRID_SIZE() && newy < BlockManager.GRID_SIZE(), "Out of bounds");

        players[_player].x = newx;
        players[_player].y = newy;
        players[_player].stepsCount++;

        emit PlayerMoved(_player, newx, newy);
    }

    // GET
    function getTotalPlayers() public view returns (uint256) {
        return totalPlayers;
    }
    
    function findLocation(address _player) public view returns (uint256 x, uint256 y) {
        Player memory player = players[_player];
        require(player.hasJoined, "Player has not joined the game");

        x = player.x;
        y = player.y;
    }
}
