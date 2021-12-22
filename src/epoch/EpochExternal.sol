// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IEpochExternal} from '../interfaces/nuggft/IEpochExternal.sol';

import {EpochCore} from '../epoch/EpochCore.sol';

abstract contract EpochExternal is IEpochExternal {
    constructor() {
        EpochCore.setGenesis();
        emit Genesis();
    }

    /// @inheritdoc IEpochExternal
    function epoch() external view override returns (uint32) {
        return EpochCore.activeEpoch();
    }
}
