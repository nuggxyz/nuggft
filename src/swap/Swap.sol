// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../libraries/ShiftLib.sol';

import './SwapShiftLib.sol';

library Swap {
    using SwapShiftLib for uint256;

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
    ) internal view returns (bool winner) {
        require(offerData != 0, 'SL:CC:1');

        bool over = activeEpoch > swapData.epoch();

        return swapData.isOwner() || (account == swapData.account() && over);
    }
}
