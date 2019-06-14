const Cloning = artifacts.require("Cloning");

contract("Cloning", accounts => {
    it("spawns.", async () => {
        const instance = await Cloning.new();
        const child = await instance.spawn();
        assert.equal(child.logs[0].event, 'cloned', "Cloning failed");
    });
});
