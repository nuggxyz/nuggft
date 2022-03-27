//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../utils/forge.sol";

import "./base.sol";

import "../../core/NuggftV1Constants.sol";

contract expectStake is base, NuggftV1Constants {
    struct Run {
        int192 expected_stake_change;
        int192 expected_share_change;
        Snapshot pre;
        bool mint;
        bool burn;
        bool mintOverpay;
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

    function start(
        uint96 eth,
        uint64 shares,
        bool up
    ) public {
        require(execution.length == 0, "EXPECT-STAKE:START: execution already exists");

        Run memory run;

        run.pre.staked = cast.i192(nuggft.staked());
        run.pre.protocol = cast.i192(nuggft.proto());
        run.pre.shares = cast.i192(nuggft.shares());
        run.pre.msp = cast.i192(nuggft.msp());
        run.pre.eps = cast.i192(nuggft.eps());

        ds.assertEq(run.pre.eps, run.pre.shares > 0 ? run.pre.staked / run.pre.shares : int256(0), "EPS is starting off with an incorrect value");

        run.burn = !up;

        run.expected_stake_change = cast.i192(eth) * (run.burn ? int8(-1) : int8(1));
        run.expected_share_change = cast.i192(shares) * (run.burn ? int8(-1) : int8(1));

        if (run.expected_share_change > 0) {
            run.mint = true;
        }

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, "EXPECT-STAKE:STOP: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        Snapshot memory pre = run.pre;

        Snapshot memory post;

        post.staked = cast.i192(nuggft.staked());
        post.protocol = cast.i192(nuggft.proto());
        post.shares = cast.i192(nuggft.shares());
        post.msp = cast.i192(nuggft.msp());
        post.eps = cast.i192(nuggft.eps());

        int256 expectedProto = 0;

        int192 protofee = int192(int256(uint256(PROTOCOL_FEE_FRAC)));

        if (run.burn) {
            ds.assertLe(post.msp, pre.msp, "msp should have decreased");
        } else {
            ds.assertGe(post.msp, pre.msp, "msp is did not increase as expected");
            expectedProto = run.expected_stake_change / protofee;
        }

        if (run.mint) {
            int192 fee = pre.eps / int192(int256(uint256(PROTOCOL_FEE_FRAC_MINT)));
            int192 overpay = run.expected_stake_change - pre.msp;
            fee += overpay / int192(int256(uint256(PROTOCOL_FEE_FRAC_MINT_DIV)));
            expectedProto = fee;
        }

        int256 expectedStake = run.expected_stake_change - expectedProto;

        ds.assertEq(post.protocol - pre.protocol, expectedProto, "totalProtocol is not what is expected");
        ds.assertEq(post.staked - pre.staked, expectedStake, "staked change is not 90 percent of expected change");
        ds.assertEq(post.shares - pre.shares, run.expected_share_change, "shares difference is not what is expected");
        ds.assertEq(post.eps, post.shares > 0 ? post.staked / post.shares : int256(0), "EPS is not ending with correct value");

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, "EXPECT-STAKE:ROLLBACK - execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        Snapshot memory pre = run.pre;

        Snapshot memory post;

        post.staked = cast.i192(nuggft.staked());
        post.protocol = cast.i192(nuggft.proto());
        post.shares = cast.i192(nuggft.shares());
        post.msp = cast.i192(nuggft.msp());
        post.eps = cast.i192(nuggft.eps());

        ds.assertTrue(post.msp == pre.msp, "EXPECT-STAKE:ROLLBACK - msp()");
        ds.assertTrue(post.protocol == pre.protocol, "EXPECT-STAKE:ROLLBACK - proto()");
        ds.assertTrue(post.shares == pre.shares, "EXPECT-STAKE:ROLLBACK - shares()");
        ds.assertTrue(post.eps == pre.eps, "EXPECT-STAKE:ROLLBACK - eps()");
        ds.assertTrue(post.staked == pre.staked, "EXPECT-STAKE:ROLLBACK - staked()");

        this.clear();
    }
}
