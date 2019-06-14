pragma solidity >=0.4.21 <0.6.0;

import "contracts/CreateAddress.sol";
import "contracts/Cloning.sol";

contract Ancestry is CreateAddress, Cloning {

    // The root of the family tree.
    address  public PROGENITOR;
    uint256[] public BIRTH_CERTIFICATE;
    uint256 public next_nonce;

    modifier onlyRelatives(uint256[] memory birthCerificate) {
        require(descends(PROGENITOR, msg.sender, birthCerificate), "NOT_RELATED");
        _;
    }

    // TODO: only_ancestors, only_parents, only_children, only_offspring, only_sibblings

    constructor()
        public
    {
        uint256[] memory genesis = new uint256[](0);
        initializeAncestry(address(0), genesis);
    }

    function initializeAncestry(
        address progenitor,
        uint256[] memory birthCerificate
    )
        public
    {
        require(PROGENITOR == address(0x0), "ANCESTRY_ALREADY_INITIALIZED");
        if (progenitor == address(0)) {
            progenitor = address(this);
        }
        require(descends(progenitor, address(this), birthCerificate), "INVALID_BIRTH_CERTIFICATE");
        PROGENITOR = progenitor;
        BIRTH_CERTIFICATE = birthCerificate;

        // Constract child nonces start at 1
        next_nonce = 1;
    }

    /// Check if a given contract is a sibbling
    /// @param progenitor The root of the family tree.
    /// @param descendant The constract address to check for membership in the family tree.
    /// @param birthCertificate Claimed proof of ancenstry.
    function descends(
        address progenitor,
        address  descendant,
        uint256[] memory birthCertificate
    )
        public pure
        returns (bool)
    {
        address relative = progenitor;
        for (uint256 i = 0; i < birthCertificate.length; ++i) {
            relative = create1(relative, birthCertificate[i]);
        }
        return relative == descendant;
    }

    /// Returns a clone of the current contract. All state is initialized
    /// zero except for the ancestry information.
    function procreate()
        public
        returns (Ancestry child)
    {
        child = Ancestry(spawn());
        child.initializeAncestry(
            PROGENITOR,
            issueBirthCertificate()
        );
    }

    /// Issues a birth certificate for the next child contract.
    /// NOTE: The birth certificate must be used in the next CREATE.
    /// NOTE: A birth certificate must be requested for each CREATE. 
    function issueBirthCertificate()
        private
        returns (uint256[] memory birthCertificate)
    {
        birthCertificate = new uint256[](BIRTH_CERTIFICATE.length + 1);

        // Copy over exsisting certificate
        for(uint256 i = 0; i < BIRTH_CERTIFICATE.length; ++i) {
            birthCertificate[i] = BIRTH_CERTIFICATE[i];
        }

        // Append new entry
        birthCertificate[BIRTH_CERTIFICATE.length] = next_nonce;

        // Increment CREATE nonce
        next_nonce += 1;
    }
}
