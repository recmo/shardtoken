const ShardToken = artifacts.require("ShardToken");

contract("ShardToken", accounts => {
    it("should procreate.", async () => {
        const mint = await ShardToken.new(1000000);
        assert.equal((await mint.balance()).toNumber(), 1000000);
        
        const wallet1tx = await mint.create();
        const wallet1 = await ShardToken.at(wallet1tx.logs[0].args.child);
        assert.equal((await wallet1.balance()).toNumber(), 0);

        const wallet2tx = await mint.create();
        const wallet2 = await ShardToken.at(wallet2tx.logs[0].args.child);
        assert.equal((await wallet2.balance()).toNumber(), 0);

        await mint.transfer(wallet1.address, 100);
        assert.equal((await mint.balance()).toNumber(), 999900);
        assert.equal((await wallet1.balance()).toNumber(), 100);

        await mint.transfer(wallet2.address, 50);
        assert.equal((await mint.balance()).toNumber(), 999850);
        assert.equal((await wallet2.balance()).toNumber(), 50);

        await wallet1.transfer(wallet2.address, 50);
        assert.equal((await wallet1.balance()).toNumber(), 50);
        assert.equal((await wallet2.balance()).toNumber(), 100);
    });
});
