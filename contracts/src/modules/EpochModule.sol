pragma solidity 0.8.4;

import '../storage/EpochStorage.sol';
import '../libraries/EpochLib.sol';

library EpochModule {
    function setSeed()
        internal
        returns (
            bytes32 seed,
            uint256 epoch,
            uint256 blocknum
        )
    {
        blocknum = block.number;
        (seed, epoch) = EpochLib.calculateSeed(blocknum);
        EpochStorage.load().seeds[epoch] = seed;
    }
}
