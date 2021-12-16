// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../libraries/ShiftLib.sol';

import './SwapShiftLib.sol';

library SwapStorage {
    using SwapShiftLib for uint256;

    struct History {
        State self;
        mapping(uint256 => State) items;
    }

    struct State {
        uint256 data;
        mapping(uint256 => mapping(uint160 => uint256)) offers;
    }

    function load(uint256 id, uint160 account) internal view returns (uint256 swapData, uint256 offerData) {
        swapData = Global.ptr().swaps[id];

        offerData = swapData == 0 || account == swapData.account() ? swapData : s.offers[swapData.epoch()][account];
    }

    function load(uint256 id, address account) internal view returns (uint256 swapData, uint256 offerData) {
        return load(id, uint160(account));
    }

    function load(
        uint256 id,
        uint160 account,
        uint256 epoch
    ) internal view returns (uint256 swapData, uint256 offerData) {
        swapData = Global.ptr().swaps[id];

        swapData = swapData.epoch() == epoch ? swapData : 0;

        offerData = swapData != 0 && account == swapData.account() ? swapData : s.offers[epoch][account];
    }

    function load(
        uint256 id,
        address account,
        uint256 epoch
    ) internal view returns (uint256 swapData, uint256 offerData) {
        return load(s, uint160(account), epoch);
    }
}
