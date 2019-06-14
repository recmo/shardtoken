pragma solidity >=0.4.21 <0.6.0;

contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor () internal {
        initializeOwnable(msg.sender);
    }

    function initializeOwnable(address newOwner) public {
        require(owner == address(0x0), "OWNABLE_ALREADY_INITIALIZED");
        owner = newOwner;
        emit OwnershipTransferred(address(0), owner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}