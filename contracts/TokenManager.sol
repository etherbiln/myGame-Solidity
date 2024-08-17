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
    uint256 public constant MAX_REWARD_LIMIT = 50000;

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
        require(SUPPORT_PACKAGE_REWARD <= MAX_REWARD_LIMIT, "Support package reward exceeds limit");
        require(token.balanceOf(address(this)) >= TREASURE_REWARD, "Not enough tokens in contract");
        require(token.transfer(_player, TREASURE_REWARD), "Treasure reward transfer failed");

        emit TreasureClaimed(_player, TREASURE_REWARD); // Emit event
    }

    function claimSupportPackage(address _player) external {
        require(_player != address(0), "Invalid player address");
        require(token.balanceOf(address(this)) >= SUPPORT_PACKAGE_REWARD, "Not enough tokens in contract");
        require(token.transfer(_player, SUPPORT_PACKAGE_REWARD), "Support package reward transfer failed");

        emit SupportPackageClaimed(_player, SUPPORT_PACKAGE_REWARD); // Emit event
    }
}
