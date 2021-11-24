pragma solidity 0.8.4;

import '../libraries/StorageLib.sol';

library RoyaltyStorage {
    struct Bin {
        uint256 fees;
        mapping(address => uint256) royalties;
    }

    function load() internal pure returns (Bin storage s) {
        uint256 ptr = StorageLib.pointer('Royalty');
        assembly {
            s.slot := ptr
        }
    }
}
