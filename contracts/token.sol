// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract MyToken is ERC20, Ownable, Pausable {
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18;
    
    event Burn(address indexed from, uint256 amount);

    constructor(address _initialAddress) ERC20("MyToken", "MTK") Ownable(msg.sender) {
        _mint(_initialAddress, INITIAL_SUPPLY);
    }

    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // Override transfer to include pausing functionality
    function transfer(address recipient, uint256 amount) public whenNotPaused override returns (bool) {
        return super.transfer(recipient, amount);
    }

    // Override transferFrom to include pausing functionality
    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused override returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    // Override approve to include pausing functionality
    function approve(address spender, uint256 amount) public whenNotPaused override returns (bool) {
        return super.approve(spender, amount);
    }

    // Example function to use tokens for a game-specific purpose
    function spendTokens(uint256 amount) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
    }
}
