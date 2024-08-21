const { expect } = require("chai");
const setupContracts = require("./setup");

describe("TreasureHuntGame", function () {
    let deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame;

    beforeEach(async function () {
        ({ deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame } = await setupContracts());
    });

    it("should allow a player to join the game", async function () {
        await treasureHuntGame.connect(player1).joinGame(player1.address);
        const players = await playerManager.showPlayers();
        expect(players).to.include(player1.address);
    });

    it("should allow a player to move", async function () {
        await treasureHuntGame.connect(deployer).onlyAuthorized(player1.address);
        await treasureHuntGame.connect(player1).joinGame(player1.address);
        await treasureHuntGame.connect(player1).startGame();
        await treasureHuntGame.connect(player1).movePlayer(player1.address,"up");
        const { x, y } = await playerManager.findLocation(player1.address);
        expect(x).to.equal(0);
        expect(y).to.equal(1);
    });

    it("should allow players to claim rewards", async function () {
        await treasureHuntGame.connect(deployer).onlyAuthorized(player1.address);
        await treasureHuntGame.connect(player1).joinGame(player1.address);
        await treasureHuntGame.connect(player1).startGame();
        for(let i =0 ;i<7;i++) {
            if(await tokenManager.checkTreasure()) {
                await treasureHuntGame.connect(player1).movePlayer(player1.address,"up");
                await tokenManager.connect(player1).claimTreasure(player1.address);
            }
        }
        const balance = await myToken.balanceOf(player1.address);
        expect(balance).to.be.above(0);
    });
});
