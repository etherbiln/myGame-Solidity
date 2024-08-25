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

    uint256 public constant movePrice  = 250*10**18;
    uint256 public constant minJoinAmount= 200*10**18;
    uint256 public gameDuration = 900; // 15 minutes
    uint256 public gameStartTime;
    uint256 public gamePrice;

    address public authorizedAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public gameAddress = 0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d; // for tokens

    event GameStarted(uint256 startTime);
    event PlayerJoined(address indexed player);
    event PlayerLeft(address indexed player);
    event PlayerMoved(address indexed player, string direction);
    event SupportPackageClaimed(address indexed player);
    event TreasureClaimed(address indexed player);

    // Constructor
    constructor(
        address _playerManager,
        address _blockManager,
        address _tokenManager,
        address _token
    ) Ownable(authorizedAddress) {
        playerManager = PlayerManager(_playerManager);
        blockManager = BlockManager(_blockManager);
        tokenManager = TokenManager(_tokenManager);
        token = MyToken(_token);
    }

    // Game
    function joinGame(address _player, uint256 _amount) external returns (bool) {
        require(_player != address(0), "Invalid player address");
        require(_amount >= minJoinAmount,"Need more amount! min : 200 18decimal");

        if (playerManager.totalPlayers() == 0) {
            gamePrice = _amount;
        } else {
            require(_amount >= gamePrice, "Not enough amount!");
        }

        require(token.balanceOf(_player) >= gamePrice, "Not enough tokens!");
        require(token.approve(address(this), gamePrice), "Approval failed");

        uint256 allowedAmount = token.allowance(_player, address(this));
        require(allowedAmount >= gamePrice, "Not enough allowance for transfer");

        require(token.transferFrom(_player, gameAddress, gamePrice), "Token transfer failed");

        require(playerManager.joinGame(_player, gamePrice));
        
        emit PlayerJoined(_player);

        return true;
    }

    function leaveGame(address _player) external onlyPlayer(_player) {
        require(playerManager.leaveGame(_player), "Player leave failed");
    
        uint256 refundAmount = gamePrice / 2;
        require(token.balanceOf(address(this)) >= refundAmount, "Not enough tokens in contract");
        require(token.transfer(_player, refundAmount), "Token transfer failed");

        emit PlayerLeft(_player);
    }

    function startGame() external onlyFirst(msg.sender) {
        require(playerManager.totalPlayers() > 1, "Not enough players!");
        require(gameStartTime == 0, "Game already started");
        gameStartTime = block.timestamp;
        
        blockManager.createSupportPackage();
        blockManager.createTreasure();

        emit GameStarted(gameStartTime);
    }

    function finishGame() external onlyAuthorized returns (bool) {
        require(getElapsedTime() >= gameDuration, "Game duration not yet finished");
        gameStartTime = 0;
        require(blockManager.finishGame(), "BlockManager finish failed");
        require(playerManager.finishGame(), "PlayerManager finish failed");

        return true;
    }

   function movePlayer(address _player, string memory _direction) external onlyPlayer(_player) onlyDuringGame {
        require(token.balanceOf(_player) >= movePrice, "Not enough tokens!");

        uint256 allowedAmount = token.allowance(_player, address(this));
        require(allowedAmount >= movePrice, "Not enough allowance for transfer");
        require(token.transferFrom(_player, gameAddress, movePrice), "Token transfer failed");

        require(playerManager.movePlayer(_player, _direction), "Move failed");
    
        emit PlayerMoved(_player, _direction);
    }

    // Check
    function checkSupportPackage(address _player) public view onlyPlayer(_player) returns (bool) {
        require(msg.sender == _player);
        return blockManager.checkSupportPackage(_player);
    }

    function checkTreasure(address _player) public view onlyPlayer(_player) returns (bool) {
        require(msg.sender == _player);
        return blockManager.checkTreasure(_player);
    }

    // Claims
    function claimSupportPackage(address _player) external onlyPlayer(_player) {
        require(msg.sender == _player);
        require(blockManager.checkSupportPackage(_player), "No support package available");
        tokenManager.claimSupportPackage(_player);
        require(blockManager.resetSupportBlocks());

        emit SupportPackageClaimed(_player);
    }

    function claimTreasure(address _player) external onlyPlayer(_player) {
        require(msg.sender == _player);
        require(blockManager.checkTreasure(_player), "No treasure available");
        tokenManager.claimTreasure(_player);

        require(blockManager.finishGame());
        require(playerManager.finishGame());
        
        gameStartTime = 0;
        emit TreasureClaimed(_player);
    }
    
    function withdrawToken() public gameAddressOwner {
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw"); 
        require(token.transferFrom(address(this), gameAddress, tokenBalance), "Token transfer failed");
    }

    // Getters
    function isPlayer(address _player) public view returns (bool) {
        return playerManager.isPlayer(_player);
    }

    function getPlayers() public view returns (address[] memory) {
        return playerManager.showPlayers();
    }
    function getPlayerArrayNumber(address _player) public view returns(uint256) {
        return playerManager.PlayerNumber(_player);
    }

    function findPlayer(address _player) public view returns (uint256 x, uint256 y) {
        (x, y) = playerManager.findPlayer(_player);
    }

    function getTotalPlayers() public view returns(uint256) {
        return playerManager.getTotalPlayers();
    }

    function getPlayerIndex(address _player) public view returns(uint256) {
        return blockManager.PlayerIndex(_player);
    }

    function getElapsedTime() public view returns (uint256) {
        if (gameStartTime == 0) {
            return 0;
        }
        return block.timestamp - gameStartTime;
    }

    // Set
    function setNewAuthorized(address _newauthorized) public onlyAuthorized {
        authorizedAddress = _newauthorized;
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

    modifier onlyPlayer(address _player) {
        require(playerManager.isPlayer(_player), "Not a valid player");
        _;
    }

    modifier onlyFirst(address _player) {
        require(playerManager.playerAddresses(0) == _player, "Not the first player");
        _;
    }
    modifier gameAddressOwner {
        require(msg.sender == gameAddress, "You are not gameAddress2");
        _;
    }
}