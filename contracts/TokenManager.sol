// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/token.sol";
import "contracts/PlayerManager.sol";
import "./BlockManager.sol";

contract TokenManager {
    PlayerManager public playerManager;
    BlockManager public blockManager;
    MyToken public token;

    address public gameAddress= 0x1405Ee3D5aF0EEe632b7ece9c31fA94809e6030d; // for tokens 
    address public setOwner= 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public treasureHuntAddress;

    uint256 public constant TREASURE_REWARD = 5000 * 10**18;
    uint256 public constant SUPPORT_PACKAGE_REWARD = 500 * 10**18;
    
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
        require(token.transferFrom(address(this), _player, TREASURE_REWARD), "Token transfer failed");

        emit TreasureClaimed(_player, TREASURE_REWARD);
    }

    function claimSupportPackage(address _player) external onlyTreasureHunt{
        require(_player != address(0), "Invalid player address");
        require(token.balanceOf(address(this)) >= SUPPORT_PACKAGE_REWARD, "Not enough tokens in contract");
        require(token.transferFrom(address(this), _player, SUPPORT_PACKAGE_REWARD), "Token transfer failed");

        emit SupportPackageClaimed(_player, SUPPORT_PACKAGE_REWARD);
    }

    function withdrawToken() public gameAddressOwner {
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw"); 
        require(token.transferFrom(address(this), gameAddress, tokenBalance), "Token transfer failed");
    }
    
    function getBalanceToken() public view returns(uint256) {
       uint256 tokenBalance  = token.balanceOf(address(this));
       return tokenBalance;
    }
     function getBalanceGameAddress() public view returns(uint256) {
        uint256 tokenBalance  = token.balanceOf(address(gameAddress));
        return tokenBalance;
    }

    // New authorized
    function setTreasureHunt(address _treasureHunt) public onlyOwner {
        treasureHuntAddress = _treasureHunt;
    }

    function setNewOwner(address _newOwner) public onlyOwner {
        setOwner = _newOwner;
    }

    // Modifier
    modifier gameAddressOwner {
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
