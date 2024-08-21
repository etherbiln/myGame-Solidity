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
    uint256 public gameDuration = 900; // 15 minutes
    address public authorizedAddress = 0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d;

    event GameStarted(uint256 startTime);
    event PlayerJoined(address indexed player);
    event PlayerLeave(address indexed player);
    event PlayerMoved(address indexed player, string direction);
    event SupportPackageClaimed(address indexed player);
    event TreasureClaimed(address indexed player);

    // Constructor
    constructor(address _playerManager, address _blockManager, address _tokenManager, address _token) Ownable(authorizedAddress) {
        playerManager = PlayerManager(_playerManager);
        blockManager = BlockManager(_blockManager);
        tokenManager = TokenManager(_tokenManager);
        token = MyToken(_token);
    }

    // Game
    function joinGame(address _player) external onlySender(_player) {
        require(playerManager.joinGame(_player));
        emit PlayerJoined(_player);
    }

    function leaveGame(address _player) external onlyPlayer(_player) {
        playerManager.leaveGame(_player);

        emit PlayerLeave(_player);
    }
    function startGame() external onlyFirst(msg.sender) {
        require(gameStartTime == 0, "Game already started");
        gameStartTime = block.timestamp;
        emit GameStarted(gameStartTime);
    }
    function finishGame() external onlyAuthorized returns(bool) {
        require(getElapsedTime() >= gameDuration);
        require(blockManager.finishGame());
        
        gameStartTime =0;
        return true;
    }

    // Move 
    function movePlayer(address _player, string memory _direction) external onlyPlayer(_player) onlyDuringGame {
        require(playerManager.movePlayer(_player, _direction));
        emit PlayerMoved(_player, _direction);
    }

    // Check
    function checkSupportPackage(address _player) public onlyPlayer(_player) view returns (bool) {
        return blockManager.checkSupportPackage(_player);
    }

    function checkTreasure(address _player) public onlyPlayer(_player) view returns (bool) {
        return blockManager.checkTreasure(_player);
    }

    // Claims
    function claimSupportPackage(address _player) external onlyPlayer(_player) {
        require(blockManager.checkSupportPackage(_player));
        tokenManager.claimSupportPackage(_player);
        emit SupportPackageClaimed(_player);
    }

    function claimTreasure(address _player) external onlyPlayer(_player) {
        require(blockManager.checkTreasure(_player));
        tokenManager.claimTreasure(_player);
        emit TreasureClaimed(_player);
    }

    // Get
    function isPlayer(address _player) external view returns(bool,uint256) {
       return  playerManager.isPlayer(_player);
    }

    function ShowPlayers() public view returns (address[] memory,uint256) {
        return playerManager.showPlayers();
    }

    function findPlayer(address _player) public view returns (uint256 x, uint256 y) {
        (x, y) = playerManager.findPlayer(_player);
        return (x, y);
    }

    function getElapsedTime() public view returns (uint256) {
        if (gameStartTime == 0) {
            return 0;
        }
        return block.timestamp - gameStartTime;
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

    modifier onlyPlayer(address _player) {
        (bool a,uint b) = playerManager.isPlayer(_player);
        require(a);
        _;
    }

    modifier onlyFirst(address _player) {
        require(playerManager.playerAddresses(0) == _player, "Not the first player");
        _;
    }
}
