// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./animals.sol";
import "contracts/farm.sol";


contract Cow is Animals {

    uint public dayMilk; // Gün başına üretilen süt miktarı
    string public cowCollor; // İneğin rengi
    uint public constant milkPrice = 0.01 ether; // Süt başına fiyat

    // Yeni bir inek oluşturur
    function createCow(string memory _kind, uint _age, uint _dayMilk, string memory _cowCollor) internal {
        animals.push(Animal(_kind, _age, _dayMilk));
        dayMilk = _dayMilk;
        cowCollor = _cowCollor;
    }

    // Gün başına üretilen süt miktarını döndürür
    function getDayMilk() public view returns (uint) {
        return dayMilk;
    }

    // İneğin rengini döndürür
    function getCowColor() public view returns (string memory) {
        return cowCollor;
    }

    // Bir inek satın alır
    function buyCow(string memory _kind, uint _age, uint _dayMilk, string memory _cowCollor ) public payable {
        require(msg.value >= 1 ether, "You need to send at least 1 ether to buy a cow.");
        createCow(_kind, _age, _dayMilk, _cowCollor);
        payable(address(this)).transfer(msg.value);
    }

    // İneği besler
    function feedCow(uint _animalId) public view  {
        require(animalToOwner[_animalId] == msg.sender, "You can only feed your own cow.");
        require(animals[_animalId].age < 365, "This cow is too old to feed.");
        // Burada ineğin yemek yemesi işlemi gerçekleştirilebilir.
    }

    function milkCow(uint _animalId) public payable {
        require(animalToOwner[_animalId] == msg.sender, "You can only milk your own cow.");
        require(animals[_animalId].age >= 365, "This cow is too young to milk.");
        require(animals[_animalId].numberOfAnimal > 0, "This cow has no milk.");
        require(msg.value == milkPrice, "Please send 0.1 ether to get milk from this cow.");
        // Burada ineğin sağılması işlemi gerçekleştirilebilir.
        // Sağılan sütü kullanıcıya gönder
        payable(msg.sender).transfer(msg.value);
        // Süt miktarını azalt
        animals[_animalId].numberOfAnimal--;
    }
}
