//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../utils/forge.sol";

import "./base.sol";

contract expectDonate is base {
    struct Run {
        int192 expected_stake_change;
        int192 expected_share_change;
        Snapshot pre;
        bool mint;
        bool burn;
    }

    struct Snapshot {
        int192 staked;
        int192 protocol;
        int192 shares;
        int192 msp;
        int192 eps;
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function start(uint96 eth) public {
        require(execution.length == 0, "EXPECT-DONATE:START: execution already exists");

        Run memory run;

        run.pre.staked = cast.i192(nuggft.staked());
        run.pre.protocol = cast.i192(nuggft.proto());
        run.pre.shares = cast.i192(nuggft.shares());
        run.pre.msp = cast.i192(nuggft.msp());
        run.pre.eps = cast.i192(nuggft.eps());

        ds.assertEq(run.pre.eps, run.pre.shares > 0 ? run.pre.staked / run.pre.shares : int256(0), "EPS is starting off with an incorrect value");

        run.expected_stake_change = cast.i192(eth);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, "EXPECT-DONATE:STOP: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        Snapshot memory pre = run.pre;

        Snapshot memory post;

        post.staked = cast.i192(nuggft.staked());
        post.protocol = cast.i192(nuggft.proto());
        post.shares = cast.i192(nuggft.shares());
        post.msp = cast.i192(nuggft.msp());
        post.eps = cast.i192(nuggft.eps());

        ds.assertEq(post.protocol, pre.protocol, "totalProtocol is not what is expected");
        ds.assertEq(post.staked, pre.staked + run.expected_stake_change, "staked change is not 90 percent of expected change");
        ds.assertEq(post.shares, pre.shares, "shares difference is not what is expected");
        ds.assertGe(post.eps, pre.eps, "eps is did not increase as expected");
        ds.assertGe(post.msp, pre.msp, "msp is did not increase as expected");

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, "EXPECT-DONATE:ROLLBACK - execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        Snapshot memory pre = run.pre;

        Snapshot memory post;

        post.staked = cast.i192(nuggft.staked());
        post.protocol = cast.i192(nuggft.proto());
        post.shares = cast.i192(nuggft.shares());
        post.msp = cast.i192(nuggft.msp());
        post.eps = cast.i192(nuggft.eps());

        ds.assertTrue(post.msp == pre.msp, "EXPECT-DONATE:ROLLBACK - msp()");
        ds.assertTrue(post.protocol == pre.protocol, "EXPECT-DONATE:ROLLBACK - proto()");
        ds.assertTrue(post.shares == pre.shares, "EXPECT-DONATE:ROLLBACK - shares()");
        ds.assertTrue(post.eps == pre.eps, "EXPECT-DONATE:ROLLBACK - eps()");
        ds.assertTrue(post.staked == pre.staked, "EXPECT-DONATE:ROLLBACK - staked()");

        this.clear();
    }
}
