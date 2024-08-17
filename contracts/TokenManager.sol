// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/token.sol";
import "contracts/PlayerManager.sol";
import "./BlockManager.sol";

contract TokenManager {
    PlayerManager public playerManager;
    BlockManager public blockManager;

    MyToken public token;

    uint256 public clueCost = 10;
    address public ownerGameAddress = 0xAC0775EA1214Dd83c9e9951e6C476605d11ECEF6;
    
    uint256 public constant TREASURE_REWARD = 5000 * 10**18; // 5000 token, 18 decimal
    uint256 public constant SUPPORT_PACKAGE_REWARD = 500 * 10**18; // 500 token, 18 decimal
    uint256 public constant MAX_REWARD_LIMIT = 50000;
    

    // event CluePurchased(address player);

    // Constructor
    constructor(PlayerManager _playerManager,BlockManager  _blockManager) {
        token = MyToken(ownerGameAddress);
        playerManager = _playerManager;
        blockManager = _blockManager;
    }

    //CLAIM
    function claimTreasure(address _player) external {
        require(_player != address(0), "Invalid player address");
        require(SUPPORT_PACKAGE_REWARD <= MAX_REWARD_LIMIT, "Support package reward exceeds limit");

        require(token.balanceOf(address(this)) >= TREASURE_REWARD, "Not enough tokens in contract");
        
        require(token.transfer(_player, TREASURE_REWARD), "Treasure reward transfer failed");
    }

    function claimSupportPackage(address _player) external {
        require(_player != address(0), "Invalid player address");
        require(token.balanceOf(address(this)) >= SUPPORT_PACKAGE_REWARD, "Not enough tokens in contract");
        require(token.transfer(_player, SUPPORT_PACKAGE_REWARD), "Support package reward transfer failed");
    }

    // CLUE
    // function buyClue(address _player) external {        
    //     require(playerManager.players[_player].hasJoined, "Player not joined");
    //     require(!playerManager.players[_player].hasClue, "Player already has a clue");

    //     playerManager.players[_player].hasClue = true;

    //     // Ensure the player has sufficient allowance for the transfer
    //     require(token().allowance(_player, address(this)) >= clueCost, "Allowance too low");

    //     // Perform the token transfer
    //     require(token().transferFrom(_player, ownerGameAddress, clueCost), "Clue purchase failed");

    //     emit CluePurchased(_player);
    // }
}