// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract RandomNumberGenerator is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    
    uint64 private subscriptionId;
    bytes32 private keyHash;
    uint32 private callbackGasLimit = 100000;
    uint16 private requestConfirmations = 3;
    uint32 private numWords = 1;

    uint256[] public randomWords;
    uint256 public requestId;
    address public owner;

    event RandomNumberRequested(uint256 requestId);
    event RandomNumberGenerated(uint256 randomWord);

    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        owner = msg.sender;
    }

    function requestRandomWords() public onlyOwner {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        emit RandomNumberRequested(requestId);
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory _randomWords
    ) internal override {
        randomWords = _randomWords;
        emit RandomNumberGenerated(randomWords[0]);
    }

    function getRandomNumberInRange() external onlyOwner returns (uint256) {
        require(randomWords.length > 0, "");

        requestRandomWords();

        return randomWords[0] % 102;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "");
        _;
    }
}
