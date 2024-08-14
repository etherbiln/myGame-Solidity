// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/token.sol";

contract TokenManager {
    MyToken public token;
    address ownerGameAddress = 0xAC0775EA1214Dd83c9e9951e6C476605d11ECEF6;
    uint256 public clueCost;

    constructor(address _tokenAddress, uint256 _clueCost) {
        token = MyToken(_tokenAddress);
        clueCost = _clueCost;
    }

    function purchaseClue(address _player) external {
        require(token.transferFrom(_player, ownerGameAddress, clueCost), "Clue purchase failed");
    }
}
