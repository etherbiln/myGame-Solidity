const { expect } = require("chai");
const setupContracts = require("./setup");

describe("BlockManager", function () {
    let deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame;

    beforeEach(async function () {
        ({ deployer, player1, player2, myToken, playerManager, blockManager, tokenManager, treasureHuntGame } = await setupContracts());
    });

    it("should create treasures at random positions", async function () {
        await blockManager.connect(player1).createTreasure();
        const totalBlocks = 7 * 7;
        let treasureCount = 0;

        for (let i = 0; i < totalBlocks; i++) {
            const x = Math.floor(i / 7);
            const y = i % 7;
            if ((await blockManager.getPlayerBlockIndex(x, y)).isTreasure) treasureCount++;
        }

        expect(treasureCount).to.equal(5);
    });

    it("should create support packages at random positions", async function () {
        await blockManager.createSupportPackage();
        const totalBlocks = 7 * 7;
        let supportPackageCount = 0;

        for (let i = 0; i < totalBlocks; i++) {
            const x = Math.floor(i / 7);
            const y = i % 7;
            if ((await blockManager.getPlayerBlockIndex(x, y)).isSupportPackage) supportPackageCount++;
        }

        expect(supportPackageCount).to.equal(5);
    });

    it("should generate random numbers", async function () {
        const randomNumber = await blockManager.random(1);
        expect(randomNumber).to.be.a('number');
    });

    it("should check if a player finds a treasure", async function () {
        await playerManager.connect(player1).joinGame(player1.address, { gasLimit: 3000000  });
        await treasureHuntGame.connect(player1).startGame();
        await playerManager.connect(player1).movePlayer(3, 3, { gasLimit: 3000000  });
        
        const isTreasure = await blockManager.checkTreasure(player1.address);
        expect(isTreasure).to.be.a('boolean');
    });

    it("should check if a player finds a support package", async function () {
        await playerManager.connect(player1).joinGame(player1.address, { gasLimit: 3000000  });
        await treasureHuntGame.connect(player1).startGame();
        await playerManager.connect(player1).movePlayer(3, 3, { gasLimit: 3000000  });

        const isSupportPackage = await blockManager.checkSupportPackage(player1.address);
        expect(isSupportPackage).to.be.a('boolean');
    });

    it("should find the player's block index", async function () {
        await playerManager.connect(player1).joinGame(player1.address, { gasLimit: 3000000  });
        await treasureHuntGame.connect(player1).startGame();
        await playerManager.connect(player1).movePlayer(3, 3, { gasLimit: 3000000  });

        const blockIndex = await blockManager.checkFind(player1.address);
        expect(blockIndex).to.be.a('number');
    });
});
