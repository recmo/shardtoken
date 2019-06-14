pragma solidity >=0.4.21 <0.6.0;

/// TODO: This should ideally be natively supported by Solidity. The way this
///       works arround constructors using initialization functions is
///       hacky and error-prone.

contract Cloning {

    event cloned(address child);

    function codehash(address addr)
        public view
        returns (bytes32 result)
    {
        assembly {
            result := extcodehash(addr)
        }
    }

    /// Create a copy of a contract with all state set to zero.
    function clone(address original)
        public
        returns (address result)
    {
        assembly {
            // Write a trivial cloning constructor:
            //
            // extcodecopy(original, 0, 0, excodesize(original))
            // return(0, excodesize(original))
            //
            // 0x73 PUSH20 <original>     original
            // 0x80 DUP1                  original original
            // 0x3b EXTCODESIZE           size original
            // 0x3d RETURNDATASIZE        0 size original
            // 0x3d RETURNDATASIZE        0 0 size original
            // 0x83 DUP4                  original 0 0 size original
            // 0x3c EXTCODECOPY           original
            // 0x3b EXTCODESIZE           size
            // 0x3d RETURNDATASIZE        0 size original
            // 0xd3 RETURN
            //
            // 0x73_________ORIGINAL__ADDRESS______________803b3d3d833c3b3df3____
            mstore(0, or(
                shl(88, original),
                0x730000000000000000000000000000000000000000803b3d3d833c3b3df30000
            ))
            result := create(0, 0, 30)
        }
        require(original != result && codehash(original) == codehash(result), "CREATE failed");
        emit cloned(result);
    }

    /// Create a copy of the current contract with state set to zero.
    function spawn()
        public
        returns (address result)
    {
        return clone(address(this));
    }
}
