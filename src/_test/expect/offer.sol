//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';
import './stake.sol';

contract expectOffer is base {
    expectStake stake;

    constructor(RiggedNuggft nuggft_) base(nuggft_) {
        stake = new expectStake(nuggft_);
    }

    struct expectOffer__Snapshot {
        expectOffer__SnapshotEnv env;
        expectOffer__SnapshotData data;
    }

    struct expectOffer__SnapshotData {
        uint256 agency;
        uint256 offer;
    }

    struct expectOffer__SnapshotEnv {
        uint160 id;
        bool isItem;
        address buyer;
        uint96 value;
    }

    struct expectOffer__Run {
        expectOffer__Snapshot snapshot;
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

        expectOffer__Run memory run;

        run.sender = sender;

        run.expectedSenderBalance = cast.i192(run.sender.balance);
        run.expectedNuggftBalance = cast.i192(address(nuggft).balance);

        expectOffer__SnapshotEnv memory env;
        expectOffer__SnapshotData memory pre;

        env.id = tokenId;
        env.isItem = env.id > 0xffffff;
        env.value = value;
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

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-OFFER:STOP: execution does not exist');

        expectOffer__Run memory run = abi.decode(execution, (expectOffer__Run));

        expectOffer__SnapshotEnv memory env = run.snapshot.env;
        expectOffer__SnapshotData memory pre = run.snapshot.data;
        expectOffer__SnapshotData memory post;

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
        expectOffer__Run memory run,
        expectOffer__SnapshotEnv memory env,
        expectOffer__SnapshotData memory pre
    ) private {
        if (env.isItem) {} else {}
    }

    function postOfferChecks(
        expectOffer__Run memory run,
        expectOffer__SnapshotEnv memory env,
        expectOffer__SnapshotData memory pre,
        expectOffer__SnapshotData memory post
    ) private {
        // BALANCE CHANGE: sender balance should go up by the amount of the offer, nuggft's should go down
        run.expectedSenderBalance -= cast.i192(env.value);
        run.expectedNuggftBalance += cast.i192(env.value);

        if (env.isItem) {} else {}
    }

    function preRunChecks(expectOffer__Run memory run) private {
        // ASSERT:OFFER_0x0C: what should the balances be before any call on claim?
        // ASSERT:OFFER_0x0C: maybe here we just check to see that the data is ok?
    }

    function postRunChecks(expectOffer__Run memory run) private {
        // ASSERT:OFFER_0x0D: is the sender balance correct?
        assertBalance(run.sender, run.expectedSenderBalance, 'ASSERT:OFFER_0x0D');

        // ASSERT:OFFER_0x0E: is the nuggft balance correct?
        assertBalance(address(nuggft), run.expectedNuggftBalance, 'ASSERT:OFFER_0x0E');
    }
}
