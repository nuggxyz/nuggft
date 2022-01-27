//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';
import {RiggedNuggft} from '../NuggftV1.test.sol';

contract expectSell is base {
    constructor(RiggedNuggft nuggft_) base(nuggft_) {}

    struct expectSell__Snapshot {
        expectSell__SnapshotEnv env;
        expectSell__SnapshotData data;
    }

    struct expectSell__SnapshotData {
        uint256 agency;
        uint256 offer;
    }

    struct expectSell__SnapshotEnv {
        uint160 id;
        bool isItem;
        address buyer;
        uint96 floor;
    }

    struct expectSell__Run {
        expectSell__Snapshot snapshot;
        address sender;
        int192 expectedSenderBalance;
        int192 expectedNuggftBalance;
    }

    function clear() public {
        delete execution;
    }

    bytes execution;

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

        expectSell__Run memory run;

        run.sender = sender;

        run.expectedSenderBalance = cast.i192(run.sender.balance);
        run.expectedNuggftBalance = cast.i192(address(nuggft).balance);

        expectSell__SnapshotEnv memory env;
        expectSell__SnapshotData memory pre;

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

        preSellChecks(run, env, pre);

        preRunChecks(run);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-SELL:STOP: execution does not exist');

        expectSell__Run memory run = abi.decode(execution, (expectSell__Run));

        expectSell__SnapshotEnv memory env = run.snapshot.env;
        expectSell__SnapshotData memory pre = run.snapshot.data;
        expectSell__SnapshotData memory post;

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

    function preSellChecks(
        expectSell__Run memory run,
        expectSell__SnapshotEnv memory env,
        expectSell__SnapshotData memory pre
    ) private {
        if (env.isItem) {} else {}
    }

    function postSellChecks(
        expectSell__Run memory run,
        expectSell__SnapshotEnv memory env,
        expectSell__SnapshotData memory pre,
        expectSell__SnapshotData memory post
    ) private {
        // BALANCE CHANGE: sender balance should go up by the amount of the offer, nuggft's should go down
        run.expectedSenderBalance -= cast.i192(env.floor);
        run.expectedNuggftBalance += cast.i192(env.floor);

        if (env.isItem) {} else {}
    }

    function preRunChecks(expectSell__Run memory run) private {
        // ASSERT:OFFER_0x0C: what should the balances be before any call on claim?
        // ASSERT:OFFER_0x0C: maybe here we just check to see that the data is ok?
    }

    function postRunChecks(expectSell__Run memory run) private {
        // ASSERT:OFFER_0x0D: is the sender balance correct?
        assertBalance(run.sender, run.expectedSenderBalance, 'ASSERT:OFFER_0x0D');

        // ASSERT:OFFER_0x0E: is the nuggft balance correct?
        assertBalance(address(nuggft), run.expectedNuggftBalance, 'ASSERT:OFFER_0x0E');
    }
}
