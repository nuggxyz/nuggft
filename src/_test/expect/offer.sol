//SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "../utils/forge.sol";

import "./base.sol";
import "./stake.sol";
import "./balance.sol";
import {Expect} from "./Expect.sol";

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
        prepped.err = abi.encodePacked(bytes4(0x7e863b48), b);
        return this;
    }

    function g() public returns (expectOffer) {
        prepped.from = creator._globalFrom();
        return this;
    }

    function exec(
        uint24 buyingTokenId,
        uint24 sellingTokenId,
        uint16 itemId
    ) public payable {
        lib.txdata memory _prepped = prepped;
        _prepped.value += uint96(msg.value);

        delete prepped;
        exec(buyingTokenId, sellingTokenId, itemId, _prepped);
    }

    function exec(uint24 tokenId) public payable {
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
        uint256 trueoffer;
    }

    struct SnapshotEnv {
        uint40 id;
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

    function exec(uint24 tokenId, lib.txdata memory txdata) public {
        forge.vm.deal(txdata.from, txdata.from.balance + txdata.value);
        this.start(tokenId, txdata.from, txdata.value);
        forge.vm.startPrank(txdata.from);
        if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
        nuggft.offer{value: txdata.value}(tokenId);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function exec(
        uint24 buyingTokenId,
        uint24 sellingTokenId,
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
        uint24 buyingTokenId,
        uint24 sellingTokenId,
        uint16 itemId,
        address sender,
        uint96 val
    ) public {
        this.start((uint64(buyingTokenId) << 40) | (uint64(itemId) << 24) | uint64(sellingTokenId), sender, val);
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function start(
        uint64 tokenId,
        address sender,
        uint96 val
    ) public {
        require(execution.length == 0, "EXPECT-OFFER:START: execution already esists");

        Run memory run;

        run.sender = sender;

        SnapshotEnv memory env;
        SnapshotData memory pre;

        env.isItem = tokenId > 0xffffff;
        env.value = val;
        env.epoch = nuggft.epoch();
        env.mintingNugg = tokenId == env.epoch;
        env.eps = nuggft.eps();
        env.msp = nuggft.msp();
        env.id = uint40(tokenId);

        if (env.isItem) {
            env.buyer = address(uint160(tokenId >> 40));
            pre.agency = nuggft.itemAgency(safe.u24(env.id & 0xffffff), uint16(env.id >> 24));
            pre.offer = nuggft.itemOffers(safe.u24(env.buyer), safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
        } else {
            env.buyer = sender;
            pre.agency = nuggft.agency(safe.u24(env.id));
            pre.offer = nuggft.offers(safe.u24(env.id), env.buyer);
        }

        pre.trueoffer = pre.offer;

        if (pre.offer == 0 && env.buyer == address(uint160(pre.agency))) pre.offer = pre.agency;

        if (env.value > 0) {
            uint96 A = uint96(((pre.offer << 26) >> 186) * .1 gwei) + env.value;
            uint96 B = uint96(((pre.agency << 26) >> 186) * .1 gwei);
            if (A >= B)
                env.increment = A - B;
                // this way it fails unless there is a rollback
            else env.increment = type(uint96).max;
            // env.increment = uint96((((pre.offer << 26) >> 186) * .1 gwei) + env.value - (((pre.agency << 26) >> 186) * .1 gwei));
        }

        run.snapshot.env = env;
        run.snapshot.data = pre;

        balance.start(run.sender, env.value, false);
        balance.start(address(nuggft), env.value, true);
        stake.start(env.increment, env.mintingNugg && pre.agency == 0 ? 1 : 0, true);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, "EXPECT-OFFER:STOP: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory pre = run.snapshot.data;
        SnapshotData memory post;

        if (env.isItem) {
            post.agency = nuggft.itemAgency(safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
            post.offer = nuggft.itemOffers(safe.u24(env.buyer), safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
        } else {
            post.agency = nuggft.agency(safe.u24(env.id));
            post.offer = nuggft.offers(safe.u24(env.id), env.buyer);
        }

        postOfferChecks(run, env, pre, post);

        balance.stop();
        stake.stop();

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, "EXPECT-OFFER:STOP: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory pre = run.snapshot.data;
        SnapshotData memory post;

        if (env.isItem) {
            post.agency = nuggft.itemAgency(safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
            post.offer = nuggft.itemOffers(safe.u24(env.buyer), safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
        } else {
            post.agency = nuggft.agency(safe.u24(env.id));
            post.offer = nuggft.offers(safe.u24(env.id), env.buyer);
        }

        ds.assertEq(pre.agency, post.agency, "EXPECT-OFFER:ROLLBACK agency changed but shouldn't have");
        ds.assertEq(pre.trueoffer, post.offer, "EXPECT-OFFER:ROLLBACK offer changed but shouldn't have");

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
        if (env.eps == 0) {
            ds.assertGe(nuggft.eps(), env.eps, "EXPECT-OFFER:STOP eps should be gte");
            ds.assertGe(nuggft.msp(), env.msp, "EXPECT-OFFER:STOP msp should be gte");
        } else {
            ds.assertGt(nuggft.eps(), env.eps, "EXPECT-OFFER:STOP eps should be greater");
            ds.assertGt(nuggft.msp(), env.msp, "EXPECT-OFFER:STOP msp should be greater");
        }

        // @todo sender should be highest offer
        if (env.isItem) {} else {}
    }
}
