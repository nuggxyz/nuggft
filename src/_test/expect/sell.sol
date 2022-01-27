//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import {expectBase} from './base.sol';

abstract contract expectSell is expectBase {
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

    function startExpectSell(
        uint160 sellingTokenId,
        uint16 itemId,
        uint96 floor,
        address sender
    ) internal {
        startExpectSell((uint160(itemId) << 24) | sellingTokenId, floor, sender);
    }

    function startExpectSell(
        uint160 tokenId,
        uint96 floor,
        address sender
    ) internal returns (bytes memory) {
        expectSell__Run memory run;

        run.sender = sender;

        run.expectedSenderBalance = cast.i192(run.sender.balance);
        run.expectedNuggftBalance = cast.i192(address(__nuggft__ref()).balance);

        expectSell__SnapshotEnv memory env;
        expectSell__SnapshotData memory pre;

        env.id = tokenId;
        env.isItem = env.id > 0xffffff;
        env.floor = floor;
        if (env.isItem) {
            env.buyer = address(tokenId >> 40);

            pre.agency = __nuggft__ref().external__itemAgency(env.id);
            pre.offer = __nuggft__ref().external__itemOffers(env.id, uint160(env.buyer));
        } else {
            env.buyer = sender;

            pre.agency = __nuggft__ref().external__agency(env.id);
            pre.offer = __nuggft__ref().external__offers(env.id, env.buyer);
        }

        if (pre.offer == 0) pre.offer = pre.agency;

        run.snapshot.env = env;
        run.snapshot.data = pre;

        preSellChecks(run, env, pre);

        preRunChecks(run);

        return abi.encode(run);
    }

    function stopExpectSell(bytes memory input) internal {
        expectSell__Run memory run = abi.decode(input, (expectSell__Run));

        expectSell__SnapshotEnv memory env = run.snapshot.env;
        expectSell__SnapshotData memory pre = run.snapshot.data;
        expectSell__SnapshotData memory post;

        if (env.isItem) {
            post.agency = __nuggft__ref().external__itemAgency(env.id);
            post.offer = __nuggft__ref().external__itemOffers(env.id, uint160(env.buyer));
        } else {
            post.agency = __nuggft__ref().external__agency(env.id);
            post.offer = __nuggft__ref().external__offers(env.id, env.buyer);
        }

        postSellChecks(run, env, pre, post);

        postRunChecks(run);
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
        // BALANCE CHANGE: sender balance should go up by the amount of the offer, __nuggft__ref's should go down
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

        // ASSERT:OFFER_0x0E: is the __nuggft__ref balance correct?
        assertBalance(address(__nuggft__ref()), run.expectedNuggftBalance, 'ASSERT:OFFER_0x0E');
    }
}
