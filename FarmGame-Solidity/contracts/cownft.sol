// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./farm.sol";
import "contracts/cow.sol";


contract CowNFT is Cow, ERC721 {
    address public farmContract; // Çiftlik sözleşmesinin adresi
    uint public constant mintPrice = 0.1 ether; // NFT başına fiyat

    constructor(address _farmContract) ERC721("Cow", "COW") {
        farmContract = _farmContract;
        require(farmContract == msg.sender); // 
    }

    // Bir inek NFT'si oluşturur ve verilen adres sahibi yapar
    function mintCowNFT(address _to, uint _tokenId) public payable {
        require(msg.value == mintPrice, "Please send 1 ether to mint a cow NFT.");
        _mint(_to, _tokenId);
        payable(farmContract).transfer(msg.value); // Ödeme, çiftlik sözleşmesine aktarılır
    }

    // İnek NFT'sine sahip olan kişiye ait ineği alır ve sütünü sağar
    function milkCowNFT(uint _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You can only milk your own cow.");
        uint cowId = _tokenId - 1; // NFT token ID'si, inek dizisi indeksinden 1 eksik olacak şekilde oluşturulmuştur
        milkCow(cowId);
    }

    // Çiftlik sözleşmesinin sahibi tarafından kullanılabilen özel bir fonksiyon
    // Bu fonksiyon, CowNFT sözleşmesine ether transferi yaparak çiftlik sahibi olmayı sağlar
    function becomeFarmOwner() public payable {
        require(msg.value == 10 ether, "Please send 10 ether to become a farm owner.");
        farmContract = msg.sender;
    }
}
