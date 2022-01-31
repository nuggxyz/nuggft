//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';
import './stake.sol';
import './balance.sol';
import {Expect} from './Expect.sol';

contract expectOffer is base {
    expectStake stake;
    expectBalance balance;
    Expect creator;

    constructor() {
        stake = new expectStake();
        balance = new expectBalance();
        creator = Expect(msg.sender);
    }

    lib.txdata prepped;

    function from(address user) public returns (expectOffer) {
        prepped.from = user;
        return this;
    }

    function value(uint96 val) public returns (expectOffer) {
        prepped.value = val;
        return this;
    }

    function err(bytes memory b) public returns (expectOffer) {
        prepped.err = b;
        return this;
    }

    function err(bytes1 b) public returns (expectOffer) {
        prepped.err = new bytes(1);
        prepped.err[0] = b;
        return this;
    }

    function g() public returns (expectOffer) {
        prepped.from = creator._globalFrom();
        return this;
    }

    function exec(uint160 tokenId) public payable {
        lib.txdata memory _prepped = prepped;
        _prepped.value += uint96(msg.value);

        delete prepped;
        exec(tokenId, _prepped);
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
        uint96 value;
        bool mintingNugg;
        uint24 epoch;
        uint96 increment;
        uint96 eps;
        uint96 msp;
    }

    struct Run {
        Snapshot snapshot;
        address sender;
        int192 expectedSenderBalance;
        int192 expectedNuggftBalance;
    }

    function exec(uint160 tokenId, lib.txdata memory txdata) public {
        forge.vm.deal(txdata.from, txdata.from.balance + txdata.value);
        this.start(tokenId, txdata.from, txdata.value);
        forge.vm.startPrank(txdata.from);
        if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
        nuggft.offer{value: txdata.value}(tokenId);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function exec(
        uint160 buyingTokenId,
        uint160 sellingTokenId,
        uint16 itemId,
        lib.txdata memory txdata
    ) public {
        forge.vm.deal(txdata.from, txdata.from.balance + txdata.value);
        this.start(buyingTokenId, sellingTokenId, itemId, txdata.from, txdata.value);
        forge.vm.startPrank(txdata.from);
        if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
        nuggft.offer{value: txdata.value}(buyingTokenId, sellingTokenId, itemId);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function start(
        uint160 buyingTokenId,
        uint160 sellingTokenId,
        uint16 itemId,
        address sender,
        uint96 val
    ) public {
        this.start((buyingTokenId << 40) | (uint160(itemId) << 24) | sellingTokenId, sender, val);
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function start(
        uint160 tokenId,
        address sender,
        uint96 val
    ) public {
        require(execution.length == 0, 'EXPECT-OFFER:START: execution already esists');

        Run memory run;

        run.sender = sender;

        SnapshotEnv memory env;
        SnapshotData memory pre;

        env.id = tokenId;
        env.isItem = env.id > 0xffffff;
        env.value = val;
        env.epoch = nuggft.epoch();
        env.mintingNugg = env.id == env.epoch;
        env.eps = nuggft.eps();
        env.msp = nuggft.msp();

        if (env.isItem) {
            env.id = tokenId & 0xffffffffff;

            env.buyer = address(tokenId >> 40);
            pre.agency = nuggft.itemAgency(env.id);
            pre.offer = nuggft.itemOffers(env.id, uint160(env.buyer));
        } else {
            env.buyer = sender;
            pre.agency = nuggft.agency(env.id);
            pre.offer = nuggft.offers(env.id, env.buyer);
        }

        if (pre.offer == 0 && env.buyer == address(uint160(pre.agency))) pre.offer = pre.agency;

        env.increment = uint96((((pre.offer << 26) >> 186) * .1 gwei) + env.value - (((pre.agency << 26) >> 186) * .1 gwei));

        run.snapshot.env = env;
        run.snapshot.data = pre;

        balance.start(run.sender, env.value, false);
        balance.start(address(nuggft), env.value, true);
        stake.start(env.increment, env.mintingNugg && pre.agency == 0 ? 1 : 0, true);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-OFFER:STOP: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory pre = run.snapshot.data;
        SnapshotData memory post;

        if (env.isItem) {
            post.agency = nuggft.itemAgency(env.id);
            post.offer = nuggft.itemOffers(env.id, uint160(env.buyer));
        } else {
            post.agency = nuggft.agency(env.id);
            post.offer = nuggft.offers(env.id, env.buyer);
        }

        postOfferChecks(run, env, pre, post);

        balance.stop();
        stake.stop();

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, 'EXPECT-OFFER:STOP: execution does not exist');

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory pre = run.snapshot.data;
        SnapshotData memory post;

        if (env.isItem) {
            post.agency = nuggft.itemAgency(env.id);
            post.offer = nuggft.itemOffers(env.id, uint160(env.buyer));
        } else {
            post.agency = nuggft.agency(env.id);
            post.offer = nuggft.offers(env.id, env.buyer);
        }

        ds.assertEq(pre.agency, post.agency, "EXPECT-OFFER:ROLLBACK agency changed but shouldn't have");
        ds.assertEq(pre.offer, post.offer, "EXPECT-OFFER:ROLLBACK offer changed but shouldn't have");

        balance.rollback();
        stake.rollback();

        this.clear();
    }

    function postOfferChecks(
        Run memory run,
        SnapshotEnv memory env,
        SnapshotData memory pre,
        SnapshotData memory post
    ) private {
        ds.assertGt(nuggft.eps(), env.eps, "EXPECT-OFFER:STOP eps should be greater");
        ds.assertGt(nuggft.msp(), env.msp, "EXPECT-OFFER:STOP msp should be greater");
        // @todo sender should be highest offer
        if (env.isItem) {} else {}
    }
}
