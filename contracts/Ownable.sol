pragma solidity >=0.4.21 <0.6.0;

contract Ownable {

    address public owner;
    address public nextOwner;
    uint256 public nextOwnerTimeout;

    event OwnershipTransferProposed(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);

    /// NOTE: onlyOwner functions are blocked while ownership transfer is in progress.
    modifier onlyOwner() {
        require(nextOwner == address(0x0), "Ownable: transfer in progress");
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor () internal {
        initializeOwnable(msg.sender);
    }

    function initializeOwnable(address newOwner) public {
        require(owner == address(0x0), "OWNABLE_ALREADY_INITIALIZED");
        owner = newOwner;
        nextOwner = address(0x0);
        emit OwnershipAccepted(address(0), owner);
    }

    function transferOwnership(
        address newOwner,
        uint256 timeoutSec
    ) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != owner, "Ownable: new owner is the current owner");
        require(nextOwner == address(0), "Ownable: ownership transfer pending");
        emit OwnershipTransferProposed(owner, newOwner);
        nextOwner = newOwner;
        nextOwnerTimeout = block.timestamp + timeoutSec;
    }

    function acceptOwnership() public {
        require(nextOwner != address(0), "Ownable: no ownership transfer pending");
        require(msg.sender == nextOwner, "Ownable: caller is not the next owner");
        // Q: Require the transfer to be not expired?
        owner = nextOwner;
        nextOwner = address(0x0);
        nextOwnerTimeout = 0;
    }

    function revertOwnership() public {
        require(nextOwner != address(0), "Ownable: no ownership transfer pending");
        require(block.timestamp >= nextOwnerTimeout, "Ownable: ownership transfer not expired");
        require(msg.sender == owner, "Ownable: caller is not the current owner");
        nextOwner = address(0x0);
        nextOwnerTimeout = 0;
    }
}
