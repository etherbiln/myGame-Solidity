// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/token.sol";
import "contracts/PlayerManager.sol";

contract TokenManager {
    MyToken public token;
    PlayerManager public player;

    address ownerGameAddress = 0xAC0775EA1214Dd83c9e9951e6C476605d11ECEF6;
    
    uint256 public clueCost;
    uint256 public constant TREASURE_REWARD = 5000 * 10**18; // 5000 token, 18 decimal
    uint256 public constant SUPPORT_PACKAGE_REWARD = 500 * 10**18; // 500 token, 18 decimal

    constructor(address _tokenAddress, uint256 _clueCost) {
        token = MyToken(_tokenAddress);
        clueCost = _clueCost;
    }

    //CLAIM
    function claimTreasure(address _player) external {
        require(_player != address(0), "Invalid player address");
        require(token.balanceOf(address(this)) >= TREASURE_REWARD, "Not enough tokens in contract");

        // Treasure bulunduğunda ödül olarak 5000 token gönder
        require(token.transfer(_player, TREASURE_REWARD), "Treasure reward transfer failed");
    }

    function claimSupportPackage(address _player) external {
        require(_player != address(0), "Invalid player address");
        require(token.balanceOf(address(this)) >= SUPPORT_PACKAGE_REWARD, "Not enough tokens in contract");

        // Support package bulunduğunda ödül olarak 500 token gönder
        require(token.transfer(_player, SUPPORT_PACKAGE_REWARD), "Support package reward transfer failed");
    }

    //-
    function purchaseClue(address _player) external payable {
        require(_player != address(0), "Invalid player address");
        require(token.allowance(_player, address(this)) >= clueCost, "Allowance too low");
        require(token.transferFrom(_player, ownerGameAddress, clueCost), "Clue purchase failed");
    }
}
