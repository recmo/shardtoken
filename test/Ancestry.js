const Ancestry = artifacts.require("Ancestry");

contract("Ancestry", accounts => {
    it("should procreate.", async () => {
        const instance = await Ancestry.new();
        const child1tx = await instance.procreate();
        const child1 = await Ancestry.at(child1tx.logs[0].args.child);
        const child2tx = await instance.procreate();
        const child2 = await Ancestry.at(child2tx.logs[0].args.child);
        const child21tx = await child2.procreate();
        const child21 = await Ancestry.at(child21tx.logs[0].args.child);

        assert.equal(await instance.PROGENITOR(), instance.address);
        assert.equal((await instance.next_nonce()).toNumber(), 3);
        assert.equal(await child1.PROGENITOR(), instance.address);
        assert.equal((await child1.BIRTH_CERTIFICATE(0)).toNumber(), 1);
        assert.equal((await child1.next_nonce()).toNumber(), 1);
        assert.equal(await child2.PROGENITOR(), instance.address);
        assert.equal((await child2.BIRTH_CERTIFICATE(0)).toNumber(), 2);
        assert.equal((await child2.next_nonce()).toNumber(), 2);
        assert.equal(await child21.PROGENITOR(), instance.address);
        assert.equal((await child21.BIRTH_CERTIFICATE(0)).toNumber(), 2);
        assert.equal((await child21.BIRTH_CERTIFICATE(1)).toNumber(), 1);
        assert.equal((await child21.next_nonce()).toNumber(), 1);
    });
});
