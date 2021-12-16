// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/storage.sol';

import {StakePure} from './pure.sol';

import {Stake} from './storage.sol';

library StakeView {
    using StakePure for uint256;

    function getActiveEthPerShare() internal view returns (uint256 res) {
        res = Stake.ptr().data;
        res = res.getStakedShares() == 0 ? 0 : res.getStakedEth() / res.getStakedShares();
    }

    function getActiveStakedShares() internal view returns (uint256 res) {
        res = Stake.ptr().data.getStakedShares();
    }

    function getActiveStakedEth() internal view returns (uint256 res) {
        res = Stake.ptr().data.getStakedEth();
    }
}
