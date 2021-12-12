// SPDX-License-Identifier: MIT

import '../libraries/ShiftLib.sol';
import '../libraries/QuadMath.sol';

import './SwapType.sol';

library Swap {
    using SwapType for uint256;

    struct History {
        Storage self;
        mapping(uint256 => Storage) items;
    }

    struct Storage {
        uint256 data;
        mapping(uint256 => mapping(uint160 => uint256)) offers;
    }

    function loadStorage(Storage storage s, address account) internal view returns (uint256 swapData, uint256 offerData) {
        return loadStorage(s, uint160(account));
    }

    function loadStorage(
        Storage storage s,
        address account,
        uint256 epoch
    ) internal view returns (uint256 swapData, uint256 offerData) {
        return loadStorage(s, uint160(account), epoch);
    }

    function loadStorage(Storage storage s, uint160 account) internal view returns (uint256 swapData, uint256 offerData) {
        swapData = s.data;

        offerData = swapData == 0 || account == swapData.account() ? swapData : s.offers[swapData.epoch()][account];
    }

    function loadStorage(
        Storage storage s,
        uint160 account,
        uint256 epoch
    ) internal view returns (uint256 swapData, uint256 offerData) {
        swapData = s.data;

        swapData = swapData.epoch() == epoch ? swapData : 0;

        offerData = swapData != 0 && account == swapData.account() ? swapData : s.offers[epoch][account];
    }

    function checkClaimer(
        uint160 account,
        uint256 swapData,
        uint256 offerData,
        uint256 activeEpoch
    ) internal pure returns (bool winner) {
        require(offerData != 0, 'SL:CC:1');

        bool over = activeEpoch > swapData.epoch();

        return swapData.isOwner() || (account == swapData.account() && over);
    }

    // function points(uint256 total, uint256 bps) internal pure returns (uint256 res) {
    //     res = QuadMath.mulDiv(total, bps, 10000);
    // }

    // function pointsWith(uint256 total, uint256 bps) internal pure returns (uint256 res) {
    //     res = points(total, bps) + total;
    // }

    // function itemTokenId(uint256 itemid, uint256 tokenid) internal pure returns (uint256 res) {
    //     res = (tokenid << 16) | itemid;
    // }

    // function tokenIdToAddress(uint256 tokenid) internal pure returns (address res) {
    //     res = address(uint160((0x42069 << 140) | tokenid));
    // }

    // function addressToTokenId(address addr) internal pure returns (uint256 res) {
    //     res = uint136(uint160(addr));
    // }

    // function isTokenIdAddress(address addr) internal view returns (bool res) {
    //     if (uint160(addr) >> 80 == 0x42069 << 60) return true;
    // }
}
