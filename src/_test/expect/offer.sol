//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';
import './stake.sol';
import './balance.sol';

contract expectOffer is base {
    expectStake stake;
    expectBalance balance;

    constructor(RiggedNuggft nuggft_) base(nuggft_) {
        stake = new expectStake(nuggft_);
        balance = new expectBalance(nuggft_);
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
    }

    struct Run {
        Snapshot snapshot;
        address sender;
        int192 expectedSenderBalance;
        int192 expectedNuggftBalance;
    }

    function start(
        uint160 buyingTokenId,
        uint160 sellingTokenId,
        uint16 itemId,
        address sender,
        uint96 value
    ) public {
        this.start((buyingTokenId << 40) | (uint160(itemId) << 24) | sellingTokenId, sender, value);
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function start(
        uint160 tokenId,
        address sender,
        uint96 value
    ) public {
        require(execution.length == 0, 'EXPECT-OFFER:START: execution already esists');

        Run memory run;

        run.sender = sender;

        SnapshotEnv memory env;
        SnapshotData memory pre;

        env.id = tokenId;
        env.isItem = env.id > 0xffffff;
        env.value = value;
        env.epoch = nuggft.epoch();
        env.mintingNugg = env.id == env.epoch;

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

        preOfferChecks(run, env, pre);

        preRunChecks(run);

        balance.start(run.sender, env.value, false);
        balance.start(address(nuggft), env.value, true);
        stake.start(0, 0, true);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-OFFER:STOP: execution does not exist');

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

        postOfferChecks(run, env, pre, post);

        postRunChecks(run);

        this.clear();
    }

    function preOfferChecks(
        Run memory run,
        SnapshotEnv memory env,
        SnapshotData memory pre
    ) private {
        if (env.isItem) {} else {}
    }

    function postOfferChecks(
        Run memory run,
        SnapshotEnv memory env,
        SnapshotData memory pre,
        SnapshotData memory post
    ) private {
        if (env.isItem) {} else {}
    }

    function preRunChecks(Run memory run) private {
        // ASSERT:OFFER_0x0C: what should the balances be before any call on claim?
        // ASSERT:OFFER_0x0C: maybe here we just check to see that the data is ok?
    }

    function postRunChecks(Run memory run) private {
        balance.stop();
        stake.stop();
    }
}
