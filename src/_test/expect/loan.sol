//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../utils/forge.sol";

import "./base.sol";
import "./stake.sol";
import "./balance.sol";
import "./donate.sol";

import {Expect} from "./Expect.sol";

contract expectLoan is base {
    expectStake stake;
    expectBalance balance;
    // expectDonate donate;

    Expect creator;

    constructor() {
        stake = new expectStake();
        balance = new expectBalance();
        // donate = new expectDonate();

        creator = Expect(msg.sender);
    }

    lib.txdata prepped;

    function from(address user) public returns (expectLoan) {
        prepped.from = user;
        return this;
    }

    // function value(uint96 val) public returns (expectLoan) {
    //     prepped.value = val;
    //     return this;
    // }

    function err(bytes memory b) public returns (expectLoan) {
        prepped.err = b;
        return this;
    }

    function err(bytes1 b) public returns (expectLoan) {
        prepped.err = abi.encodePacked(bytes4(0x7e863b48), b);
        return this;
    }

    function exec(uint24[] memory tokenIds) public {
        lib.txdata memory _prepped = prepped;

        delete prepped;
        exec(tokenIds, _prepped);
    }

    function g() public returns (expectLoan) {
        prepped.from = creator._globalFrom();
        return this;
    }

    struct Snapshot {
        uint256 agency;
        uint24 tokenId;
    }

    struct Run {
        Snapshot[] snapshots;
        address sender;
        uint96 eps;
        uint96 msp;
        bool shouldDonate;
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function exec(uint24[] memory tokenIds, lib.txdata memory txdata) public {
        this.start(tokenIds, txdata.from);
        forge.vm.startPrank(txdata.from);
        if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
        nuggft.loan(tokenIds);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function start(uint24[] memory tokenIds, address sender) public {
        require(execution.length == 0, "EXPECT-LOAN:START: execution already esists");

        Run memory run;

        run.snapshots = new Snapshot[](tokenIds.length);

        run.sender = sender;

        run.eps = nuggft.eps();

        run.msp = nuggft.msp();

        run.shouldDonate = run.sender.code.length > 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            Snapshot memory pre;

            pre.tokenId = tokenIds[i];

            pre.agency = nuggft.agency(pre.tokenId);

            run.snapshots[i] = pre;
        }

        uint96 expectedReward = ((run.eps * uint96(tokenIds.length)) / .1 gwei) * .1 gwei;

        if (!run.shouldDonate) {
            stake.start(0, 0, true);
            balance.start(run.sender, expectedReward, true);
            balance.start(address(nuggft), expectedReward, false);
        } else {
            stake.start(expectedReward, 0, true);
            balance.start(run.sender, 0, true);
            balance.start(address(nuggft), 0, true);
        }

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, "EXPECT-LOAN:STOP: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            Snapshot memory pre = run.snapshots[i];
            Snapshot memory post;

            post.agency = nuggft.agency(pre.tokenId);

            ds.assertGt(pre.agency, 0, "EXPECT-LOAN:STOP - agency should not be 0");
            ds.assertEq(address(uint160(post.agency)), run.sender, "EXPECT-LOAN:STOP - sender should still be agent");
            ds.assertEq(post.agency >> 254, 0x02, "EXPECT-LOAN:STOP - agency flag should be LOAN - 0x02");

            if (!run.shouldDonate) {
                ds.assertEq(nuggft.eps(), run.eps, "EXPECT-LOAN:STOP - eps should not change");
                ds.assertEq(nuggft.msp(), run.msp, "EXPECT-LOAN:STOP - msp should not change");
            }
        }

        // @todo - any other checks we want here?

        stake.stop();
        balance.stop();

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, "EXPECT-LOAN:ROLLBACK: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            Snapshot memory pre = run.snapshots[i];
            Snapshot memory post;

            post.agency = nuggft.agency(pre.tokenId);

            ds.assertEq(post.agency, pre.agency, "EXPECT-LOAN:ROLLBACK - agency should be same");
        }

        stake.rollback();
        balance.rollback();

        this.clear();
    }
}
