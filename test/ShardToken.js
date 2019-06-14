const ShardToken = artifacts.require("ShardToken");
const truffleAssert = require('truffle-assertions');

contract("ShardToken", accounts => {
    it("should mint", async () => {
        const mint = await ShardToken.new(1000000);
        assert.equal((await mint.balance()).toNumber(), 1000000);
    });

    it("should transfer", async () => {
        const mint = await ShardToken.new(1000000);
        assert.equal((await mint.balance()).toNumber(), 1000000);
        
        const wallet1tx = await mint.create();
        const wallet1 = await ShardToken.at(wallet1tx.logs[0].args.child);
        assert.equal((await wallet1.balance()).toNumber(), 0);

        const wallet2tx = await mint.create();
        const wallet2 = await ShardToken.at(wallet2tx.logs[0].args.child);
        assert.equal((await wallet2.balance()).toNumber(), 0);

        const wallet21tx = await wallet2.create();
        const wallet21 = await ShardToken.at(wallet21tx.logs[0].args.child);
        assert.equal((await wallet21.balance()).toNumber(), 0);

        await mint.transfer(wallet1.address, 100);
        assert.equal((await mint.balance()).toNumber(), 999900);
        assert.equal((await wallet1.balance()).toNumber(), 100);

        await mint.transfer(wallet2.address, 50);
        assert.equal((await mint.balance()).toNumber(), 999850);
        assert.equal((await wallet2.balance()).toNumber(), 50);

        await wallet1.transfer(wallet2.address, 50);
        assert.equal((await wallet1.balance()).toNumber(), 50);
        assert.equal((await wallet2.balance()).toNumber(), 100);

        await wallet1.transfer(wallet21.address, 50);
        assert.equal((await wallet1.balance()).toNumber(), 0);
        assert.equal((await wallet21.balance()).toNumber(), 50);

        await wallet21.transfer(mint.address, 50);
        assert.equal((await wallet21.balance()).toNumber(), 0);
        assert.equal((await mint.balance()).toNumber(), 999900);
    });

    it("should not mix mints", async () => {
        const mintA = await ShardToken.new(1000000);
        assert.equal((await mintA.balance()).toNumber(), 1000000);

        const mintB = await ShardToken.new(1000000);
        assert.equal((await mintB.balance()).toNumber(), 1000000);

        await truffleAssert.reverts(
            mintA.transfer(mintB.address, 100),
            "NOT_RELATED"
        );

        const walletAtx = await mintA.create();
        const walletA = await ShardToken.at(walletAtx.logs[0].args.child);
        const walletBtx = await mintB.create();
        const walletB = await ShardToken.at(walletBtx.logs[0].args.child);

        await truffleAssert.reverts(
            mintB.transfer(walletA.address, 100),
            "NOT_RELATED"
        );

        await mintA.transfer(walletA.address, 100);
        assert.equal((await walletA.balance()).toNumber(), 100);

        await truffleAssert.reverts(
            mintA.transfer(walletB.address, 100),
            "NOT_RELATED"
        );

        await mintB.transfer(walletB.address, 100);
        assert.equal((await walletB.balance()).toNumber(), 100);

        await truffleAssert.reverts(
            walletA.transfer(walletB.address, 100),
            "NOT_RELATED"
        );
        await truffleAssert.reverts(
            walletB.transfer(walletA.address, 100),
            "NOT_RELATED"
        );
        await truffleAssert.reverts(
            mintB.transfer(walletA.address, 100),
            "NOT_RELATED"
        );
    });
});
