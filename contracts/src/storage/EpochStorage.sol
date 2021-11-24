pragma solidity 0.8.4;

import '../libraries/StorageLib.sol';

library EpochStorage {
    struct Bin {
        mapping(uint256 => bytes32) seeds;
    }

    function load() internal pure returns (Bin storage s) {
        uint256 ptr = StorageLib.pointer('Epoch');
        assembly {
            s.slot := ptr
        }
    }
}
