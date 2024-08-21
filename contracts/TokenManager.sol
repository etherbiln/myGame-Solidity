// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/token.sol";
import "contracts/PlayerManager.sol";
import "./BlockManager.sol";

contract TokenManager {
    PlayerManager public playerManager;
    BlockManager public blockManager;
    MyToken public token;

    address public ownerGameAddress = 0xAC0775EA1214Dd83c9e9951e6C476605d11ECEF6;
    uint256 public constant TREASURE_REWARD = 5000 * 10**18;
    uint256 public constant SUPPORT_PACKAGE_REWARD = 500 * 10**18;
    uint256 public constant MAX_REWARD_LIMIT = 50000 * 10**18;

    address public newOwner;

    // Events
    event TreasureClaimed(address indexed player, uint256 reward);
    event SupportPackageClaimed(address indexed player, uint256 reward);

    // Constructor
    constructor(PlayerManager _playerManager, BlockManager _blockManager) {
        token = MyToken(ownerGameAddress);
        playerManager = _playerManager;
        blockManager = _blockManager;
    }

    // Claims
    function claimTreasure(address _player) external {
        require(_player != address(0), "Invalid player address");
        require(blockManager.checkTreasure(_player),"You are not egilible");
        require(token.balanceOf(address(this)) >= TREASURE_REWARD, "Not enough tokens in contract");
        require(SUPPORT_PACKAGE_REWARD <= MAX_REWARD_LIMIT, "Support package reward exceeds limit");
        require(token.transfer(_player, TREASURE_REWARD), "Treasure reward transfer failed");

        emit TreasureClaimed(_player, TREASURE_REWARD);
    }

    function claimSupportPackage(address _player) external {
        require(_player != address(0), "Invalid player address");
        require(blockManager.checkSupportPackage(_player),"You are not egilible");
        require(token.balanceOf(address(this)) >= SUPPORT_PACKAGE_REWARD, "Not enough tokens in contract");
        require(token.transfer(_player, SUPPORT_PACKAGE_REWARD), "Support package reward transfer failed");

        emit SupportPackageClaimed(_player, SUPPORT_PACKAGE_REWARD);
    }

    function withdrawToken() public onlyOwner {
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw"); 
        require(token.transfer(ownerGameAddress, tokenBalance), "Token transfer failed");
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner, "Not the new owner");
        ownerGameAddress = newOwner;
        newOwner = address(0);
    }

    modifier onlyOwner {
        require(ownerGameAddress ==msg.sender);
        _;
    }
}
