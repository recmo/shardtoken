pragma solidity >=0.4.21 <0.6.0;

import "contracts/Ancestry.sol";
import "contracts/Ownable.sol";

contract ShardToken is Ownable, Ancestry {

    uint256 public balance;
    mapping (address => uint256) public allowance;

    constructor(uint amount) public
        Ownable()
        Ancestry()
    {
        balance = amount;
    }

    // Allows anyone to create a new empty wallet for this token.
    function create()
        public
        returns (ShardToken new_wallet)
    {
        new_wallet = ShardToken(address(procreate()));
        new_wallet.initializeOwnable(msg.sender);
    }

    function destroy()
        public
        onlyOwner()
    {
        require(balance == 0, "NONZERO_BALANCE");
        selfdestruct(msg.sender);
    }

    // Transfer to some other wallet
    function transfer(
        ShardToken receipient,
        uint256 amount
    )
        public
        onlyOwner()
    {
        require(balance >= amount, "INSUFFICIENT_FUNDS");
        balance -= amount;
        receipient.receive(amount, BIRTH_CERTIFICATE);
    }

    function receive(
        uint256 amount,
        uint256[] memory birthCertificate
    )
        public
        onlyRelatives(birthCertificate)
    {
        balance += amount;

        // Should not happen because total supply guarantees an upper limit.
        require(balance >= amount, "BALANCE_OVERFLOW");
    }
}
