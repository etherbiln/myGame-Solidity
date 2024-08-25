// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PlayerManager {
    uint256 public constant GRID_SIZE = 10;

    struct Player {
        bool hasJoined;
        uint256 paid;
        uint x;
        uint y;
        uint stepsCount;
    }

    address[] public playerAddresses;
    uint256 public totalPlayers;

    address public treasureHuntAddress;
    address public setOwner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    mapping(address => Player) public players;
    mapping(address => bool) private playerExists;

    event PlayerJoined(address player);
    event PlayerLeave(address player);
    event PlayerMoved(address player, uint x, uint y);
    event GameStarted(uint256 startTime);

    // Constructor
    constructor() {}

    // JOIN
    function joinGame(address _player,uint256 _amount) external onlyTreasureHunt returns(bool) {
        require(!players[_player].hasJoined, "Player already joined");
        require(totalPlayers < 30, "Game is full");
        
        players[_player] = Player(true,0, 0, 0, 0);
        playerAddresses.push(_player);
        playerExists[_player] = true;
        totalPlayers++;

        players[_player].paid = _amount;
        
        emit PlayerJoined(_player);

        return true;
    }

    function leaveGame(address _player) public onlyPlayer(_player) returns (bool) {
        require(players[_player].hasJoined, "Player does not exist");
        require(totalPlayers > 0, "No players in the game");

        uint256 index = PlayerNumber(_player);
        
        playerAddresses[index] = playerAddresses[playerAddresses.length - 1];
        playerAddresses.pop();
        
        delete players[_player];
        delete playerExists[_player];
        totalPlayers--;

        emit PlayerLeave(_player);
        return true;
    }

    function finishGame() external onlyTreasureHunt returns (bool) {
        require(totalPlayers > 0, "No players in the game");
        
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            address player = playerAddresses[i];
            delete players[player];
            delete playerExists[player];
        }

        delete playerAddresses;
        totalPlayers = 0;

        return true;
    }

    function movePlayer(address _player, string memory _direction) external onlyTreasureHunt returns(bool) {
        require(players[_player].hasJoined, "Player not joined");
        require(players[_player].stepsCount < 100, "Player has exceeded max steps!");

        uint256 x = players[_player].x;
        uint256 y = players[_player].y;
        uint256 newx = x;
        uint256 newy = y;

        bytes32 directionHash = keccak256(abi.encodePacked(_direction));

        if (directionHash == keccak256(abi.encodePacked("up"))) {
            require((y + 1) <= GRID_SIZE, "Out of bounds");
            newy = y + 1;
        } else if (directionHash == keccak256(abi.encodePacked("down"))) {
            require(y >= 1, "Out of bounds");
            newy = y - 1;
        } else if (directionHash == keccak256(abi.encodePacked("left"))) {
            require(x >= 1, "Out of bounds");
            newx = x - 1;
        } else if (directionHash == keccak256(abi.encodePacked("right"))) {
            require((x + 1) <= GRID_SIZE, "Out of bounds");
            newx = x + 1;
        } else {
            revert("Invalid direction");
        }

        players[_player].x = newx;
        players[_player].y = newy;
        players[_player].stepsCount++;

        emit PlayerMoved(_player, newx, newy);
        return true;
    }
    
    // Player
    function showPlayers() public view returns(address[] memory) {
        return playerAddresses;
    }

    function isPlayer(address _player) public view returns(bool) {
        return playerExists[_player];
    }
    
    function PlayerNumber(address _player) public onlyPlayer(_player) view returns(uint256) {
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            if (playerAddresses[i] == _player) {
                return i;
            }
        }
        revert("Player not found");
    }

    function findPlayer(address _player) public onlyPlayer(_player) view returns (uint256 x, uint256 y) {
        Player memory player = players[_player];
        require(player.hasJoined, "Player has not joined the game");
        return (player.x, player.y);
    }

    function getTotalPlayers() public view returns(uint256) {
        return totalPlayers;
    }
    
    // New authorized
    function setTreasureHunt(address _treasureHunt) public onlyOwner {
        treasureHuntAddress = _treasureHunt;
    }
    
    function setNewOwner(address _newOwner) public onlyOwner {
        setOwner = _newOwner;
    }

    // Modifier
    modifier onlyOwner {
        require(msg.sender == setOwner, "You are not authorized");
        _;
    }
    
    modifier onlyTreasureHunt {
        require(msg.sender == treasureHuntAddress, "You are not TreasureHunt address");
        _;
    }
    
    modifier onlyPlayer(address _player) {
        require(playerExists[_player], "You are not a player");
        _;
    }

    modifier onlyFirst(address _player) {
        require(playerAddresses.length > 0 && playerAddresses[0] == _player, "You are not the first player");
        _;
    }
}
