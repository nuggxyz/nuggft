// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/storage.sol';

import {StakeView} from './view.sol';

import '../interfaces/INuggFT.sol';

abstract contract StakeExternal is IStakeExternal {
    using StakeView for Stake.Storage;

    function global() internal view virtual returns (Global.Storage storage);

    /*///////////////////////////////////////////////////////////////
                                  VIEW
    //////////////////////////////////////////////////////////////*/

    function totalSupply() public view override returns (uint256 res) {
        res = totalStakedShares();
    }

    function totalStakedShares() public view override returns (uint256 res) {
        res = global().getActiveStakedShares();
    }

    function totalStakedEth() public view override returns (uint256 res) {
        res = global().getActiveStakedEth();
    }

    function activeEthPerShare() public view override returns (uint256 res) {
        res = global().getActiveEthPerShare();
    }
}
