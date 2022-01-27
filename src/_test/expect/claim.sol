//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import './base.sol';

abstract contract expectClaim is expectBase {
    function startExpectClaim(
        uint160[] memory tokenIds,
        uint160[] memory offerers,
        address sender
    ) internal {
        address[] memory a;
        assembly {
            a := offerers
        }
        startExpectClaim(tokenIds, a, sender);
    }

    struct expectClaim__Snapshot {
        expectClaim__SnapshotEnv env;
        expectClaim__SnapshotData data;
    }

    struct expectClaim__SnapshotData {
        uint256 agency;
        uint256 offer;
    }

    struct expectClaim__SnapshotEnv {
        uint160 id;
        bool isItem;
        bool winner;
        address buyer;
        bool reclaim;
    }

    struct expectClaim__RunBalances {
        address account;
        int192 change;
    }

    struct expectClaim__Run {
        expectClaim__Snapshot[] snapshots;
        address sender;
        int192 expectedSenderBalance;
        int192 expectedNuggftBalance;
    }

    function startExpectClaim(
        uint160[] memory tokenIds,
        address[] memory offerers,
        address sender
    ) internal returns (bytes memory) {
        require(tokenIds.length == offerers.length, 'EXPECT-CLAIM:START:ArrayLengthNotSame');

        expectClaim__Run memory run;

        run.sender = sender;
        run.snapshots = new expectClaim__Snapshot[](tokenIds.length);
        run.expectedSenderBalance = cast.i192(run.sender.balance);
        run.expectedNuggftBalance = cast.i192(address(__nuggft__ref()).balance);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            expectClaim__SnapshotEnv memory env;
            expectClaim__SnapshotData memory pre;

            env.id = tokenIds[i];
            env.isItem = env.id > 0xffffff;
            env.buyer = offerers[i];

            if (env.isItem) {
                pre.agency = __nuggft__ref().external__itemAgency(env.id);
                pre.offer = __nuggft__ref().external__itemOffers(env.id, uint160(env.buyer));
            } else {
                pre.agency = __nuggft__ref().external__agency(env.id);
                pre.offer = __nuggft__ref().external__offers(env.id, env.buyer);
            }

            if (pre.offer == 0) pre.offer = pre.agency;

            // NEED TO CHECK: what happens when someone who owns the nugg also has an offer ?

            env.winner = uint160(pre.agency) == (uint160(pre.offer));

            if (env.winner && (2 << pre.agency) >> 232 == 0) {
                env.reclaim = true;
            }

            run.snapshots[i].env = env;
            run.snapshots[i].data = pre;

            preSingleClaimChecks(run, env, pre);
        }

        preRunChecks(run);

        return abi.encode(run);
    }

    function stopExpectClaim(bytes memory input) internal {
        expectClaim__Run memory run = abi.decode(input, (expectClaim__Run));

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            expectClaim__SnapshotEnv memory env = run.snapshots[i].env;
            expectClaim__SnapshotData memory pre = run.snapshots[i].data;
            expectClaim__SnapshotData memory post;

            if (env.isItem) {
                post.agency = __nuggft__ref().external__itemAgency(env.id);
                post.offer = __nuggft__ref().external__itemOffers(env.id, uint160(env.buyer));
            } else {
                post.agency = __nuggft__ref().external__agency(env.id);
                post.offer = __nuggft__ref().external__offers(env.id, env.buyer);
            }

            postSingleClaimChecks(run, env, pre, post);
        }

        postRunChecks(run);
    }

    function proofSearch(uint256 proof, uint16 itemId) internal pure returns (bool ok, uint8 index) {
        do {
            if (proof & 0xffff == itemId) return (true, index);
            index++;
        } while ((proof >>= 16) != 0);
    }

    function assertProofContains(
        uint160 tokenId,
        uint16 itemId,
        string memory str
    ) private {
        uint256 proof = __nuggft__ref().proofOf(tokenId);

        (bool hasItem, ) = proofSearch(proof, itemId);

        assertTrue(hasItem, string(abi.encodePacked('assertProofContains FAILED: - ', str)));
    }

    function assertProofNotContains(
        uint160 tokenId,
        uint16 itemId,
        string memory str
    ) private {
        uint256 proof = __nuggft__ref().proofOf(tokenId);

        (bool hasItem, ) = proofSearch(proof, itemId);

        assertTrue(!hasItem, string(abi.encodePacked('assertProofNotContains FAILED: - ', str)));
    }

    function preSingleClaimChecks(
        expectClaim__Run memory run,
        expectClaim__SnapshotEnv memory env,
        expectClaim__SnapshotData memory pre
    ) private {
        // ASSERT:CLAIM_0x01: externally is the nugg owned by the contract?

        if (env.isItem) {
            if (env.winner) {
                // -- __nuggft__ref's protocol items should be > 1 for the item

                // ASSERT:CLAIM_0x02: is the item inside the selling nuggs proof?
                assertProofNotContains(uint24(env.id), uint16(env.id >> 24), 'ASSERT:CLAIM_0x02: item SHOULD NOT be inside the selling nuggs proof');

                if (env.reclaim) {
                    // @note BEFORE a winning item reclaim
                } else {
                    // @note BEFORE a winning item claim
                }
            } else {
                // @note BEFORE a losing item claim

                // ASSERT:CLAIM_0x03: is the sender the offerer?
                assertEq(run.sender, address(uint160(pre.offer)), 'ASSERT:CLAIM_0x03: the offerer SHOULD be the sender');
            }
        } else {
            if (env.winner) {
                // ASSERT:CLAIM_0x04: does the agency have a SWAP flag?
                assertEq(pre.agency >> 254, 0x03, 'ASSERT:CLAIM_0x04: pre agency must have the SWAP - 0x03 - flag');

                if (env.reclaim) {
                    // @note BEFORE a winning nugg reclaim
                } else {
                    // @note BEFORE a winning nugg claim
                }
            } else {
                // @note BEFORE a losing nugg claim

                // ASSERT:CLAIM_0x05: is the sender the offerer?
                assertEq(run.sender, address(uint160(pre.offer)), 'ASSERT:CLAIM_0x05: is the offerer SHOULD be the sender?');
            }
        }
    }

    function postSingleClaimChecks(
        expectClaim__Run memory run,
        expectClaim__SnapshotEnv memory env,
        expectClaim__SnapshotData memory pre,
        expectClaim__SnapshotData memory post
    ) private {
        // ASSERT:CLAIM_0x06: is the post offer == 0?
        assertEq(post.offer, 0, 'ASSERT:CLAIM_0x06: is the post offer == 0?');

        if (!env.winner) {
            // BALANCE CHANGE: sender balance should go up by the amount of the offer, __nuggft__ref's should go down
            int192 amount = cast.i192(((pre.offer << 26) >> 186) * .1 gwei);
            run.expectedSenderBalance += amount;
            run.expectedNuggftBalance -= amount;
        }

        if (env.isItem) {
            if (env.winner) {
                // @note AFTER a winning item claim
                if (env.reclaim) {} else {
                    // ASSERT:CLAIM_0x07: is the item inside the winning nugg's proof?
                    assertProofContains(uint160(env.buyer), uint16(env.id >> 24), "ASSERT:CLAIM_0x07: the item SHOULD be inside the winning nugg's proof");

                    // ASSERT:CLAIM_0x08: is the post agency == 0?
                    assertEq(post.agency, 0, 'ASSERT:CLAIM_0x08: the agency SHOULD be 0 after the claim');
                }
            } else {
                // ASSERT:CLAIM_0x09: AFTER a losing item claim
            }
        } else {
            if (env.winner) {
                if (env.reclaim) {} else {
                    // @note AFTER a winning nugg claim
                    // ASSERT:CLAIM_0x0A: does the post agency reflect the same user as the pre agency?
                    assertEq(
                        address(uint160(post.agency)),
                        address(uint160(pre.agency)),
                        'ASSERT:CLAIM_0x0A: the pre agency user and the post agency user SHOULD be the same'
                    );

                    // ASSERT:CLAIM_0x0B: does the post agency have a OWN flag?
                    assertEq(post.agency >> 254, 0x01, 'ASSERT:CLAIM_0x0B: post agency must have the OWN - 0x01 - flag');
                }
            } else {
                // @note AFTER a losing nugg claim
                // make sure the nugg is owned by the contract
            }
        }
    }

    function preRunChecks(expectClaim__Run memory run) private {
        // ASSERT:CLAIM_0x0C: what should the balances be before any call on claim?
        // ASSERT:CLAIM_0x0C: maybe here we just check to see that the data is ok?
    }

    function postRunChecks(expectClaim__Run memory run) private {
        // ASSERT:CLAIM_0x0D: is the sender balance correct?
        assertBalance(run.sender, run.expectedSenderBalance, 'ASSERT:CLAIM_0x0D');

        // ASSERT:CLAIM_0x0E: is the __nuggft__ref balance correct?
        assertBalance(address(__nuggft__ref()), run.expectedNuggftBalance, 'ASSERT:CLAIM_0x0E');
    }
}
