// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18;
    
    constructor(address _initialAddress) ERC20("MyToken", "MTK") {
        _mint(_initialAddress, INITIAL_SUPPLY);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}