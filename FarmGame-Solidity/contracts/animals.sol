// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Animals {

    struct Animal {
        string kind;
        uint age;
        uint numberOfAnimal;
    }

    mapping(address => uint) public level;
    mapping(uint => address) public animalToOwner;
    
    Animal[] public animals;

}
contract Animals2 {
    struct Animal {
        string kind; // Hayvan türü
        uint age; // Hayvanın yaşı
        uint numberOfAnimal; // Hayvanın sayısı (örneğin, ineklerde süt miktarı)
    }

    Animal[] public animals; // Tüm hayvanlar
    
    // Hayvan sayısını döndürür
    function getAnimalCount() public view returns (uint) {
        return animals.length;
    }

    // Yeni bir hayvan ekler
    function addAnimal(string memory _kind, uint _age, uint _numberOfAnimal) internal {
        animals.push(Animal(_kind, _age, _numberOfAnimal));
    }
}
