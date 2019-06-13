pragma solidity >=0.4.21 <0.6.0;

// https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed
// https://github.com/projectchicago/gastoken/blob/master/contract/rlp.sol#L21
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1014.md

contract CreateAddress {
    
    /// Compute the child contract address for CREATE
    /// sha3(rlp_encode([parent, nonce]))[12:]
    function create1(
        address parent,
        uint256 nonce
    )
        public pure
        returns (address)
    {
        require(nonce > 0, "INVALID_NONCE");
        if (nonce <= 0x7f) {
            return address(uint160(uint256(keccak256(abi.encodePacked(
                uint8(0xd6), uint8(0x94), parent, uint8(nonce)
            )))));
        } else if (nonce <= 0xff) {
            return address(uint160(uint256(keccak256(abi.encodePacked(
                uint8(0xd7), uint8(0x94), parent, uint8(0x81), uint8(nonce)
            )))));
        } else if (nonce <= 0xffff) {
            return address(uint160(uint256(keccak256(abi.encodePacked(
                uint8(0xd8), uint8(0x94), parent, uint8(0x82), uint16(nonce)
            )))));
        } else {
            // TODO computed lengths
            revert("UNIMPLEMENTED_NONCE_SIZE");
        }
    }
}
