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

    address[]  public playerAddresses;
    uint256 public totalPlayers; 
    uint256 public constant GRID_SIZE = 7;
    address public authorizedAddress = 0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d;


    mapping(address => Player) public players;

    event PlayerJoined(address player);
    event PlayerLeave(address player);
    event PlayerMoved(address player, uint x, uint y);

    // Constructor
    constructor() {}

    // JOIN
    function joinGame(address _player) external onlyPlayer(_player) returns(bool) {
        require(!players[_player].hasJoined, "Player already joined");
        require(totalPlayers < 30, "Game is full");
        
        players[_player] = Player(true, false, 0, 0, 0);
        playerAddresses.push(_player);
        totalPlayers++;
        
        emit PlayerJoined(_player);
        return true;
    }
    function leaveGame(address _player) public onlyPlayer(_player) returns (bool) {
        require(players[_player].hasJoined, "Player does not exist");
        require(totalPlayers > 0, "No players in the game");

        (bool playerFound,uint256 index) = isPlayer(_player);
        require(playerFound, "Player not found in the array");

        playerAddresses[index] = playerAddresses[playerAddresses.length - 1];
        playerAddresses.pop();

        players[_player] = Player(false, false, 0, 0, 0);
        totalPlayers--;

        emit PlayerLeave(_player);
        return true;
    }

   function finishGame() external onlyAuthorized returns (bool) {
        require(totalPlayers > 0, "No players in the game");
        
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            address player = playerAddresses[i];
            players[player] = Player(false, false, 0, 0, 0);
        }

        delete playerAddresses;
        totalPlayers = 0;

        return true;
    }

    // MOVE
    function movePlayer(address _player, string memory _direction) external onlyPlayer(_player)  returns(bool) {
        require(players[_player].hasJoined, "Player not joined");
        require(players[_player].stepsCount < 15, "Player has exceeded max steps!");

        uint256 x = players[_player].x;
        uint256 y = players[_player].y;
        uint256 newx = x;
        uint256 newy = y;
        

        bytes32 directionHash = keccak256(abi.encodePacked(_direction));

        if (directionHash == keccak256(abi.encodePacked("up"))) {
            require((newy = y + 1) <=  7, "Out of bounds");
        } else if (directionHash == keccak256(abi.encodePacked("down"))) {
            require((newy = y - 1) >= 0, "Out of bounds");
        } else if (directionHash == keccak256(abi.encodePacked("left"))) {
            require((newx = x - 1) >= 0, "Out of bounds");
        } else if (directionHash == keccak256(abi.encodePacked("right"))) {
            require((newx = x + 1) <= 7, "Out of bounds");
        } else {
            revert("Invalid direction");
        }

        // Ensure new coordinates are within bounds
        players[_player].x = newx;
        players[_player].y = newy;
        players[_player].stepsCount++;

        emit PlayerMoved(_player, newx, newy);
        return true;
    }
    
    // Players
    function showPlayers() public view returns(address[] memory,uint256) {
        return (playerAddresses,totalPlayers);
    }

    function isPlayer(address _player) public view returns(bool,uint256) {
        uint256 index;
        bool playerFound = false;
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            if (playerAddresses[i] == _player) {
                index = i;
                playerFound = true;
                break;
            }
        }
        return (playerFound,index);
    }
    function findPlayer(address _player) public view returns (uint256 x, uint256 y) {
        Player memory player = players[_player];
        require(player.hasJoined, "Player has not joined the game");

        x = player.x;
        y = player.y;
    }

     modifier onlyAuthorized{
        require (msg.sender == authorizedAddress);
        _;
    }
    
    modifier onlyPlayer(address _player) {
        require(msg.sender == _player);
        (bool a,uint b) = isPlayer(_player);
        require(a);
        _;
    }
}
