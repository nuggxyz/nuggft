//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';

contract expectBalance is base {
    constructor(RiggedNuggft nuggft_) base(nuggft_) {}

    struct expectBalance__Snapshot {
        address user;
        int192 expectedBalance;
    }

    expectBalance__Snapshot[] snapshots;

    function clear() public {
        delete snapshots;
    }

    function start(
        address user,
        uint96 value,
        bool up
    ) public {
        delete snapshots;

        snapshots.push(
            expectBalance__Snapshot({
                user: user, //
                expectedBalance: cast.i192(up ? user.balance + value : user.balance - value)
            })
        );
    }

    function stop() public {
        for (uint256 i = 0; i < snapshots.length; i++) {
            assertBalance(snapshots[i].user, snapshots[i].expectedBalance, 'stopExpectBalance ');
        }
        this.clear();
    }
}
