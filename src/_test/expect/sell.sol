//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';
import './stake.sol';
import './balance.sol';

contract expectSell is base {
    expectStake stake;
    expectBalance balance;

    constructor() {
        stake = new expectStake();
        balance = new expectBalance();
    }

    lib.txdata prepped;

    function from(address user) public returns (expectSell) {
        prepped.from = user;
        return this;
    }

    function value(uint96 val) public returns (expectSell) {
        prepped.value = val;
        return this;
    }

    function err(bytes memory b) public returns (expectSell) {
        prepped.err = b;
        return this;
    }

    function exec(uint160 tokenId, uint96 floor) public {
        lib.txdata memory _prepped = prepped;
        delete prepped;
        exec(tokenId, floor, _prepped);
    }

    struct Snapshot {
        SnapshotEnv env;
        SnapshotData data;
    }

    struct SnapshotData {
        uint256 agency;
        uint256 offer;
    }

    struct SnapshotEnv {
        uint160 id;
        bool isItem;
        address buyer;
        uint96 floor;
    }

    struct Run {
        Snapshot snapshot;
        address sender;
        int192 expectedSenderBalance;
        int192 expectedNuggftBalance;
    }

    function clear() public {
        delete execution;
    }

    bytes execution;

    function exec(
        uint160 tokenId,
        uint96 floor,
        lib.txdata memory txdata
    ) public {
        this.start(tokenId, floor, txdata.from);
        forge.vm.startPrank(txdata.from);
        if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
        nuggft.sell(tokenId, floor);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function exec(
        uint160 sellingTokenId,
        uint16 itemId,
        uint96 floor,
        lib.txdata memory txdata
    ) public {
        this.start(sellingTokenId, itemId, floor, txdata.from);
        forge.vm.startPrank(txdata.from);
        if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
        nuggft.sell(sellingTokenId, itemId, floor);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function start(
        uint160 sellingTokenId,
        uint16 itemId,
        uint96 floor,
        address sender
    ) public {
        this.start((uint160(itemId) << 24) | sellingTokenId, floor, sender);
    }

    function start(
        uint160 tokenId,
        uint96 floor,
        address sender
    ) public {
        require(execution.length == 0, 'EXPECT-SELL:START: execution already esists');

        Run memory run;

        run.sender = sender;

        run.expectedSenderBalance = cast.i192(run.sender.balance);
        run.expectedNuggftBalance = cast.i192(address(nuggft).balance);

        SnapshotEnv memory env;
        SnapshotData memory pre;

        env.id = tokenId;
        env.isItem = env.id > 0xffffff;
        env.floor = floor;
        if (env.isItem) {
            env.buyer = address(tokenId >> 40);

            pre.agency = nuggft.external__itemAgency(env.id);
            pre.offer = nuggft.external__itemOffers(env.id, uint160(env.buyer));
        } else {
            env.buyer = sender;

            pre.agency = nuggft.external__agency(env.id);
            pre.offer = nuggft.external__offers(env.id, env.buyer);
        }

        if (pre.offer == 0) pre.offer = pre.agency;

        run.snapshot.env = env;
        run.snapshot.data = pre;

        balance.start(sender, 0, true);
        balance.start(address(nuggft), 0, true);

        stake.start(0, 0, true);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-SELL:STOP: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory pre = run.snapshot.data;
        SnapshotData memory post;

        if (env.isItem) {
            post.agency = nuggft.external__itemAgency(env.id);
            post.offer = nuggft.external__itemOffers(env.id, uint160(env.buyer));
        } else {
            post.agency = nuggft.external__agency(env.id);
            post.offer = nuggft.external__offers(env.id, env.buyer);
        }

        postSellChecks(run, env, pre, post);

        postRunChecks(run);

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, 'EXPECT-SELL:ROLLBACK: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory pre = run.snapshot.data;
        SnapshotData memory post;

        if (env.isItem) {
            post.agency = nuggft.external__itemAgency(env.id);
            post.offer = nuggft.external__itemOffers(env.id, uint160(env.buyer));
        } else {
            post.agency = nuggft.external__agency(env.id);
            post.offer = nuggft.external__offers(env.id, env.buyer);
        }

        ds.assertEq(pre.agency, post.agency, "EXPECT-SELL:ROLLBACK agency changed but shouldn't have");
        ds.assertEq(pre.offer, post.offer, "EXPECT-SELL:ROLLBACK offer changed but shouldn't have");

        this.clear();
    }

    function postSellChecks(
        Run memory run,
        SnapshotEnv memory env,
        SnapshotData memory pre,
        SnapshotData memory post
    ) private {
        if (env.isItem) {} else {}
    }

    function postRunChecks(Run memory run) private {}
}
