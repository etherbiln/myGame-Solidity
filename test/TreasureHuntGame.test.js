const { expect } = require("chai");
const setupContracts = require("./setup");

describe("TreasureHuntGame", function () {
    let deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame;

    beforeEach(async function () {
        ({ deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame } = await setupContracts());
    });

    it("should allow a player to join the game", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        const players = await playerManager.showPlayers();
        expect(players).to.include(player1.address);
    });

    it("should allow a player to move", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        await treasureHuntGame.connect(player1).movePlayer("up");
        const { x, y } = await playerManager.findLocation(player1.address);
        expect(x).to.equal(0);
        expect(y).to.equal(1);
    });

    it("should let a player buy a clue", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        
        const clueCost = await tokenManager.clueCost();
        await myToken.connect(deployer).transfer(player1.address, clueCost);
        await myToken.connect(player1).approve(tokenManager.address, clueCost);

        await treasureHuntGame.connect(player1).buyClue();

        const player = await playerManager.players(player1.address);
        expect(player.hasClue).to.be.true;
    });

    it("should allow players to claim rewards", async function () {
        await treasureHuntGame.connect(player1).joinGame();
        
        await tokenManager.claimTreasure(player1.address);

        const balance = await myToken.balanceOf(player1.address);
        expect(balance).to.be.above(0);
    });
});
