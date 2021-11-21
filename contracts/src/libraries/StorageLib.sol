library StorageLib {
    function pointer(string memory refA) internal pure returns (uint256 ptr) {
        assembly {
            ptr := mload(0x40)
            mstore(add(ptr, 0), refA)
            ptr := keccak256(ptr, 32)
        }
    }

    function pointer(uint256 refA, uint256 refB) internal pure returns (uint256 ptr) {
        assembly {
            ptr := mload(0x40)
            mstore(add(ptr, 0), refA)
            mstore(add(ptr, 32), refB)
            ptr := keccak256(ptr, 64)
        }
    }
}
