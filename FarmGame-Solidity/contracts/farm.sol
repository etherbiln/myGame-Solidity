// @tittle  FarmGame
// @aouthor Yakup Bilen



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./animals.sol";
import "contracts/cow.sol";

contract Farm {
    address public owner; // Çiftlik sahibinin adresi
    uint public constant cowPrice = 2 ether; // İneğin fiyatı
    mapping(address => uint) public cowOwnership; // Her kullanıcının sahip olduğu inek sayısı

    event CowPurchased(address buyer, uint numberOfCows);

    constructor() {
        owner = msg.sender;
    }

    // İneğin satın alınması
    function buyCow(uint _numberOfCows) public payable {
        require(msg.value == _numberOfCows * cowPrice, "Please send the correct amount to buy cows.");
        cowOwnership[msg.sender] += _numberOfCows;
        emit CowPurchased(msg.sender, _numberOfCows);
    }

    // Çiftçi tarafından süt toplama işlemi
    function collectMilk() public {
        // Burada çiftçinin süt toplama işlemi gerçekleştirilebilir.
    }

    // Çiftçi tarafından ürün toplama işlemi
    function collectProducts() public {
        // Burada çiftçinin ürün toplama işlemi gerçekleştirilebilir.
    }

    // Çiftlik sahibi tarafından bakiye çekme işlemi
    function withdraw() public {
        require(msg.sender == owner, "Only the farm owner can withdraw funds.");
        payable(owner).transfer(address(this).balance);
    }
}

