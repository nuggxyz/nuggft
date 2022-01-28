//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';
import './stake.sol';
import './balance.sol';

contract expectMint is base {
    expectStake stake;
    expectBalance balance;

    constructor(RiggedNuggft nuggft_) base(nuggft_) {
        stake = new expectStake(nuggft_);
        balance = new expectBalance(nuggft_);
    }

    struct SnapshotData {
        uint256 agency;
    }

    struct SnapshotEnv {
        uint160 tokenId;
        uint96 value;
    }

    struct Snapshot {
        SnapshotEnv env;
        SnapshotData data;
    }

    struct Run {
        Snapshot snapshot;
        address sender;
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function exec(uint160 tokenId, lib.txdata memory txdata) public {
        forge.vm.deal(txdata.from, txdata.from.balance + txdata.value);
        this.start(tokenId, txdata.from, txdata.value);
        forge.vm.startPrank(txdata.from);
        if (txdata.str.length > 0) forge.vm.expectRevert(txdata.str);
        nuggft.mint{value: txdata.value}(tokenId);
        forge.vm.stopPrank();
        txdata.str.length > 0 ? this.rollback() : this.stop();
    }

    function start(
        uint160 tokenId,
        address sender,
        uint96 value
    ) public {
        require(execution.length == 0, 'EXPECT-MINT:START: execution already esists');

        Run memory run;

        run.sender = sender;

        SnapshotEnv memory env;
        SnapshotData memory pre;

        env.tokenId = tokenId;
        env.value = value;

        pre.agency = nuggft.agency(env.tokenId);

        ds.assertEq(pre.agency, 0, 'EXPECT-MINT:START - agency should be 0');

        balance.start(run.sender, env.value, false);
        balance.start(address(nuggft), env.value, true);

        stake.start(env.value, 1, true);

        run.snapshot.env = env;
        run.snapshot.data = pre;

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-MINT:STOP: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory pre = run.snapshot.data;
        SnapshotData memory post;

        post.agency = nuggft.agency(env.tokenId);

        ds.assertEq(pre.agency, 0, 'EXPECT-MINT:STOP - agency should not be 0');

        // @todo - any other checks we want here?

        stake.stop();
        balance.stop();

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, 'EXPECT-MINT:ROLLBACK: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory post;

        post.agency = nuggft.agency(env.tokenId);

        ds.assertEq(post.agency, 0, 'EXPECT-MINT:ROLLBACK - agency should be 0');

        stake.stop();
        balance.stop();

        this.clear();
    }
}
