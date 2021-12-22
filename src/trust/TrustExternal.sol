// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ITrustExternal} from '../interfaces/nuggft/ITrustExternal.sol';

import {Trust} from './Trust.sol';

abstract contract TrustExternal is ITrustExternal {
    constructor() {
        Trust.Storage storage store;

        assembly {
            store.slot := 0x20002467
        }

        store.trusted[msg.sender] = true;

        emit TrustUpdated(msg.sender, true);
    }

    /// @inheritdoc ITrustExternal
    function setIsTrusted(address user, bool trust) external virtual override {
        Trust.check();

        Trust.Storage storage store;

        assembly {
            store.slot := 0x20002467
        }

        store.trusted[user] = trust;

        emit TrustUpdated(user, trust);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc ITrustExternal
    function trusted(address user) public view override returns (bool) {
        Trust.Storage storage store;

        assembly {
            store.slot := 0x20002467
        }

        return store.trusted[user];
    }
}
