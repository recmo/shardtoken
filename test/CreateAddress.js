const CreateAddress = artifacts.require("CreateAddress");

contract("CreateAddress", accounts => {
    it("computes CREATE1 addresses.", async () => {
        const root = "0x6ac7ea33f8831ea9dcc53393aaa88b25a785dbf0";
        const children = [
            "0xcd234a471b72ba2f1ccf0a70fcaba648a5eecd8d", // Skipped
            "0x343c43a37d37dff08ae8c4a11544c718abb4fcf8",
            "0xf778b86fa74e846c4f0a1fbd1335fe81c00a0c91",
            "0xfffd933a0bc612844eaf0c6fe3e5b8e9b6c1d19c"
        ];
        const createAddressInstance = await CreateAddress.new();
        for(let i = 1; i < children.length; i++) {
            const address = children[i];
            const result = await createAddressInstance.create1(
                root, i
            );
            assert.equal(address, result.toLowerCase(), `Address for none ${i} incorrect`);
        }
    });
});
