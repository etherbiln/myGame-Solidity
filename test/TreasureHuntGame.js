const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TreasureHuntGame", function () {
    let TreasureHuntGame, treasureHuntGame, MyToken, myToken;
    let owner, player1, player2;

    beforeEach(async function () {
        // Deploy MyToken contract
        MyToken = await ethers.getContractFactory("MyToken");
        myToken = await MyToken.deploy();
        await myToken.deployed();

        [owner, player1, player2] = await ethers.getSigners();

        // Deploy TreasureHuntGame contract
        TreasureHuntGame = await ethers.getContractFactory("TreasureHuntGame");
        treasureHuntGame = await TreasureHuntGame.deploy(myToken.address, ethers.utils.parseUnits("1", 18), 5, 3600); // 1 token clue cost, 5 blocks for support package, 1 hour game duration
        await treasureHuntGame.deployed();

        // Mint tokens to players
        await myToken.mint(player1.address, ethers.utils.parseUnits("100", 18));
        await myToken.mint(player2.address, ethers.utils.parseUnits("100", 18));
    });

    it("should allow players to join the game", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        const player1Data = await treasureHuntGame.players(player1.address);
        expect(player1Data.hasJoined).to.be.true;

        await treasureHuntGame.connect(player2).joinGame();
        const player2Data = await treasureHuntGame.players(player2.address);
        expect(player2Data.hasJoined).to.be.true;
    });

    it("should start the game and prevent re-starting", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        await treasureHuntGame.connect(player2).joinGame();

        await treasureHuntGame.startGame();
        await expect(treasureHuntGame.startGame()).to.be.revertedWith("Game already started");
    });

    it("should allow players to move within bounds and check for treasure/support packages", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        await treasureHuntGame.startGame();

        await treasureHuntGame.connect(player1).movePlayer("right");
        let { x, y } = await treasureHuntGame.findLocation();
        expect(x).to.equal(1);
        expect(y).to.equal(0);
    });

    it("should allow players to buy clues and get clues", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        await treasureHuntGame.startGame();

        // Transfer tokens to player1
        await myToken.connect(player1).approve(treasureHuntGame.address, ethers.utils.parseUnits("1", 18));

        await treasureHuntGame.connect(player1).buyClue();
        const player1Data = await treasureHuntGame.players(player1.address);
        expect(player1Data.hasClue).to.be.true;
    });

    it("should find treasure and handle rewards correctly", async function () {
        // Assuming there's a treasure at position (1, 1) in the contract, you need to adjust the test for actual game logic
        await treasureHuntGame.connect(player1).joinGame();
        await treasureHuntGame.startGame();

        // Set a treasure on a specific block
        await treasureHuntGame.setBlock(1, 1, true, false); // Assuming you have a setBlock function to set the treasure for testing purposes

        await treasureHuntGame.connect(player1).movePlayer("right");
        await treasureHuntGame.connect(player1).movePlayer("down");
        
        await treasureHuntGame.connect(player1).findTreasure();
        
        const player1Balance = await myToken.balanceOf(player1.address);
        expect(player1Balance).to.be.equal(ethers.utils.parseUnits("101", 18)); // 100 initial + 1000 reward
    });

    it("should determine the winner based on steps count", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        await treasureHuntGame.connect(player2).joinGame();
        await treasureHuntGame.startGame();

        await treasureHuntGame.connect(player1).movePlayer("right");
        await treasureHuntGame.connect(player2).movePlayer("right");
        await treasureHuntGame.connect(player1).movePlayer("right");

        const winner = await treasureHuntGame.winnerAddress();
        expect(winner).to.equal(player1.address);
    });

    it("should handle game status correctly", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        await treasureHuntGame.startGame();
        const status = await treasureHuntGame.getGameStatus();
        expect(status).to.equal("Game is in progress.");

        // Simulate game end
        await ethers.provider.send("evm_increaseTime", [3600]);
        await ethers.provider.send("evm_mine", []);
        const statusAfter = await treasureHuntGame.getGameStatus();
        expect(statusAfter).to.equal("Game is Over.");
    });
});
