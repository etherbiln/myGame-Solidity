// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PlayerManager.sol";
import "./BlockManager.sol";
import "./TokenManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TreasureHuntGame is Ownable {
    PlayerManager public playerManager;
    BlockManager public blockManager;
    TokenManager public tokenManager;

    uint256 public totalPlayers;
    uint256 public gameStartTime;
    uint256 public gameDuration;

    address public authorizedAddress = msg.sender;  // New variable to store the authorized address

    event GameStarted(uint256 startTime);

    constructor(address _tokenAddress, uint256 _clueCost, uint256 _gameDuration) Ownable(authorizedAddress) { // need change wen deploy
        playerManager = new PlayerManager();
        blockManager = new BlockManager();
        tokenManager = new TokenManager(_tokenAddress, _clueCost);
        
        gameDuration = _gameDuration;
    }

    function joinGame() external {
        playerManager.joinGame(msg.sender);
        totalPlayers++;
    }

    function startGame() external onlyAuthorized {
        require(gameStartTime == 0, "Game already started");
        gameStartTime = block.timestamp;
        emit GameStarted(gameStartTime);
    }

    function movePlayer(string memory _direction) external  onlyDuringGame {
        playerManager.movePlayer(msg.sender, _direction, blockManager);
    }

    function buyClue() external onlyDuringGame {
        playerManager.buyClue();
    }

    // CHECK
    function checkTreasure() public view {
        require(blockManager.checkTreasure(), "No treasure at this location");
    }

    function checkSupportPackage() public view {
        require(blockManager.checkSupportPackage(), "No support package at this location");
    }
    
    function findLocation() public view returns (uint256 x, uint256 y) {
        (x, y) = playerManager.findLocation(msg.sender);
        return (x, y);
    }

    // CLAIMS
    
    function claimSupportPackage(address _player) public {
        tokenManager.claimSupportPackage(_player);
    }
    
    function claimTreasure(address _player) public {
        tokenManager.claimTreasure(_player); 
    }
    
    /// GET

    function getTotalPlayers() public view returns (uint256) {
        return playerManager.getTotalPlayers();
    }

    /// SET

    function setPlayerManager(address _playerManager) external onlyOwner {
        playerManager = PlayerManager(_playerManager);
    }

    function setBlockManager(address _blockManager) external onlyOwner {
        blockManager = BlockManager(_blockManager);
    }

    function setTokenManager(address _tokenManager) external onlyOwner {
        tokenManager = TokenManager(_tokenManager);
    }

    function setAuthorizedAddress(address _authorizedAddress) external onlyOwner {
        authorizedAddress = _authorizedAddress;
    }

    /// MODIFIER

    modifier onlyDuringGame() {
        require(block.timestamp <= gameStartTime + gameDuration, "Game is over");
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == authorizedAddress, "Not authorized");
        _;
    }
}
