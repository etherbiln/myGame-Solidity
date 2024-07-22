// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TreasureHuntGame{
    address ownerGameAddress = 0xAC0775EA1214Dd83c9e9951e6C476605d11ECEF6;
    
    uint256 public constant GRID_SIZE = 32;
    uint256 public constant TOTAL_BLOCKS = GRID_SIZE*GRID_SIZE;
    uint8 tokenDecimals = 18;
    MyToken public token;

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

    mapping (uint256  => Block) public blocks;
    mapping (address => Player) public players;

    address[] public  playerAddresses;

    uint256 totalBalance;
    uint256 public clueCost;
    uint256 public supportPackageBlocks;
    uint256 public totalPlayers; //
    uint256 public gameStartTime;
    uint256 public gameDuration;

    constructor(address _tokenAddress, uint256 _clueCost, uint256 _supportPackageBlocks, uint256 _gameDuration) {
        token = MyToken(_tokenAddress);
        clueCost = _clueCost;
        supportPackageBlocks = _supportPackageBlocks;
        gameDuration = _gameDuration;
    }

    function joinGame() external {
        require(!players[msg.sender].hasJoined, "Player already joined");
        require(totalPlayers < 30, "Game is full");
        
        players[msg.sender] = Player(true,false,0,0,0);
        playerAddresses.push(msg.sender);
        totalPlayers++;
    }

    function startGame() external {
        //require(totalPlayers == 30,"Not enough players to start!");
        require(gameStartTime == 0,"Game already started");
        gameStartTime = block.timestamp;

    }   

    function testDirection(string memory _direction) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_direction));
    }

    function movePlayer(string memory _direction) public {
        require(players[msg.sender].hasJoined,"Player not Joined!");
        require(players[msg.sender].stepsCount < 15, "Player has exceeded max steps!");
        require(block.timestamp >= gameStartTime + gameDuration,"Game is over");
       
        uint256 x = players[msg.sender].x;
        uint256 y = players[msg.sender].y; 
        uint256 newx = x;
        uint256 newy = y; 
       
       
        if(keccak256(abi.encodePacked(_direction)) == testDirection("up")){
            newy = y + 1;  
        }else if(keccak256(abi.encodePacked(_direction)) == testDirection("down")){
            newy = y - 1;  
        }else if(keccak256(abi.encodePacked(_direction)) == testDirection("left")){
            newx = x - 1;  
        }else if(keccak256(abi.encodePacked(_direction)) == testDirection("right")){
            newx = x + 1;  
        }else{
            revert("Invalid direction");
        } 

        // oyun mantığı düzenlemek gerek        
        if(newx >= GRID_SIZE || newy >= GRID_SIZE){
            revert("Out of bounds");
        }else if(blocks[newx*GRID_SIZE+newy].isTreasure){
            revert("Player found treasure");
        }else if(blocks[newx*GRID_SIZE+newy].isSupportPackage){
            revert("Player found support package");
        }else{
            players[msg.sender].x = newx;
            players[msg.sender].y = newy;
            players[msg.sender].stepsCount++;
        }
    }
    
    function findLocation() public view returns (uint256 x, uint256 y) {
        Player memory player = players[msg.sender];

        require(player.hasJoined, "Player has not joined the game");

        x = player.x;
        y = player.y;
    }

    function buyClue() external onlyDuringGame onlyPlayer {
        require(token.transferFrom(msg.sender, ownerGameAddress, clueCost), "Clue purchase failed");
        players[msg.sender].hasClue = true;
    }

    function getClue() public view onlyPlayer {
        require(players[msg.sender].hasClue, "Player does not have a clue");
        // Implement logic to provide a clue location
        // Example: Provide the location of the nearest treasure or support package
    }

    function findSupportPackage() external view onlyPlayer returns (string memory) {
        Player memory player = players[msg.sender];
        uint256 x = player.x;
        uint256 y = player.y;
        Block memory currentBlock = blocks[x + y * GRID_SIZE];
        if (currentBlock.isSupportPackage) {
            return "Support Package Found!";
        }
        return "No Support Package Here.";
    }

    function findTreasure() external onlyPlayer {
        Player memory player = players[msg.sender];

        uint256 x = player.x;
        uint256 y = player.y;

        Block memory currentBlock = blocks[x + y * GRID_SIZE];
        
        if (currentBlock.isTreasure) {
            uint256 treasureReward = 1000 * 10 ** tokenDecimals;
            require(token.transfer(msg.sender, treasureReward), "Treasure reward transfer failed");
            players[msg.sender].stepsCount = 101; // 101 adımda çıkış yapılır ve puan
        }
    }
    

    function getGameStatus() external view returns (string memory) {
        if (gameStartTime == 0) {
            return "Game has not started yet.";
        } else if (block.timestamp >= gameStartTime + gameDuration) {
            return "Game is in progress.";
        } else {
            return "Game is in Over.";
        }
    }

    function determineWinner() internal view returns (address) {
        address winner;
        uint256 maxSteps = 0;
        for (uint i = 0; i < playerAddresses.length; i++) {
            address playerAddress = playerAddresses[i];
            if (players[playerAddress].stepsCount > maxSteps) {
                maxSteps = players[playerAddress].stepsCount;
                winner = playerAddress;
            }
        }
        return winner;
    }
    function winnerAddress() public view returns(address){
        address winAddress = determineWinner();
        return winAddress;
    }

    modifier JoinedGame {
        require(!players[msg.sender].hasJoined, "Player already joined!");
        _;
    }

    modifier onlyDuringGame() {
        require(gameStartTime > 0 && block.timestamp < gameStartTime + gameDuration, "Game is not active");
        _;
    }

    modifier onlyPlayer() {
        require(players[msg.sender].hasJoined, "Player not joined");
        _;
    }
}