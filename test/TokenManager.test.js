const { expect } = require("chai");
const setupContracts = require("./setup");

describe("TokenManager", function () {
    let deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame;

    beforeEach(async function () {
        ({ deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame } = await setupContracts());
    });

    it("should allow claiming treasure reward", async function () {
        await playerManager.connect(player1).joinGame(player1.address);
        await tokenManager.claimTreasure(player1.address);
        const balance = await myToken.balanceOf(player1.address);
        expect(balance).to.be.above(0);
    });

    it("should allow claiming support package reward", async function () {
        await playerManager.connect(player1).joinGame(player1.address);
        await tokenManager.claimSupportPackage(player1.address);
        const balance = await myToken.balanceOf(player1.address);
        expect(balance).to.be.above(0);
    });
});
