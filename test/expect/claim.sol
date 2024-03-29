//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "../utils/forge.sol";

import "./base.sol";

import {expectStake} from "./stake.sol";
import {expectBalance} from "./balance.sol";
import {Expect} from "./Expect.sol";

contract expectClaim is base {
	expectStake stake;
	expectBalance balance;
	Expect creator;

	constructor() {
		stake = new expectStake();
		balance = new expectBalance();
		creator = Expect(msg.sender);
	}

	lib.txdata prepped;

	function from(address user) public returns (expectClaim) {
		prepped.from = user;
		return this;
	}

	// function value(uint96 val) public returns (expectClaim) {
	//     prepped.value = val;
	//     return this;
	// }

	function err(bytes memory b) public returns (expectClaim) {
		prepped.err = b;
		return this;
	}

	function err(bytes1 b) public returns (expectClaim) {
		if (b != 0x0) prepped.err = abi.encodePacked(bytes4(0x7e863b48), b);
		return this;
	}

	function g() public returns (expectClaim) {
		prepped.from = creator._globalFrom();
		return this;
	}

	function exec(uint24[] memory tokenIds, address[] memory offerers) public {
		lib.txdata memory _prepped = prepped;
		delete prepped;
		exec(tokenIds, offerers, _prepped);
	}

	function exec(uint24 tokenId, address account) public {
		exec(array.b24(tokenId), array.bAddress(account));
	}

	function exec(
		uint24 tokenId,
		uint24 buyerId,
		uint16 itemId
	) public {
		exec(array.b24(tokenId), array.b24(buyerId), array.b16(itemId));
	}

	function exec(
		uint24[] memory tokenIds,
		uint24[] memory buyingTokenIds,
		uint16[] memory itemIds
	) public {
		lib.txdata memory _prepped = prepped;
		delete prepped;
		exec(tokenIds, buyingTokenIds, itemIds, _prepped);
	}

	function execUnchecked(
		uint24[] memory tokenIds,
		uint40[] memory buyingTokenIds,
		uint16[] memory itemIds
	) public {
		lib.txdata memory _prepped = prepped;
		delete prepped;
		exec(tokenIds, array.to24(array.from40(buyingTokenIds)), itemIds, _prepped);
	}

	function exec(
		uint24[] memory tokenIds,
		address[] memory offerers,
		uint24[] memory buyingTokenIds,
		uint16[] memory itemIds
	) public {
		lib.txdata memory _prepped = prepped;
		delete prepped;
		exec(tokenIds, offerers, buyingTokenIds, itemIds, _prepped);
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
		bool winner;
		address buyer;
		bool reclaim;
		address buyingNuggOwner;
		uint256 nuggsProof;
	}

	struct RunBalances {
		address account;
		int192 change;
	}

	struct Run {
		Snapshot[] snapshots;
		address sender;
		uint96 expectedBalanceChange;
		bool shouldDonate;
	}

	bytes execution;

	// event ClaimItem(uint24 indexed sellingTokenId, uint16 indexed itemId, uint24 indexed buyerTokenId, bytes32 proof);

	// event Claim(uint24 indexed tokenId, address indexed account);

	// function mockProofUpdate__add(uint256 proof, uint16 item) pure returns (uint256 res) {

	// }

	function exec(
		uint24[] memory tokenIds,
		address[] memory offerers,
		uint24[] memory buyingTokenIds,
		uint16[] memory itemIds,
		lib.txdata memory txdata
	) public returns (Run memory run) {
		run = this.start(tokenIds, offerers, buyingTokenIds, itemIds, txdata.from);
		forge.vm.startPrank(txdata.from);
		if (txdata.err.length > 0) {
			forge.vm.expectRevert(txdata.err);
		} else {
			for (uint256 a = 0; a < tokenIds.length; a++) {
				bytes32 agen;
				uint256 proof;
				if (offerers[a] == address(0)) {
					if (run.snapshots[a].env.winner) {
						agen = bytes32(uint256(buyingTokenIds[a]));
						(, , proof) = mockInsertItem(run.snapshots[a].env.nuggsProof, itemIds[a]);
					}
					forge.vm.expectEmit(true, true, true, true);
					emit Claim((uint40(itemIds[a]) << 24) | uint40(tokenIds[a]), bytes32(proof), bytes32(run.snapshots[a].data.offer), agen);
					if (run.snapshots[a].env.winner) {
						forge.vm.expectCall(
							address(xnuggft),
							abi.encodeWithSelector(
								xnuggft.transfer.selector,
								itemIds[a],
								uint256(uint160(address(nuggft))) | (uint256(tokenIds[a]) << 160),
								run.snapshots[a].env.buyingNuggOwner
							)
						);
					}
				} else {
					if (run.snapshots[a].env.winner) {
						agen = bytes32(uint256((0x01) << AFJO) | uint160(offerers[a]));
						proof = run.snapshots[a].env.nuggsProof;
					}
					forge.vm.expectEmit(true, true, true, true);
					emit Claim(tokenIds[a], bytes32(proof), bytes32(run.snapshots[a].data.offer), agen);
					if (run.snapshots[a].env.winner) {
						forge.vm.expectCall(
							address(xnuggft),
							abi.encodeWithSelector(
								xnuggft.transfer.selector,
								run.snapshots[a].env.nuggsProof,
								uint256(uint160(address(nuggft))) | (uint256(tokenIds[a]) << 160),
								offerers[a]
							)
						);
					}
				}
			}
		}
		nuggft.claim(tokenIds, offerers, buyingTokenIds, itemIds);
		forge.vm.stopPrank();
		txdata.err.length > 0 ? this.rollback() : this.stop();
	}

	function clear() public {
		delete execution;
	}

	function exec(uint40[] memory tokenIds, address[] memory offerers) public {
		uint24[] memory sellers = new uint24[](tokenIds.length);
		address[] memory eoas = new address[](tokenIds.length);
		uint24[] memory buyers = new uint24[](tokenIds.length);
		uint16[] memory items = new uint16[](tokenIds.length);

		for (uint256 i = 0; i < tokenIds.length; i++) {
			if (tokenIds[i] > 0xffffff) {
				sellers[i] = safe.u24(tokenIds[i] & 0xffffff);
				buyers[i] = safe.u24(offerers[i]);
				items[i] = safe.u16(tokenIds[i] >> 24);
			} else {
				sellers[i] = safe.u24(tokenIds[i]);
				eoas[i] = offerers[i];
			}
		}
		this.exec(sellers, eoas, buyers, items);
	}

	function exec(
		uint24[] memory tokenIds,
		address[] memory offerers,
		lib.txdata memory txdata
	) public {
		uint16 len = uint16(tokenIds.length);
		address[] memory a;
		assembly {
			a := offerers
		}
		this.exec(tokenIds, offerers, array.r24(0, len), array.r16(0, len), txdata);
	}

	function exec(
		uint24[] memory tokenIds,
		uint24[] memory buyingTokenIds,
		uint16[] memory itemIds,
		lib.txdata memory txdata
	) public {
		uint16 len = uint16(tokenIds.length);
		this.exec(tokenIds, array.rAddress(address(0), len), buyingTokenIds, itemIds, txdata);
	}

	// function start(
	//     uint24[] memory tokenIds,
	//     address[] memory offerers,
	//     uint24[] memory buyingTokenIds,
	//     uint16[] memory itemIds,
	//     address sender
	// ) public {
	//     address[] memory a;
	//     assembly {
	//         a := offerers
	//     }
	//     this.start(tokenIds, a, sender);
	// }

	function start(
		uint24[] memory tokenIds,
		address[] memory offerers,
		uint24[] memory buyingTokenIds,
		uint16[] memory itemIds,
		address sender
	) public returns (Run memory run) {
		require(execution.length == 0, "EXPECT-CLAIM:START: execution already esists");

		// require(tokenIds.length == offerers.length, 'EXPECT-CLAIM:START:ArrayLengthNotSame');

		run.sender = sender;
		run.snapshots = new Snapshot[](tokenIds.length);

		run.shouldDonate = sender == ds.noFallback || sender.code.length != 0;

		ds.emit_log_named_uint("sender", sender.code.length);

		for (uint256 i = 0; i < tokenIds.length; i++) {
			SnapshotEnv memory env;
			SnapshotData memory pre;

			env.id = tokenIds[i];
			env.isItem = offerers[i] == address(0);

			if (env.isItem) {
				env.buyer = address(uint160(buyingTokenIds[i]));
				env.id |= uint40(itemIds[i]) << 24;
			} else {
				env.buyer = offerers[i];
			}

			if (env.isItem) {
				pre.agency = nuggft.itemAgency(safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
				pre.offer = nuggft.itemOffers(safe.u24(env.buyer), safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
				env.buyingNuggOwner = address(uint160(nuggft.agency(safe.u24(uint160(env.buyer)))));
				env.nuggsProof = nuggft.proofOf(safe.u24(env.buyer));
			} else {
				pre.agency = nuggft.agency(safe.u24(env.id));
				pre.offer = nuggft.offers(safe.u24(env.id), env.buyer);
				env.nuggsProof = nuggft.proofOf(safe.u24(env.id));
			}

			pre.trueoffer = pre.offer;

			if (pre.offer == 0) pre.offer = pre.agency;

			// NEED TO CHECK: what happens when someone who owns the nugg also has an offer ?

			env.winner = uint160(pre.agency) == (uint160(pre.offer));

			if (env.winner && (pre.agency << AEJL) >> AEJR == 0) {
				env.reclaim = true;
			}

			run.snapshots[i].env = env;
			run.snapshots[i].data = pre;

			preSingleClaimChecks(run, env, pre);
		}

		if (run.shouldDonate) {
			stake.start(run.expectedBalanceChange, 0, true);

			// ASSERT:CLAIM_0x0D: is the sender balance correct?
			balance.start(run.sender, 0, true);

			// ASSERT:CLAIM_0x0E: is the nuggft balance correct?
			balance.start(address(nuggft), 0, true);
		} else {
			stake.start(0, 0, true);

			// ASSERT:CLAIM_0x0D: is the sender balance correct?
			balance.start(run.sender, run.expectedBalanceChange, true);

			// ASSERT:CLAIM_0x0E: is the nuggft balance correct?
			balance.start(address(nuggft), run.expectedBalanceChange, false);
		}

		preRunChecks(run);

		execution = abi.encode(run);
	}

	function stop() public {
		require(execution.length > 0, "EXPECT-CLAIM:STOP: execution does not esists");

		Run memory run = abi.decode(execution, (Run));

		for (uint256 i = 0; i < run.snapshots.length; i++) {
			SnapshotEnv memory env = run.snapshots[i].env;
			SnapshotData memory pre = run.snapshots[i].data;
			SnapshotData memory post;

			if (env.isItem) {
				post.agency = nuggft.itemAgency(safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
				post.offer = nuggft.itemOffers(safe.u24(env.buyer), safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
			} else {
				post.agency = nuggft.agency(safe.u24(env.id));
				post.offer = nuggft.offers(safe.u24(env.id), env.buyer);
			}

			postSingleClaimChecks(run, env, pre, post);
		}

		balance.stop();
		stake.stop();

		this.clear();
	}

	function rollback() public {
		require(execution.length > 0, "EXPECT-CLAIM:ROLLBACK: execution does not esists");

		Run memory run = abi.decode(execution, (Run));

		for (uint256 i = 0; i < run.snapshots.length; i++) {
			SnapshotEnv memory env = run.snapshots[i].env;
			SnapshotData memory pre = run.snapshots[i].data;
			SnapshotData memory post;

			if (env.isItem) {
				post.agency = nuggft.itemAgency(safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
				post.offer = nuggft.itemOffers(safe.u24(env.buyer), safe.u24(env.id & 0xffffff), safe.u16(env.id >> 24));
			} else {
				post.agency = nuggft.agency(safe.u24(env.id));
				post.offer = nuggft.offers(safe.u24(env.id), env.buyer);
			}

			ds.assertEq(pre.agency, post.agency, "EXPECT-CLAIM:ROLLBACK agency changed but shouldn't have");
			ds.assertEq(pre.trueoffer, post.offer, "EXPECT-CLAIM:ROLLBACK offer changed but shouldn't have");
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

	function mockInsertItem(uint256 proof, uint16 itemId)
		internal
		pure
		returns (
			bool ok,
			uint8 index,
			uint256 res
		)
	{
		res = proof;
		index = 8;
		proof >>= 128;
		do {
			if (proof & 0xffff == 0) {
				return (true, index, res + (uint256(itemId) << (index * 16)));
			}
			index++;
			proof >>= 16;
		} while (index < 16);

		return (false, 0, res);
	}

	function assertProofContains(
		uint24 tokenId,
		uint16 itemId,
		string memory str
	) private {
		uint256 proof = nuggft.proof(tokenId);

		(bool hasItem, ) = proofSearch(proof, itemId);
		ds.assertTrue(hasItem, string(abi.encodePacked("assertProofContains FAILED: - ", str)));
	}

	function assertProofNotContains(
		uint24 tokenId,
		uint16 itemId,
		string memory str
	) private {
		uint256 proof = nuggft.proof(tokenId);

		(bool hasItem, ) = proofSearch(proof, itemId);

		ds.assertTrue(!hasItem, string(abi.encodePacked("assertProofNotContains FAILED: - ", str)));
	}

	function preSingleClaimChecks(
		Run memory run,
		SnapshotEnv memory env,
		SnapshotData memory pre
	) private {
		// ASSERT:CLAIM_0x01: externally is the nugg owned by the contract?

		if (!env.winner) {
			// BALANCE CHANGE: sender balance should go up by the amount of the offer, nuggft's should go down
			uint96 amount = uint96(((pre.offer << AVJL) >> AVJR) * LOSS);
			run.expectedBalanceChange += amount;
		}

		if (env.isItem) {
			// ASSERT:CLAIM_0x02: is the item inside the selling nuggs proof?
			// assertProofNotContains(uint24(env.id), uint16(env.id >> 24), "ASSERT:CLAIM_0x02: item SHOULD NOT be inside the selling nuggs proof");
			if (env.winner) {
				// @todo nuggft's protocol items should be > 1 for the item

				if (env.reclaim) {
					// @note BEFORE a winning item reclaim
				} else {
					// @note BEFORE a winning item claim
				}
			} else {
				// @note BEFORE a losing item claim
				// ASSERT:CLAIM_0x03: is the sender the offerer?
				// ds.assertEq(env.buyer, address(uint160(pre.offer)), "ASSERT:CLAIM_0x03: the offerer SHOULD be the sender");
			}
		} else {
			// ds.assertEq(pre.agency >> AFJR, 0x03, "ASSERT:CLAIM_0x04: pre agency must have the SWAP - 0x03 - flag");
			if (env.winner) {
				// ASSERT:CLAIM_0x04: does the agency have a SWAP flag?

				if (env.reclaim) {
					// @note BEFORE a winning nugg reclaim
				} else {
					// @note BEFORE a winning nugg claim
				}
			} else {
				// @note BEFORE a losing nugg claim
				// ASSERT:CLAIM_0x05: is the sender the offerer?
				// ds.assertEq(run.sender, address(uint160(pre.offer)), "ASSERT:CLAIM_0x05: the offerer SHOULD be the sender");
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
		ds.assertEq(post.offer, 0, "ASSERT:CLAIM_0x06: is the post offer == 0?");

		if (env.isItem) {
			if (env.winner) {
				// @todo make sure post user balance = pre user balance
				// ASSERT:CLAIM_0x07: is the item inside the winning nugg's proof?
				assertProofContains(safe.u24(env.buyer), uint16(env.id >> 24), "ASSERT:CLAIM_0x07: the item SHOULD be inside the winning nugg's proof");

				// ASSERT:CLAIM_0x08: is the post agency == 0?
				ds.assertEq(post.agency, 0, "ASSERT:CLAIM_0x08: the agency SHOULD be 0 after the claim");
				if (env.reclaim) {} else {
					// @note AFTER a winning item claim
				}
			} else {
				// ASSERT:CLAIM_0x09: AFTER a losing item claim
				// @todo make sure post user balance = pre user balance + claimed
			}
		} else {
			if (env.winner) {
				// @todo make sure post user balance = pre user balance
				// ASSERT:CLAIM_0x0A: does the post agency reflect the same user as the pre agency?
				ds.assertEq(
					address(uint160(post.agency)),
					address(uint160(pre.agency)),
					"ASSERT:CLAIM_0x0A: the pre agency user and the post agency user SHOULD be the same"
				);

				// ASSERT:CLAIM_0x0B: does the post agency have a OWN flag?
				ds.assertEq(post.agency >> AFJR, 0x01, "ASSERT:CLAIM_0x0B: post agency must have the OWN - 0x01 - flag");
				if (env.reclaim) {} else {
					// @note AFTER a winning nugg claim
				}
			} else {
				// @note AFTER a losing nugg claim
				// @todo make sure post user balance = pre user balance + claimed
			}
		}
	}

	function preRunChecks(Run memory run) private {
		// ASSERT:CLAIM_0x0C: what should the balances be before any call on claim?
		// ASSERT:CLAIM_0x0C: maybe here we just check to see that the data is ok?
	}

	function postRunChecks(Run memory run) private {}
}
