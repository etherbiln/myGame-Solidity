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

    // Change mapping to hold an array of LockInfo structs for each account
    mapping(address => LockInfo[]) public lockedAddresses;

    event Locked(address indexed account, uint256 amount, uint256 releaseTime);
    event Claimed(address indexed account, uint256 amount);

    constructor() ERC20("Treasure Hunt", "HUNT") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY - LOCKED_SUPPLY);
        _mint(msg.sender, LOCKED_SUPPLY);
        lockTokensForVesting(LOCKED_SUPPLY, VESTING_MONTHS);
    }

    /**
     * @dev Lock tokens for vesting during contract creation.
     */
    function lockTokensForVesting(uint256 amount, uint256 months) private {
        require(amount <= balanceOf(msg.sender), "Exceeds available supply to lock");
        require(months >= 1 && months <= VESTING_MONTHS, "Lock duration must be between 1 and 24 months");
        uint256 releaseTime = block.timestamp + (months * 30 days);

        require(transfer(address(this), amount), "Transfer failed");

        // Push a new lock entry to the array
        lockedAddresses[msg.sender].push(LockInfo({
            totalAmount: amount,
            claimedAmount: 0,
            startTime: block.timestamp,
            releaseTime: releaseTime
        }));

        emit Locked(msg.sender, amount, releaseTime);
    }

    /**
     * @dev Lock tokens for a specified account and duration.
     * @param amount The amount of tokens to lock.
     * @param months The duration in months for which tokens are locked.
     */
    function lockTokens(uint256 amount, uint256 months) public {
        require(amount <= balanceOf(msg.sender), "Exceeds available supply to lock");
        require(months >= 1 && months <= VESTING_MONTHS, "Lock duration must be between 1 and 24 months");
        uint256 releaseTime = block.timestamp + (months * 30 days);
        require(transfer(address(this), amount), "Transfer failed");

        // Push a new lock entry to the array
        lockedAddresses[msg.sender].push(LockInfo({
            totalAmount: amount,
            claimedAmount: 0,
            startTime: block.timestamp,
            releaseTime: releaseTime
        }));

        emit Locked(msg.sender, amount, releaseTime);
    }

    /**
     * @dev Get all lock information for a specified account.
     * @param account The address to check.
     * @return An array of LockInfo structs for the account.
     */
    function getLockInfo(address account) external view returns (LockInfo[] memory) {
        return lockedAddresses[account]; // Return all lock entries for the account
    }

    /**
     * @dev Get the amount of releasable tokens for a specified account.
     * @param account The address to check.
     * @return The total releasable tokens.
     */
    function getReleasableAmount(address account) public view returns (uint256) {
        uint256 totalReleasable = 0;

        // Loop through each lock entry for the account
        for (uint256 i = 0; i < lockedAddresses[account].length; i++) {
            LockInfo memory lockInfo = lockedAddresses[account][i];

            // Check if lock period has started
            if (block.timestamp >= lockInfo.startTime) {
                uint256 monthsPassed = (block.timestamp - lockInfo.startTime) / 30 days;

                // Calculate releasable amount for the lock entry
                uint256 monthlyRelease = lockInfo.totalAmount / VESTING_MONTHS;
                uint256 releasableForLock = (monthsPassed * monthlyRelease > lockInfo.claimedAmount)
                    ? (monthsPassed * monthlyRelease) - lockInfo.claimedAmount
                    : 0;

                totalReleasable += releasableForLock;
            }
        }

        return totalReleasable;
    }

    /**
     * @dev Claim unlocked tokens for the calling account.
     */
    function claimUnlockedTokens() external {
        uint256 releasable = getReleasableAmount(msg.sender);
        require(releasable > 0, "No tokens available for claim");

        // Update claimed amounts for each lock and transfer releasable tokens
        for (uint256 i = 0; i < lockedAddresses[msg.sender].length; i++) {
            LockInfo storage lockInfo = lockedAddresses[msg.sender][i];
            uint256 monthsPassed = (block.timestamp - lockInfo.startTime) / 30 days;

            // Calculate releasable for this specific lock entry
            uint256 monthlyRelease = lockInfo.totalAmount / VESTING_MONTHS;
            uint256 releasableForLock = (monthsPassed * monthlyRelease > lockInfo.claimedAmount)
                ? (monthsPassed * monthlyRelease) - lockInfo.claimedAmount
                : 0;

            // Only update if there's releasable tokens for this lock
            if (releasableForLock > 0) {
                lockInfo.claimedAmount += releasableForLock;
            }
        }

        // Transfer all releasable tokens to the user
        _transfer(address(this), msg.sender, releasable);

        emit Claimed(msg.sender, releasable);
    }
}
