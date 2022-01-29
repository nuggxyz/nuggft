//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';
import './stake.sol';
import './balance.sol';

contract expectLoan is base {
    expectStake stake;
    expectBalance balance;

    constructor() {
        stake = new expectStake();
        balance = new expectBalance();
    }

    struct Snapshot {
        uint256 agency;
    }

    struct Run {
        Snapshot[] snapshots;
        address sender;
        uint160 tokenId;
        uint96 eps;
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function exec(uint160[] memory tokenIds, lib.txdata memory txdata) public {
        this.start(tokenIds, txdata.from);
        forge.vm.startPrank(txdata.from);
        if (txdata.str.length > 0) forge.vm.expectRevert(txdata.str);
        nuggft.loan(tokenIds);
        forge.vm.stopPrank();
        txdata.str.length > 0 ? this.rollback() : this.stop();
    }

    function start(uint160[] memory tokenIds, address sender) public {
        require(execution.length == 0, 'EXPECT-LOAN:START: execution already esists');

        Run memory run;

        run.snapshots = new Snapshot[](tokenIds.length);

        run.sender = sender;

        run.eps = nuggft.eps();

        for (uint256 i = 0; i < tokenIds.length; i++) {
            Snapshot memory pre;

            run.tokenId = tokenIds[i];

            pre.agency = nuggft.agency(run.tokenId);

            ds.assertGt(pre.agency, 0, 'EXPECT-LOAN:START - agency should not be 0');

            run.snapshots[i] = pre;
        }

        balance.start(run.sender, run.eps * uint96(tokenIds.length), true);
        balance.start(address(nuggft), run.eps * uint96(tokenIds.length), false);

        stake.start(0, 0, true);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-LOAN:STOP: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            Snapshot memory pre = run.snapshots[i];
            Snapshot memory post;

            post.agency = nuggft.agency(run.tokenId);

            ds.assertEq(post.agency >> 254, 0x02, 'EXPECT-LOAN:STOP - agency flag should be LOAN - 0x02');
            ds.assertEq(nuggft.eps(), run.eps, 'EXPECT-LOAN:STOP - eps should not change');
        }

        // @todo - any other checks we want here?

        stake.stop();
        balance.stop();

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, 'EXPECT-LOAN:ROLLBACK: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            Snapshot memory pre = run.snapshots[i];
            Snapshot memory post;

            post.agency = nuggft.agency(run.tokenId);

            ds.assertEq(post.agency, pre.agency, 'EXPECT-LOAN:ROLLBACK - agency should be same');
        }

        stake.rollback();
        balance.rollback();

        this.clear();
    }
}
