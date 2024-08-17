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
    MyToken public token;

    uint256 public gameStartTime;
    uint256 public gameDuration = 10000; // end
    address public authorizedAddress = msg.sender;  // New variable to store the authorized address

    event GameStarted(uint256 startTime);
    event PlayerJoined(address indexed player);
    event PlayerMoved(address indexed player, string direction);
    event SupportPackageClaimed(address indexed player);
    event TreasureClaimed(address indexed player);

    // Constructor
    constructor() Ownable(authorizedAddress) {
        playerManager = new PlayerManager();
        blockManager = new BlockManager(address(playerManager));
        tokenManager = new TokenManager(playerManager, blockManager);
    }

    // Game
    function joinGame(address _player) external onlySender(_player) {
        playerManager.joinGame(_player);
        emit PlayerJoined(_player);
    }

    function startGame() external onlyAuthorized {
        require(gameStartTime == 0, "Game already started");
        gameStartTime = block.timestamp;
        emit GameStarted(gameStartTime);
    }

    function movePlayer(address _player, string memory _direction) external onlySender(_player) onlyDuringGame {
        playerManager.movePlayer(_player, _direction);
        emit PlayerMoved(_player, _direction);
    }

    // Check
    function checkSupportPackage(address _player) public onlySender(_player) view returns (bool) {
        return blockManager.checkSupportPackage(_player);
    }

    function checkTreasure(address _player) public onlySender(_player) view returns (bool) {
        return blockManager.checkTreasure(_player);
    }

    // Claims
    function claimSupportPackage(address _player) external onlySender(_player) {
        require(blockManager.checkSupportPackage(_player));
        tokenManager.claimSupportPackage(_player);
        emit SupportPackageClaimed(_player);
    }

    function claimTreasure(address _player) external onlySender(_player) {
        require(blockManager.checkTreasure(_player));
        tokenManager.claimTreasure(_player);
        emit TreasureClaimed(_player);
    }

    // Get
    function getTotalPlayers() public view returns (uint256) {
        return playerManager.getTotalPlayers();
    }

    function getShowPlayer() public view returns (address[] memory) {
        return playerManager.showPlayers();
    }

    function findLocation(address _player) public view returns (uint256 x, uint256 y) {
        (x, y) = playerManager.findLocation(_player);
        return (x, y);
    }

    // Modifiers
    modifier onlyDuringGame() {
        require(block.timestamp <= gameStartTime + gameDuration, "Game is over");
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == authorizedAddress, "Not authorized");
        _;
    }

    modifier onlySender(address _player) {
        require(_player == msg.sender, "Sender is not the player");
        _;
    }
}
