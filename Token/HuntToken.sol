// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title HuntToken
 * @dev ERC20 Token with burnable and ownable features, plus a vesting mechanism for locked tokens.
 */
contract HuntToken is ERC20, ERC20Burnable, Ownable {
    uint256 public constant TOTAL_SUPPLY = 1_000_000 * 10**18;
    uint256 public constant LOCKED_SUPPLY = TOTAL_SUPPLY * 30 / 100;
    uint256 public constant VESTING_MONTHS = 24;

    struct LockInfo {
        uint256 totalAmount;
        uint256 claimedAmount;
        uint256 startTime;
        uint256 releaseTime;
    }

    mapping(address => LockInfo) public lockedAddresses;

    event Locked(address indexed account, uint256 amount, uint256 releaseTime);
    event Claimed(address indexed account, uint256 amount);

    /**
     * @dev Constructor that gives msg.sender all of existing tokens except the locked supply.
     */
    constructor()
        ERC20("Treasure Hunt", "HUNT")
        Ownable(msg.sender)
    {
        _mint(msg.sender, TOTAL_SUPPLY - LOCKED_SUPPLY);
        _mint(address(this), LOCKED_SUPPLY);
        lockTokens(msg.sender, LOCKED_SUPPLY, VESTING_MONTHS);
    }

    /**
     * @dev Lock tokens for a specified account and duration.
     * @param account The address to lock tokens for.
     * @param amount The amount of tokens to lock.
     * @param months The duration in months for which tokens are locked.
     */
    function lockTokens(address account, uint256 amount, uint256 months) public {
        require(amount <= balanceOf(address(this)), "Exceeds available supply to lock");
        require(months >= 1 && months <= VESTING_MONTHS, "Lock duration must be between 1 and 24 months");
        uint256 releaseTime = block.timestamp + (months * 30 days);
        lockedAddresses[account] = LockInfo({
            totalAmount: amount,
            claimedAmount: 0,
            startTime: block.timestamp,
            releaseTime: releaseTime
        });
        emit Locked(account, amount, releaseTime);
    }

    /**
     * @dev Get the amount of releasable tokens for a specified account.
     * @param account The address to check.
     * @return The amount of releasable tokens.
     */
    function getReleasableAmount(address account) public view returns (uint256) {
        LockInfo memory lockInfo = lockedAddresses[account];
        if (block.timestamp < lockInfo.startTime) {
            return 0;
        }
        uint256 monthsPassed = (block.timestamp - lockInfo.startTime) / 30 days;
        uint256 monthlyRelease = lockInfo.totalAmount / VESTING_MONTHS;
        uint256 totalReleasable = monthsPassed * monthlyRelease;
        return totalReleasable - lockInfo.claimedAmount;
    }

    /**
     * @dev Claim unlocked tokens for the calling account.
     */
    function claimUnlockedTokens() external {
        LockInfo storage lockInfo = lockedAddresses[msg.sender];
        require(lockInfo.totalAmount > 0, "No tokens locked for this address");
        uint256 releasable = getReleasableAmount(msg.sender);
        require(releasable > 0, "No tokens available for claim");
        lockInfo.claimedAmount += releasable;
        _transfer(address(this), msg.sender, releasable);
        emit Claimed(msg.sender, releasable);
    }

    /**
     * @dev Get lock information for a specified account.
     * @param account The address to check.
     * @ The total amount, claimed amount, start time, and release time of the locked tokens.
     */
    function getLockInfo(address account) external view returns (uint256 totalAmount, uint256 claimedAmount, uint256 startTime, uint256 releaseTime) {
        LockInfo memory lockInfo = lockedAddresses[account];
        return (lockInfo.totalAmount, lockInfo.claimedAmount, lockInfo.startTime, lockInfo.releaseTime);
    }
}
