// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/token.sol";
import "contracts/PlayerManager.sol";
import "./BlockManager.sol";

contract TokenManager {
    PlayerManager public playerManager;
    BlockManager public blockManager;
    MyToken public token;

    address public treasureHuntAddress;
    address public gameAddress; // for tokens 
    address public setOwner= 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    uint256 public constant TREASURE_REWARD = 5000 * 10**18;
    uint256 public constant SUPPORT_PACKAGE_REWARD = 500 * 10**18;
    uint256 public constant MAX_REWARD_LIMIT = 50000 * 10**18;

    // Events
    event TreasureClaimed(address indexed player, uint256 reward);
    event SupportPackageClaimed(address indexed player, uint256 reward);

    // Constructor
    constructor(PlayerManager _playerManager, BlockManager _blockManager,MyToken _token) {
        token = _token;
        playerManager = _playerManager;
        blockManager = _blockManager;
    }

    // Claims
    function claimTreasure(address _player) external onlyTreasureHunt {
        require(_player != address(0), "Invalid player address");
        require(token.balanceOf(address(this)) >= TREASURE_REWARD, "Not enough tokens in contract");
        require(SUPPORT_PACKAGE_REWARD <= MAX_REWARD_LIMIT, "Support package reward exceeds limit");
        require(token.transfer(_player, TREASURE_REWARD), "Treasure reward transfer failed");

        emit TreasureClaimed(_player, TREASURE_REWARD);
    }

    function claimSupportPackage(address _player) external onlyTreasureHunt{
        require(_player != address(0), "Invalid player address");
        require(token.balanceOf(address(this)) >= SUPPORT_PACKAGE_REWARD, "Not enough tokens in contract");
        require(token.transfer(_player, SUPPORT_PACKAGE_REWARD), "Support package reward transfer failed");

        emit SupportPackageClaimed(_player, SUPPORT_PACKAGE_REWARD);
    }

    function withdrawToken() public gameAddress2 {
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw"); 
        require(token.transfer(gameAddress, tokenBalance), "Token transfer failed");
    }
    
    function getBalanceToken() public view returns(uint256) {
       uint256 tokenBalance  = token.balanceOf(address(this));
       return tokenBalance;
    }

    function setTreasureHunt(address _treasureHunt) public onlyOwner {
        treasureHuntAddress = _treasureHunt;
    }

    function getBalanceGameAddress() public view returns(uint256) {
        uint256 tokenBalance  = token.balanceOf(address(gameAddress));
        return tokenBalance;
    }

    // Modifier
    modifier gameAddress2 {
        require(msg.sender == gameAddress, "You are not gameAddress2");
        _;
    }
    modifier onlyOwner {
        require(msg.sender == setOwner, "You are not authorized");
        _;
    }

    modifier onlyTreasureHunt {
        require(msg.sender == treasureHuntAddress, "You are not TreasureHunt address");
        _;
    }
}
