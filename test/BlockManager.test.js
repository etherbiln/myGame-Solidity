const { expect } = require("chai");
const setupContracts = require("./setup");

describe("BlockManager", function () {
    let deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame;

    beforeEach(async function () {
        ({ deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame } = await setupContracts());
    });

    it("should correctly place treasures and support packages", async function () {
        const block = await blockManager.getBlock();
        expect(block.isTreasure).to.be.false;
        expect(block.isSupportPackage).to.be.false;
    });

    it("should return correct block data based on player location", async function () {
        await playerManager.connect(player1).joinGame(player1.address);
        await playerManager.connect(player1).movePlayer(player1.address, "right");
        const block = await blockManager.getBlock(player1);
        const { x, y } = await playerManager.findLocation(player1.address);
        const blockData = await blockManager.getBlock(x, y);
        expect(blockData).to.deep.equal(block);
    });
});
