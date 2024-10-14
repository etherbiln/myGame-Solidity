// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PlayerManager.sol";
import "./BlockManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../Token/HuntToken.sol";

/**
 * @title TreasureHuntGame
 * @dev A smart contract for managing the Treasure Hunt game.
 * Players can join, move, claim rewards, and interact with game mechanics.
 */
contract TreasureHuntGame is Ownable {
    PlayerManager public playerManager;
    BlockManager public blockManager;
    HuntToken public token;
    
    uint256 public constant SUPPORT_PACKAGE_REWARD = 150 * 10 ** 18;
    uint256 public constant MOVE_PRICE = 25 * 10 ** 18;
    uint256 public gameDuration = 900; // 15 minutes
    uint256 public gameStartTime;
    address public authorizedAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public TeamAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    event GameStarted(uint256 startTime);
    event PlayerJoined(address indexed player);
    event PlayerLeft(address indexed player);
    event PlayerMoved(address indexed player, string direction);
    event SupportPackageClaimed(address indexed player);
    event TreasureClaimed(address indexed player);

    /**
     * @dev Constructor initializes the game with necessary contracts.
     * @param _playerManager Address of the PlayerManager contract.
     * @param _blockManager Address of the BlockManager contract.
     * @param _token Address of the HuntToken contract.
     */
    constructor(
        address _playerManager,
        address _blockManager,
        address _token
    ) Ownable(msg.sender) {
        playerManager = PlayerManager(_playerManager);
        blockManager = BlockManager(_blockManager);
        token = HuntToken(_token);
    }

    // Game Functions

    /**
     * @dev Allows a player to join the game by paying the MOVE_PRICE.
     */
    function joinGame() external {
        require(msg.sender != address(0), "Invalid player address");
        bool success = token.approve(address(this), MOVE_PRICE);
        require(success, "Token approval failed");

        require(token.transferFrom(msg.sender, address(this), MOVE_PRICE), "Token transfer failed");
        require(playerManager.joinGame(msg.sender, MOVE_PRICE), "Join game failed");

        emit PlayerJoined(msg.sender);
    }

    /**
     * @dev Allows a player to leave the game and receive a refund.
     * @param _player The address of the player leaving the game.
     */
    function leaveGame(address _player) external onlyPlayer(_player) {
        uint256 paidAmount = playerManager.getTotalPaidPlayer(_player);
        uint256 refundAmount = paidAmount / 5;
        require(refundAmount > 0, "No paid!");

        require(playerManager.leaveGame(msg.sender), "Player leave failed");
        require(token.transfer(msg.sender, refundAmount), "Token transfer failed");

        emit PlayerLeft(msg.sender);
    }

    /**
     * @dev Starts the game. Can only be called by the first player.
     */
    function startGame() external onlyFirst(msg.sender) {
        require(gameStartTime == 0, "Game already started");
        gameStartTime = block.timestamp;

        blockManager.createSupportPackage();
        blockManager.createTreasure();

        emit GameStarted(gameStartTime);
    }

    /**
     * @dev Finishes the game. Can only be called by an authorized address.
     * @return bool indicating whether the game was successfully finished.
     */
    function finishGame() external onlyAuthorized returns (bool) {
        require(getElapsedTime() >= gameDuration, "Game duration not yet finished");
        gameStartTime = 0;

        require(blockManager.finishGame(), "BlockManager finish failed");
        require(playerManager.finishGame(), "PlayerManager finish failed");

        return true;
    }

    /**
     * @dev Allows a player to move in a specified direction during the game.
     * @param _direction The direction in which the player wants to move.
     */
    function movePlayer(string memory _direction) external onlyPlayer(msg.sender) onlyDuringGame {
        require(token.transferFrom(msg.sender, address(this), MOVE_PRICE), "Token transfer failed");
        require(playerManager.movePlayer(msg.sender, _direction), "Move failed");

        emit PlayerMoved(msg.sender, _direction);
    }

    // Claims

    /**
     * @dev Allows a player to claim a support package.
     */
    function claimSupportPackage() external onlyPlayer(msg.sender) {
        require(blockManager.checkSupportPackage(msg.sender), "No support package available");
        require(token.transfer(msg.sender, SUPPORT_PACKAGE_REWARD), "Token transfer failed");
        require(blockManager.resetSupportBlocks(), "Resetting support blocks failed");

        emit SupportPackageClaimed(msg.sender);
    }

    /**
     * @dev Allows a player to claim the treasure.
     */
    function claimTreasure() external onlyPlayer(msg.sender) {
        require(blockManager.checkTreasure(msg.sender), "No treasure available");
        uint256 treasureAmount = token.balanceOf(address(this));

        require(token.transfer(TeamAddress, treasureAmount / 4), "Token transfer failed (Team Address)");
        require(token.transfer(msg.sender, token.balanceOf(address(this))), "Token transfer failed (Player Address)");

        require(blockManager.finishGame(), "Finish game failed");
        require(playerManager.finishGame(), "PlayerManager finish failed");

        gameStartTime = 0;
        emit TreasureClaimed(msg.sender);
    }

    // Check functions
    function checkSupportPackage() public view returns (bool) {
        return blockManager.checkSupportPackage(msg.sender);
    }

    function checkTreasure() public view returns (bool) {
        return blockManager.checkTreasure(msg.sender);
    }

    // Getters
    function isPlayer(address _player) public view returns (bool) {
        return playerManager.isPlayer(_player);
    }

    function getPlayers() public view returns (address[] memory) {
        return playerManager.showPlayers();
    }

    function findPlayer(address _player) public view returns (uint256 x, uint256 y) {
        (x, y) = playerManager.findPlayer(_player);
    }

    function getTotalPlayers() public view returns (uint256) {
        return playerManager.getTotalPlayers();
    }

    function getElapsedTime() public view returns (uint256) {
        return block.timestamp - gameStartTime;
    }

    // Modifiers

    modifier onlyAuthorized() {
        require(msg.sender == authorizedAddress, "Not authorized");
        _;
    }

    function setNewAuthorized(address _newAuthorized) public onlyOwner {
        authorizedAddress = _newAuthorized;
    }

    modifier onlyPlayer(address _player) {
        require(playerManager.isPlayer(_player), "Not a valid player");
        _;
    }

    modifier onlyFirst(address _player) {
        require(playerManager.playerAddresses(0) == _player, "Not the first player");
        _;
    }

    modifier onlyDuringGame() {
        require(block.timestamp <= gameStartTime + gameDuration, "Game is over");
        _;
    }
}
