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

    uint256 public gameStartTime;
    uint256 public gameDuration = 10000; // end

    address public authorizedAddress = msg.sender;  // New variable to store the authorized address

    event GameStarted(uint256 startTime);

    // Constructor
    constructor() Ownable(authorizedAddress) {
        playerManager = new PlayerManager();
        blockManager = new BlockManager();
        tokenManager = new TokenManager(playerManager,blockManager);
    }

    function joinGame() external {
        playerManager.joinGame(msg.sender);
    }

    function startGame() external onlyAuthorized {
        require(gameStartTime == 0, "Game already started");
        gameStartTime = block.timestamp;
        emit GameStarted(gameStartTime);
    }

    function movePlayer(string memory _direction) external  onlyDuringGame {
        playerManager.movePlayer(msg.sender, _direction);
    }

    // function buyClue() external onlyDuringGame {
    //     tokenManager.buyClue();
    // }

    // CHECK
    
    function findLocation(address _player) public view returns (uint256 x, uint256 y) {
        (x, y) = playerManager.findLocation(_player);
        return (x, y);
    }

    function checkSupportPackage() public  view returns(bool) {
        return blockManager.checkSupportPackage();
    
    }
    
    function checkTreasure() public view returns(bool) {
        return blockManager.checkTreasure();
    }

    // --- 

    // CLAIMS
    function claimSupportPackage(address _player) external {
        require(checkSupportPackage());
        tokenManager.claimSupportPackage(_player);
    }
    
    function claimTreasure(address _player) external {
        require(checkTreasure());
        tokenManager.claimTreasure(_player); 
    }
    
    /// GET

    function getTotalPlayers() public view returns (uint256) {
        return playerManager.getTotalPlayers();
    }

    function getShowPlayer() public view returns(address[] memory) {
        return playerManager.showPlayers();
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