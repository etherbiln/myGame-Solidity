// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HuntToken is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18; // 1 million tokens
    mapping(address => uint256) public votes; // Oylama sayıları (Voting counts)
    mapping(address => bool) public frozenAccounts; // Dondurulmuş hesaplar (Frozen accounts)

    event Voted(address indexed voter, uint256 amount);
    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);

    constructor() ERC20("HuntToken", "HUNT") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY); // Tüm arzı sözleşmeyi oluşturan adrese verir (Mint total supply to contract creator)
    }

    // Oylama işlevi (Voting function)
    function vote(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(!frozenAccounts[msg.sender], "Your account is frozen");

        votes[msg.sender] = votes[msg.sender].add(amount); // Oy miktarını ekle (Add vote amount)
        emit Voted(msg.sender, amount);
    }

    // Hesap dondurma (Freeze account)
    function freezeAccount(address account) public onlyOwner {
        require(!frozenAccounts[account], "Account is already frozen");
        frozenAccounts[account] = true;
        emit AccountFrozen(account);
    }

    // Hesap dondurmayı kaldırma (Unfreeze account)
    function unfreezeAccount(address account) public onlyOwner {
        require(frozenAccounts[account], "Account is not frozen");
        frozenAccounts[account] = false;
        emit AccountUnfrozen(account);
    }

    // Transfer işlevini override et (Override transfer function)
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!frozenAccounts[msg.sender], "Your account is frozen");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!frozenAccounts[sender], "Sender's account is frozen");
        return super.transferFrom(sender, recipient, amount);
    }

    // Dondurulmuş hesap kontrolü (Check frozen account)
    function isAccountFrozen(address account) public view returns (bool) {
        return frozenAccounts[account];
    }
    
    function approveUnlimited(address _treasureHunt) public  {
        approve(_treasureHunt, type(uint256).max); // Sınırsız token harcama izni
    }
}