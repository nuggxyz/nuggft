// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {IStakeExternal} from '../interfaces/INuggFT.sol';

import {StakeCore} from './StakeCore.sol';

abstract contract StakeExternal is IStakeExternal {
    using SafeCastLib for uint256;

    function migrateStake(uint160 tokenId) external override {
        StakeCore.migrateStakedShare(tokenId);
    }

    function withdrawStake(uint160 tokenId) external override {
        StakeCore.burnStakedShare(tokenId);
    }

    function verifiedMinSharePrice() external view override returns (uint96 res) {
        res = StakeCore.verifiedMinSharePrice();
    }

    function totalStakedShares() external view override returns (uint64 res) {
        res = StakeCore.activeStakedShares();
    }

    function totalStakedEth() external view override returns (uint96 res) {
        res = StakeCore.activeStakedEth();
    }

    function activeEthPerShare() external view override returns (uint96 res) {
        res = StakeCore.activeEthPerShare();
    }

    function totalProtocolEth() external view override returns (uint96 res) {
        res = StakeCore.activeProtocolEth();
    }

    function totalSupply() external view override returns (uint256 res) {
        res = StakeCore.activeStakedShares();
    }
}
