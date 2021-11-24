pragma solidity 0.8.4;

import '../libraries/StorageLib.sol';

library ProjectStorage {
    struct Bin {
        uint256 data;
    }

    function load() internal pure returns (Bin storage s) {
        uint256 ptr = StorageLib.pointer('Project');
        assembly {
            s.slot := ptr
        }
    }
}
