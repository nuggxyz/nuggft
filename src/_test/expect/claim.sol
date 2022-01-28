//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import './base.sol';

import {expectStake} from './stake.sol';
import {expectBalance} from './balance.sol';

contract expectClaim is base {
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
        bool winner;
        address buyer;
        bool reclaim;
    }

    struct RunBalances {
        address account;
        int192 change;
    }

    struct Run {
        Snapshot[] snapshots;
        address sender;
        uint96 expectedBalanceChange;
    }

    bytes execution;

    function exec(
        uint160[] memory tokenIds,
        address[] memory offerers,
        lib.txdata memory txdata
    ) public {
        this.start(tokenIds, offerers, txdata.from);
        forge.vm.prank(txdata.from);
        nuggft.claim(tokenIds, offerers);
        this.stop();
    }

    function clear() public {
        delete execution;
    }

    function exec(
        uint160[] memory tokenIds,
        uint160[] memory offerers,
        lib.txdata memory txdata
    ) public {
        address[] memory a;
        assembly {
            a := offerers
        }
        this.exec(tokenIds, a, txdata);
    }

    function start(
        uint160[] memory tokenIds,
        uint160[] memory offerers,
        address sender
    ) public {
        address[] memory a;
        assembly {
            a := offerers
        }
        this.start(tokenIds, a, sender);
    }

    function start(
        uint160[] memory tokenIds,
        address[] memory offerers,
        address sender
    ) public {
        require(execution.length == 0, 'EXPECT-CLAIM:START: execution already esists');

        require(tokenIds.length == offerers.length, 'EXPECT-CLAIM:START:ArrayLengthNotSame');

        Run memory run;

        run.sender = sender;
        run.snapshots = new Snapshot[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            SnapshotEnv memory env;
            SnapshotData memory pre;

            env.id = tokenIds[i];
            env.isItem = env.id > 0xffffff;
            env.buyer = offerers[i];

            if (env.isItem) {
                pre.agency = nuggft.itemAgency(env.id);
                pre.offer = nuggft.itemOffers(env.id, uint160(env.buyer));
            } else {
                pre.agency = nuggft.agency(env.id);
                pre.offer = nuggft.offers(env.id, env.buyer);
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

        stake.start(0, 0, true);

        // ASSERT:CLAIM_0x0D: is the sender balance correct?
        balance.start(run.sender, run.expectedBalanceChange, true);

        // ASSERT:CLAIM_0x0E: is the nuggft balance correct?
        balance.start(address(nuggft), run.expectedBalanceChange, false);

        preRunChecks(run);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, 'EXPECT-CLAIM:STOP: execution does not esists');

        Run memory run = abi.decode(execution, (Run));

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            SnapshotEnv memory env = run.snapshots[i].env;
            SnapshotData memory pre = run.snapshots[i].data;
            SnapshotData memory post;

            if (env.isItem) {
                post.agency = nuggft.itemAgency(env.id);
                post.offer = nuggft.itemOffers(env.id, uint160(env.buyer));
            } else {
                post.agency = nuggft.agency(env.id);
                post.offer = nuggft.offers(env.id, env.buyer);
            }

            postSingleClaimChecks(run, env, pre, post);
        }

        balance.stop();
        stake.stop();

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, 'EXPECT-CLAIM:ROLLBACK: execution does not esists');

        Run memory run = abi.decode(execution, (Run));

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            SnapshotEnv memory env = run.snapshots[i].env;
            SnapshotData memory pre = run.snapshots[i].data;
            SnapshotData memory post;

            if (env.isItem) {
                post.agency = nuggft.itemAgency(env.id);
                post.offer = nuggft.itemOffers(env.id, uint160(env.buyer));
            } else {
                post.agency = nuggft.agency(env.id);
                post.offer = nuggft.offers(env.id, env.buyer);
            }

            ds.assertEq(pre.agency, post.agency, "EXPECT-CLAIM:ROLLBACK agency changed but shouldn't have");
            ds.assertEq(pre.offer, post.offer, "EXPECT-CLAIM:ROLLBACK offer changed but shouldn't have");
        }

        balance.rollback();
        stake.rollback();

        this.clear();
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
        uint256 proof = nuggft.proofOf(tokenId);

        (bool hasItem, ) = proofSearch(proof, itemId);

        ds.assertTrue(hasItem, string(abi.encodePacked('assertProofContains FAILED: - ', str)));
    }

    function assertProofNotContains(
        uint160 tokenId,
        uint16 itemId,
        string memory str
    ) private {
        uint256 proof = nuggft.proofOf(tokenId);

        (bool hasItem, ) = proofSearch(proof, itemId);

        ds.assertTrue(!hasItem, string(abi.encodePacked('assertProofNotContains FAILED: - ', str)));
    }

    function preSingleClaimChecks(
        Run memory run,
        SnapshotEnv memory env,
        SnapshotData memory pre
    ) private {
        // ASSERT:CLAIM_0x01: externally is the nugg owned by the contract?

        if (!env.winner) {
            // BALANCE CHANGE: sender balance should go up by the amount of the offer, nuggft's should go down
            uint96 amount = uint96(((pre.offer << 26) >> 186) * .1 gwei);
            run.expectedBalanceChange += amount;
        }

        if (env.isItem) {
            if (env.winner) {
                // -- nuggft's protocol items should be > 1 for the item

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
                ds.assertEq(env.buyer, address(uint160(pre.offer)), 'ASSERT:CLAIM_0x03: the offerer SHOULD be the sender');
            }
        } else {
            if (env.winner) {
                // ASSERT:CLAIM_0x04: does the agency have a SWAP flag?
                ds.assertEq(pre.agency >> 254, 0x03, 'ASSERT:CLAIM_0x04: pre agency must have the SWAP - 0x03 - flag');

                if (env.reclaim) {
                    // @note BEFORE a winning nugg reclaim
                } else {
                    // @note BEFORE a winning nugg claim
                }
            } else {
                // @note BEFORE a losing nugg claim

                // ASSERT:CLAIM_0x05: is the sender the offerer?
                ds.assertEq(run.sender, address(uint160(pre.offer)), 'ASSERT:CLAIM_0x05: is the offerer SHOULD be the sender?');
            }
        }
    }

    function postSingleClaimChecks(
        Run memory run,
        SnapshotEnv memory env,
        SnapshotData memory pre,
        SnapshotData memory post
    ) private {
        // ASSERT:CLAIM_0x06: is the post offer == 0?
        ds.assertEq(post.offer, 0, 'ASSERT:CLAIM_0x06: is the post offer == 0?');

        if (env.isItem) {
            if (env.winner) {
                // @note AFTER a winning item claim
                if (env.reclaim) {} else {
                    // ASSERT:CLAIM_0x07: is the item inside the winning nugg's proof?
                    assertProofContains(uint160(env.buyer), uint16(env.id >> 24), "ASSERT:CLAIM_0x07: the item SHOULD be inside the winning nugg's proof");

                    // ASSERT:CLAIM_0x08: is the post agency == 0?
                    ds.assertEq(post.agency, 0, 'ASSERT:CLAIM_0x08: the agency SHOULD be 0 after the claim');
                }
            } else {
                // ASSERT:CLAIM_0x09: AFTER a losing item claim
            }
        } else {
            if (env.winner) {
                if (env.reclaim) {} else {
                    // @note AFTER a winning nugg claim
                    // ASSERT:CLAIM_0x0A: does the post agency reflect the same user as the pre agency?
                    ds.assertEq(
                        address(uint160(post.agency)),
                        address(uint160(pre.agency)),
                        'ASSERT:CLAIM_0x0A: the pre agency user and the post agency user SHOULD be the same'
                    );

                    // ASSERT:CLAIM_0x0B: does the post agency have a OWN flag?
                    ds.assertEq(post.agency >> 254, 0x01, 'ASSERT:CLAIM_0x0B: post agency must have the OWN - 0x01 - flag');
                }
            } else {
                // @note AFTER a losing nugg claim
                // make sure the nugg is owned by the contract
            }
        }
    }

    function preRunChecks(Run memory run) private {
        // ASSERT:CLAIM_0x0C: what should the balances be before any call on claim?
        // ASSERT:CLAIM_0x0C: maybe here we just check to see that the data is ok?
    }

    function postRunChecks(Run memory run) private {}
}
