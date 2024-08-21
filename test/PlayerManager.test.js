const { expect } = require("chai");
const setupContracts = require("./setup");

describe("PlayerManager", function () {
    let deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame;

    beforeEach(async function () {
        ({ deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame } = await setupContracts());
    });

    it("should allow a player to join the game", async function () {
        await playerManager.connect(player1).joinGame(player1.address);
        const players = await playerManager.showPlayers();
        expect(players).to.include(player1.address);
    });

    it("should move player correctly", async function () {
        await playerManager.connect(player1).joinGame(player1.address);
        await playerManager.connect(player1).movePlayer(player1.address, "up");
        const { x, y } = await playerManager.findLocation(player1.address); 
        expect(x).to.equal(0);
        expect(y).to.equal(1);
    });

    it("should not allow right moving if player has exceeded max steps", async function () {
        await playerManager.connect(player1).joinGame(player1.address);
        for (let i = 0; i < 7; i++) {
            await playerManager.connect(player1).movePlayer(player1.address, "up");
        }
        await expect(playerManager.connect(player1).movePlayer(player1.address, "up")).to.be.revertedWith("Out of bounds");
    });
});
