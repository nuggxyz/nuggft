pragma solidity 0.8.4;

import '../libraries/StorageLib.sol';

library StakeStorage {
    struct Bin {
        uint256 shares;
        mapping(address => uint256) owned;
    }

    function load() internal pure returns (Bin storage s) {
        uint256 ptr = StorageLib.pointer('Stake');
        assembly {
            s.slot := ptr
        }
    }
}
