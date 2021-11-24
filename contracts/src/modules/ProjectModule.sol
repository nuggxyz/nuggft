pragma solidity 0.8.4;

import '../storage/ProjectStorage.sol';
import '../libraries/ProjectLib.sol';

library ProjectModule {
    function createProject(
        address owner,
        bool is1155, // bit
        bool freeforall, // simple || d
        uint256 floor, // uint32
        uint256 startid, // uint32
        uint256 length, // uint32 - 0 for perpetual,
        uint256 startEpoch // simple
    ) internal returns (uint256 res) {
        res = uint256(0).setAccount(owner).setEpoch(startEpoch).setIs1155(is1155);
    }
}
