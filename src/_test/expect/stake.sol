//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import {expectBase} from './base.sol';

abstract contract expectStake is expectBase {
    struct expectStake__Run {
        int192 expected_stake_change;
        int192 expected_share_change;
        expectStake__Snapshot pre;
    }
    enum dir {
        down,
        up
    }

    struct expectStake__Snapshot {
        int192 staked;
        int192 protocol;
        int192 shares;
        int192 msp;
        int192 eps;
    }

    function startExpectStake(
        uint96 eth,
        uint64 shares,
        dir direction
    ) internal returns (bytes memory res) {
        expectStake__Run memory run;

        run.pre.staked = cast.i192(__nuggft__ref().staked());
        run.pre.protocol = cast.i192(__nuggft__ref().proto());
        run.pre.shares = cast.i192(__nuggft__ref().shares());
        run.pre.msp = cast.i192(__nuggft__ref().msp());
        run.pre.eps = cast.i192(__nuggft__ref().eps());

        assertEq(run.pre.eps, run.pre.shares > 0 ? run.pre.staked / run.pre.shares : int256(0), 'EPS is starting off with an incorrect value');

        run.expected_stake_change = cast.i192(eth) * (direction == dir.up ? int8(1) : int8(-1));
        run.expected_share_change = cast.i192(shares) * (direction == dir.up ? int8(1) : int8(-1));

        return abi.encode(run);
    }

    function stopExpectStake(bytes memory input) internal {
        expectStake__Run memory run = abi.decode(input, (expectStake__Run));

        expectStake__Snapshot memory pre = run.pre;

        expectStake__Snapshot memory post;

        post.staked = cast.i192(__nuggft__ref().staked());
        post.protocol = cast.i192(__nuggft__ref().proto());
        post.shares = cast.i192(__nuggft__ref().shares());
        post.msp = cast.i192(__nuggft__ref().msp());
        post.eps = cast.i192(__nuggft__ref().eps());

        assertTrue(post.msp >= pre.msp, 'msp is did not increase as expected');
        assertEq(post.protocol - pre.protocol, lib.take(10, run.expected_stake_change), 'totalProtocol is not what is expected');
        assertEq(
            post.staked - pre.staked,
            run.expected_stake_change - lib.take(10, run.expected_stake_change),
            'staked change is not 90 percent of expected change'
        );
        assertEq(post.shares - pre.shares, run.expected_share_change, 'shares difference is not what is expected');

        post.eps = cast.i192(__nuggft__ref().eps());
        assertEq(post.eps, post.shares > 0 ? post.staked / post.shares : int256(0), 'EPS is not ending with correct value');
    }
}
