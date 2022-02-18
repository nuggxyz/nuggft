//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import '../utils/forge.sol';

import './base.sol';
import './stake.sol';
import './balance.sol';
import {Expect} from './Expect.sol';

contract expectRebalance is base {
    expectStake stake;
    expectBalance balance;
    Expect creator;

    constructor() {
        stake = new expectStake();
        balance = new expectBalance();
        creator = Expect(msg.sender);
    }

    lib.txdata prepped;

    function from(address user) public returns (expectRebalance) {
        prepped.from = user;
        return this;
    }

    function value(uint96 val) public returns (expectRebalance) {
        prepped.value = val;
        return this;
    }

    function err(bytes memory b) public returns (expectRebalance) {
        prepped.err = b;
        return this;
    }

    function err(bytes1 b) public returns (expectRebalance) {
        prepped.err = new bytes(1);
        prepped.err[0] = b;
        return this;
    }

    function g() public returns (expectRebalance) {
        prepped.from = creator._globalFrom();
        return this;
    }

    function exec(uint160[] memory tokenIds) public payable {
        lib.txdata memory _prepped = prepped;
        _prepped.value += uint96(msg.value);

        delete prepped;
        exec(tokenIds, _prepped);
    }

    struct Snapshot {
        uint256 agency;
        uint96 fee;
        uint96 earned;
    }

    struct Run {
        Snapshot[] snapshots;
        address sender;
        uint160 tokenId;
        uint96 eps;
        uint96 accFee;
        uint96 accEarned;
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function exec(uint160[] memory tokenIds, lib.txdata memory txdata) public {
        forge.vm.deal(txdata.from, txdata.from.balance + txdata.value);
        this.start(tokenIds, txdata.from);
        forge.vm.startPrank(txdata.from);
        if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
        nuggft.rebalance{value: txdata.value}(tokenIds);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function start(uint160[] memory tokenIds, address sender) public {
        require(execution.length == 0, 'EXPECT-REBALANCE:START: execution already esists');

        Run memory run;

        run.snapshots = new Snapshot[](tokenIds.length);

        run.sender = sender;

        run.eps = nuggft.eps();

        for (uint256 i = 0; i < tokenIds.length; i++) {
            Snapshot memory pre;

            run.tokenId = tokenIds[i];

            pre.agency = nuggft.agency(run.tokenId);

            uint96 agency__eth = uint96((pre.agency << 26) >> 186) * .1 gwei;

            pre.fee = agency__eth / nuggft.REBALANCE_FEE_BPS();
            pre.earned = run.eps - agency__eth;

            run.accFee += pre.fee;
            run.accEarned += pre.earned;

            run.snapshots[i] = pre;
        }

        if (run.accEarned >= run.accFee) {
            // if more was earned than the fee
            uint96 change = run.accEarned - run.accFee;
            balance.start(run.sender, change, true);
            balance.start(address(nuggft), change, false);
        } else {
            uint96 change = run.accFee - run.accEarned;
            balance.start(run.sender, change, false);
            balance.start(address(nuggft), change, true);
        }

        stake.start(run.accFee, 0, true);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-REBALANCE:STOP: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        uint96 postEps = nuggft.eps();

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            Snapshot memory pre = run.snapshots[i];
            Snapshot memory post;

            post.agency = nuggft.agency(run.tokenId);

            ds.assertEq(post.agency >> 254, 0x02, 'EXPECT-REBALANCE:STOP - agency flag should be LOAN - 0x02');

            ds.assertEq(address(uint160(post.agency)), address(uint160(pre.agency)), 'EXPECT-REBALANCE:STOP - agent should stay the same');

            ds.assertEq(uint96((post.agency << 26) >> 186), postEps / .1 gwei, 'EXPECT-REBALANCE:STOP - principal should be same as post EPS');
        }

        ds.assertGt(postEps, run.eps, 'EXPECT-REBALANCE:STOP - eps should be geater than before');

        // @todo - any other checks we want here?

        stake.stop();
        balance.stop();

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, 'EXPECT-REBALANCE:ROLLBACK: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        uint96 postEps = nuggft.eps();

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            Snapshot memory pre = run.snapshots[i];
            Snapshot memory post;

            post.agency = nuggft.agency(run.tokenId);

            ds.assertEq(post.agency, pre.agency, 'EXPECT-REBALANCE:ROLLBACK - agency should be same');
        }

        ds.assertEq(postEps, run.eps, 'EXPECT-REBALANCE:ROLLBACK - eps should be the same');

        stake.rollback();
        balance.rollback();

        this.clear();
    }
}
