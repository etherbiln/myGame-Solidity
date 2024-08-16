const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("TreasureHuntGame", function () {
    let TreasureHuntGame, treasureHuntGame;
    let PlayerManager, BlockManager, TokenManager;
    let token, owner, addr1, addr2;

    const clueCost = ethers.utils.parseEther("0.1");
    const gameDuration = 3600; // 1 hour

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        // Deploy the token contract
        const Token = await ethers.getContractFactory("MyToken");
        // const initialSupply = ethers.utils.parseUnits("1000", 18); 

        token = await Token.deploy(1000);
        await token.deployed();

        // Deploy the PlayerManager, BlockManager, and TokenManager contracts
        PlayerManager = await ethers.getContractFactory("PlayerManager");
        BlockManager = await ethers.getContractFactory("BlockManager");
        TokenManager = await ethers.getContractFactory("TokenManager");

        // Deploy the main game contract
        TreasureHuntGame = await ethers.getContractFactory("TreasureHuntGame");
        treasureHuntGame = await TreasureHuntGame.deploy(token.address, clueCost, gameDuration);
        await treasureHuntGame.deployed();
    });
    // -/
    describe("Deployment", function () {
        it("Should set the correct owner", async function () {
            expect(await treasureHuntGame.owner()).to.equal(owner.address);
        });

        it("Should initialize with the correct game duration", async function () {
            expect(await treasureHuntGame.gameDuration()).to.equal(gameDuration);
        });
    });

    //.
    describe("Game mechanics", function () {
        it("Should allow a player to join the game", async function () {
            await treasureHuntGame.connect(addr1).joinGame();
            expect(await treasureHuntGame.getTotalPlayers()).to.equal(1);
        });

        it("Should not allow non-authorized users to start the game", async function () {
            await expect(treasureHuntGame.connect(addr1).startGame()).to.be.revertedWith("Not authorized");
        });

        it("Should allow the authorized user to start the game", async function () {
            await treasureHuntGame.connect(owner).startGame();
            expect(await treasureHuntGame.gameStartTime()).to.not.equal(0);
        });

        // it("Should allow player to move during the game", async function () {
        //     await treasureHuntGame.connect(owner).startGame();
        //     await treasureHuntGame.connect(addr1).joinGame();
        //     await treasureHuntGame.connect(addr1).movePlayer("north");

        //     // Add checks for player's position using playerManager's findLocation function
        // });

        it("Should not allow player to move after game is over", async function () {
            await treasureHuntGame.connect(owner).startGame();
            await network.provider.send("evm_increaseTime", [gameDuration + 1]);
            await network.provider.send("evm_mine");

            await expect(treasureHuntGame.connect(addr1).movePlayer("up")).to.be.revertedWith("Game is over");
        });
    });

    describe("Token interaction", function () {
    it("Should allow player to buy a clue with own token", async function () {
        await treasureHuntGame.connect(owner).startGame();
        await treasureHuntGame.connect(addr1).joinGame();

        // Önce addr1'e belirli miktarda token gönderiyoruz
        const initialTokenBalance = ethers.utils.parseUnits("1", 18); // Örnek olarak 1000 token
        await token.transfer(addr1.address, initialTokenBalance);

        // addr1'in bakiyesini kontrol edelim
        const addr1InitialBalance = await token.balanceOf(addr1.address);
        expect(addr1InitialBalance).to.equal(initialTokenBalance);

        // addr1, ipucu satın almak için tokeni onaylar
        await token.connect(addr1).approve(treasureHuntGame.address, clueCost);

        // addr1, ipucu satın alıyor
        await treasureHuntGame.connect(addr1).buyClue();

        // addr1'in bakiyesinin güncellenip güncellenmediğini kontrol edelim
        const addr1FinalBalance = await token.balanceOf(addr1.address);
        expect(addr1FinalBalance).to.equal(initialTokenBalance.sub(clueCost));

        // TokenManager veya ilgili state'in doğru şekilde güncellenip güncellenmediğini kontrol edin
        // Örneğin, TokenManager'dan clue purchase durumunu kontrol eden bir fonksiyon çağırın.
    });

    it("Should not allow player to claim support package without a package", async function () {
        await treasureHuntGame.connect(owner).startGame();

        // addr1, destek paketi olmadan destek paketi talep etmeye çalışıyor
        await expect(treasureHuntGame.connect(addr1).claimSupportPackage(addr1.address)).to.be.revertedWith("No support package available");
    });

    it("Should not allow player to claim treasure without a treasure", async function () {
        await treasureHuntGame.connect(owner).startGame();

        // addr1, hazine olmadan hazine talep etmeye çalışıyor
        await expect(treasureHuntGame.connect(addr1).claimTreasure(addr1.address)).to.be.revertedWith("No treasure available");
    });
});

describe("Authorized address", function () {
    it("Should allow owner to set a new authorized address", async function () {
        // addr1, yetkili adres olarak atanıyor
        await treasureHuntGame.connect(owner).setAuthorizedAddress(addr1.address);

        // Yetkili adresin doğru olarak ayarlandığını kontrol edin
        expect(await treasureHuntGame.authorizedAddress()).to.equal(addr1.address);
    });

    it("Should allow the new authorized address to start the game", async function () {
        // addr1, yetkili adres olarak atanıyor
        await treasureHuntGame.connect(owner).setAuthorizedAddress(addr1.address);

        // Yeni yetkili adres (addr1) oyunu başlatıyor
        await treasureHuntGame.connect(addr1).startGame();

        // Oyun başlama zamanının sıfırdan farklı olup olmadığını kontrol edin
        expect(await treasureHuntGame.gameStartTime()).to.not.equal(0);
    });
    });
});
