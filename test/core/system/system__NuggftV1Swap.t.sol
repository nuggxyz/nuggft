// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "@nuggft-v1-core/test/main.sol";
import {NuggftV1Proof} from "@nuggft-v1-core/src/core/NuggftV1Proof.sol";
import {fragments} from "./fragments.t.sol";

abstract contract system__NuggftV1Swap is NuggftV1Test, fragments {
	using SafeCast for uint96;

	address[] tmpUsers;
	uint40[] tmpTokens;

	modifier clean() {
		delete tmpUsers;
		delete tmpTokens;
		delete itemId;

		_;
	}

	// function test__system__frankMintsThenBurns() public clean {
	//     uint24 token1 = mintable(0);
	//     uint24 token2 = mintable(99);
	//     uint24 token3 = mintable(48);
	//     jumpStart();

	//     mintHelper(token1, users.frank, 1 ether);

	//     // if nothing else is in the pool then value goes to 0 and tests fail
	//     mintHelper(token2, users.frank, nuggft.msp());

	//     expect.burn().from(users.frank).exec(token1);
	// }

	function test__system__frankBidsOnANuggThenClaims() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		jumpStart();

		uint24 token = nuggft.epoch();

		uint96 value = 1 ether;
		{
			expect.offer().from(users.frank).exec{value: value}(token);

			jumpSwap();

			expect.claim().from(users.frank).exec(array.b24(token), lib.sarrAddress(users.frank));
		}
	}

	function test__system__frankSellsANuggThenReclaims() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		jumpStart();

		mintHelper(token1, users.frank, nuggft.msp());
		expect.sell().from(users.frank).exec(token1, nuggft.msp());

		jumpSwap();

		expect.claim().from(users.frank).exec(array.b24(token1), array.bAddress(users.frank));
	}

	function test__system__frankBidsOnAnItemThenClaims() public clean {
		// uint24 token1 = mintable(0);
		// uint24 token2 = mintable(99);
		// uint24 token3 = mintable(48);
		// deeSellsAnItem();
		// jumpStart();
		// mintHelper(token2, users.frank, nuggft.msp());
		// expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, token2)}(token2, token1, itemId);
		// jumpSwap();
		// expect.claim().from(users.frank).exec(array.b24(token1), array.b24(token2), array.b16(itemId));
	}

	function test__system__frankMulticlaimWinningItemAndNuggs() public clean {
		// uint24 token1 = mintable(0);
		// uint24 token2 = mintable(99);
		// uint24 token3 = mintable(48);
		// deeSellsAnItem();
		// userMints(users.frank, token2);
		// // forge.vm.startPrank(users.frank);
		// {
		//     for (uint16 i = 0; i < 100; i++) {
		//         jumpUp(1);
		//         tmpTokens.push(nuggft.epoch());
		//         uint96 value = nuggft.vfo(users.frank, uint24(tmpTokens[i]));
		//         expect.offer().exec(safe.u24(tmpTokens[i]), lib.txdata(users.frank, value, ""));
		//     }
		//     expect.offer().exec(token2, token1, itemId, lib.txdata(users.frank, nuggft.vfo(token2, token1, itemId), ""));
		//     tmpTokens.push(encItemIdClaim(token1, itemId));
		//     jumpSwap();
		//     tmpUsers = lib.mAddress(users.frank, uint16(tmpTokens.length - 1));
		//     tmpUsers.push(address(uint160(token2)));
		//     expect.claim().from(users.frank).exec(tmpTokens, tmpUsers);
		// }
		// // forge.vm.stopPrank();
	}

	event log_array(uint24[] tmp);

	function test__system__frankMulticlaimLosingItemAndNuggs() public clean {
		// uint24 token1 = mintable(0);
		// uint24 token2 = mintable(99);
		// uint24 token3 = mintable(48);
		// deeSellsAnItem();
		// userMints(users.frank, token2);
		// userMints(users.dennis, token3);
		// jumpStart();
		// // forge.vm.startPrank(users.frank);
		// {
		//     for (uint16 i = 0; i < 100; i++) {
		//         jumpUp(1);
		//         tmpTokens.push(nuggft.epoch());
		//         uint96 value = nuggft.vfo(users.frank, safe.u24(tmpTokens[i]));
		//         expect.offer().from(users.frank).exec{value: value}(safe.u24(tmpTokens[i]));
		//         uint96 dennisIsABastardMan = nuggft.vfo(users.dennis, safe.u24(tmpTokens[i]));
		//         expect.offer().from(users.dennis).exec{value: dennisIsABastardMan}(safe.u24(tmpTokens[i]));
		//     }
		//     expect.offer().from(users.frank).exec{value: nuggft.vfo(token2, token1, itemId)}(token2, token1, itemId);
		//     expect.offer().from(users.dennis).exec{value: nuggft.vfo(token3, token1, itemId)}(token3, token1, itemId);
		//     tmpTokens.push(encItemIdClaim(token1, itemId));
		//     jumpSwap();
		//     tmpUsers = lib.mAddress(users.frank, uint16(tmpTokens.length - 1));
		//     tmpUsers.push(address(uint160(token2)));
		//     expect.claim().from(users.frank).exec(tmpTokens, tmpUsers);
		// }
		// forge.vm.stopPrank();
	}

	function test__system__nuggFactory() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		uint16 nugg__size = 100;
		uint256 user__count = 0;

		mintHelper(token1, users.frank, nuggft.msp());

		for (uint16 i = 0; i < nugg__size; i++) {
			jumpUp(1);
			tmpTokens.push(nuggft.epoch());
			for (; user__count < i * 10; user__count++) {
				tmpUsers.push(address(uint160(uint256(keccak256("nuggfactory")) + user__count)));
				uint96 money = nuggft.vfo(tmpUsers[user__count], safe.u24(tmpTokens[i]));
				forge.vm.deal(tmpUsers[user__count], money);

				expect.offer().from(tmpUsers[user__count]).exec{value: money}(safe.u24(tmpTokens[i]));
			}
		}

		jumpSwap();
		user__count = 0;

		for (uint16 i = 0; i < nugg__size; i++) {
			for (; user__count < i * 10; user__count++) {
				expect.claim().from(tmpUsers[user__count]).exec(array.b24(tmpTokens[i]), array.bAddress(tmpUsers[user__count]));
			}
		}
	}

	function test__system__offerWar() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		jumpStart();

		mintHelper(token1, users.frank, nuggft.msp());

		uint16 size = 2;

		address[] memory user__list = new address[](size);

		for (uint256 i = 0; i < size; i++) {
			user__list[i] = address(uint160(uint256(keccak256(abi.encodePacked(i + 6)))));
		}

		for (uint24 p = 0; p < size; p++) {
			for (uint256 i = 0; i < size; i++) {
				tmpUsers.push(user__list[i]);
				uint24 epoch = nuggft.epoch();
				tmpTokens.push(epoch);
				for (uint256 j = 0; j < size; j++) {
					uint96 money = nuggft.vfo(user__list[j], epoch);
					forge.vm.deal(user__list[j], money);
					expect.offer().start(epoch, user__list[j], money);
					forge.vm.prank(user__list[j]);
					nuggft.offer{value: money}(epoch);
					expect.offer().stop();
				}
			}

			jumpUp(1);
			nuggft.epoch();
		}
		jumpSwap();
		// uint256 i = 1;
		for (uint256 i = 0; i < size; i++) {
			expect.claim().from(tmpUsers[i]).exec(array.b24(tmpTokens[i]), array.bAddress(tmpUsers[i]));
		}

		// forge.vm.prank(users.dennis);
		// nuggft.claim(tmpTokens, tmpUsers);
		// endExpectClaim();

		// delete tmpTokens;
		// delete tmpUsers;

		// stakeHelper();
	}

	function test__system__revert__0xA0__offerWarClaimTwice() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		test__system__offerWar();

		expect.claim().from(tmpUsers[1]).err(0xA0).exec(array.b24(tmpTokens[1]), lib.sarrAddress(tmpUsers[1]));
	}

	function test__system__revert__0xA0__claim__twice__frank() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		jumpStart();
		jumpUp(1000);
		uint24 token = nuggft.epoch();
		expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, token)}(token);
		jumpSwap();

		expect.claim().from(users.frank).exec(array.b24(token), array.bAddress(users.frank));
	}

	function test__system__revert__0x67__claim__early__frank() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		jumpStart();
		jumpUp(1000);
		uint24 token = nuggft.epoch();

		expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, token)}(token);

		expect.claim().from(users.frank).err(0x67).exec(array.b24(token), array.bAddress(users.frank));
	}

	// 3165405740233807789653026790548718548040
	// 79228162514264337593543950336

	function test__system__item__sell__frank() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		mintHelper(token1, users.frank, nuggft.msp());

		uint16[16] memory f = xnuggft.floop(token1);

		itemId = uint16(f[1]);

		forge.vm.startPrank(users.frank);

		// xnuggft.floop(token1);
		nuggft.sell(token1, itemId, 50 ether);
		// nuggft.sell(token1, 90 ether);
		// xnuggft.floop(token1);
		// nuggft.rotate(token1, 1, 8);
		// xnuggft.floop(token1);

		// nuggft.proofToDotnuggMetadata(token1);

		forge.vm.stopPrank();
	}

	function test__system__revert__0x99__item__sellThenOffer__frank() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		mintHelper(token1, users.frank, nuggft.msp());
		forge.vm.startPrank(users.frank);

		uint16[16] memory f = xnuggft.floop(token1);

		itemId = uint16(f[1]);

		nuggft.sell(token1, itemId, 50 ether);
		forge.vm.expectRevert(hex"7e863b48_99");
		nuggft.offer{value: 1 ether}(token1, token1, itemId);

		forge.vm.stopPrank();
	}

	function test__system__item__sellWaitThenOffer__frank() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		jumpStart();
		mintHelper(token1, users.frank, nuggft.msp());
		forge.vm.startPrank(users.frank);

		uint16[16] memory f = xnuggft.floop(token1);

		itemId = uint16(f[1]);

		// xnuggft.floop(token1);
		nuggft.sell(token1, itemId, 1 ether);
		// forge.vm.expectRevert(hex'7e863b48_99');
		forge.vm.stopPrank();

		mintHelper(token2, users.dee, nuggft.msp());

		forge.vm.startPrank(users.dee);
		nuggft.offer{value: 1.1 ether}(token2, token1, itemId);
		forge.vm.stopPrank();

		forge.vm.prank(users.frank);
		nuggft.offer{value: 1.2 ether}(token1, token1, itemId);
		// nuggft.sell(token1, 90 ether);
		// xnuggft.floop(token1);
		// nuggft.rotate(token1, 1, 8);s
		// xnuggft.floop(token1);

		// nuggft.proofToDotnuggMetadata(token1);
	}

	function test__system__item__sellTwo__frank() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		mintHelper(token1, users.frank, 2 ether);

		uint16[16] memory f = xnuggft.floop(token1);

		itemId = uint16(f[1]);

		expect.sell().from(users.frank).exec(token1, itemId, 50 ether);
		// nuggft.claim(array.b24(encItemIdClaim(token1, itemId)), array.b24(token1));

		xnuggft.floop(token1);

		itemId = uint16(f[2]);

		expect.sell().from(users.frank).exec(token1, itemId, 50 ether);

		forge.vm.stopPrank();
	}

	function test__system__item__sellTwoClaimBack__frank() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		mintHelper(token1, users.frank, 2 ether);

		uint16[16] memory f = xnuggft.floop(token1);

		itemId = uint16(f[1]);

		expect.sell().from(users.frank).exec(token1, itemId, 50 ether);
		expect.claim().from(users.frank).exec(array.b24(token1), array.b24(token1), array.b16(itemId));

		xnuggft.floop(token1);

		itemId = uint16(f[2]);

		expect.sell().from(users.frank).exec(token1, itemId, 50 ether);
		expect.claim().from(users.frank).exec(array.b24(token1), array.b24(token1), array.b16(itemId));
	}

	function test__system__item__offerWar__frankSale() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(1500);
		uint24 token3 = mintable(48);
		test__system__item__sell__frank();
		// jumpStart();
		uint16 size = 20;

		for (uint256 i = 0; i < size; i++) {
			tmpUsers.push(forge.vm.addr(i + 100));

			uint24 token = uint24(token2 + i);
			tmpTokens.push(token);

			uint96 msp = nuggft.msp();

			mintHelper(token, tmpUsers[i], msp);
		}

		for (uint256 i = 0; i < size; i++) {
			uint24 token = uint24(token2 + i);

			// uint96 msp = nuggft.msp();

			// msp = nuggft.msp();
			uint96 vfo = nuggft.vfo(token, token1, itemId);

			// forge.vm.deal(tmpUsers[i], vfo);
			// forge.vm.startPrank(tmpUsers[i]);
			// nuggft.offer{value:vfo}(token, token1, itemId);
			// forge.vm.stopPrank();

			// uint96 vfo = nuggft.vfo(token, token1, itemId);

			expect.offer().from(tmpUsers[i]).exec{value: vfo}(token, token1, itemId);
		}
	}

	function test__system__item__everyoneClaimsTheirOwn__offerWar__frankSale() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		test__system__item__offerWar__frankSale();

		jumpSwap();

		for (uint16 i = 0; i < tmpTokens.length; i++) {
			expect.claim().from(tmpUsers[i]).exec(array.b24(token1), array.b24(tmpTokens[i]), array.b16(itemId));
		}
	}

	function test__system__revert__0x74__item__oneClaimsAll__offerWar__frankSale() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		test__system__item__offerWar__frankSale();

		jumpSwap();

		// forge.vm.expectRevert(hex"7e863b48_74");
		// forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
		// nuggft.claim(lib.m160(encItemIdClaim(token1, itemId), uint16(tmpUsers.length)), tmpTokens);

		expect.claim().err(0x74).from(tmpUsers[tmpUsers.length - 2]).execUnchecked(
			array.r24(token1, uint16(tmpUsers.length)),
			tmpTokens,
			array.r16(itemId, uint16(tmpUsers.length))
		);
	}

	function test__system__item__trustlessWinnerClaim__offerWar__frankSale() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		test__system__item__offerWar__frankSale();

		jumpSwap();

		expect.claim().from(tmpUsers[tmpUsers.length - 2]).exec(
			token1,
			//
			safe.u24(tmpTokens[tmpUsers.length - 1]),
			itemId //
		);

		// forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
		// nuggft.claim(array.b24(encItemIdClaim(token1, itemId)), array.b24(tmpTokens[tmpUsers.length - 1]));
	}

	uint24[] tmpIds;
	uint16[] tmpItemIds;

	// function test__system__item__offerWar__ffrankSale__hf() clean public clean {

	//     test__system__item__sell__frank();
	//     forge.vm.prank(users.frank);
	//     nuggft.sell(token1, .9 ether);

	//     // mintHelper(509, FIX_ADDRESS, 200 ether);

	//     uint16 size = 20;
	//     uint96 money = .69696969 ether;

	//     for (uint256 i = 0; i < size; i++) {
	//         tmpUsers.push(forge.vm.addr(100));
	//         tmpTokens.push(uint24(token2 + i));
	//         tmpIds.push(encItemIdClaim(token1, itemId));
	//         uint256 value = nuggft.msp();
	//         uint24 tkn = uint24(token2 + i);
	//         money = nuggft.vfo(tkn, token1, itemId);

	//         forge.vm.startPrank(tmpUsers[i]);
	//         {
	//             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + value);

	//             mintHelper(tkn, FIX_ADDRESS, value);

	//             money = nuggft.vfo(forge.vm.addr(100), token1);

	//             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + money);

	//             expect.offer().start(token1, tmpUsers[i], money);
	//             nuggft.offer{value: money}(tkn, token1, itemId);
	//             expect.offer().stop();

	//             money = nuggft.vfo(forge.vm.addr(100), token1);

	//             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + money);

	//             expect.offer().start(token1, tmpUsers[i], money);
	//             nuggft.offer{value: money}(token1);
	//             expect.offer().stop();
	//         }
	//         forge.vm.stopPrank();
	//         money += .42069696969 ether;
	//     }

	//     tmpUsers.push(forge.vm.addr(100));
	//     tmpIds.push(token1);

	//     tmpTokens.push(uint24(forge.vm.addr(100)));

	//     jumpSwap();

	//     // uint24[] memory tkn = uint24[](size);

	//     // for (uint16 i = 0; i<size; i++) {

	//     // }

	//     forge.vm.prank(tmpUsers[size - 3]);
	//     expect.claim().start(tmpIds, tmpTokens, tmpUsers[size - 3]);
	//     nuggft.claim(tmpIds, tmpTokens);
	// }

	function test__system__item__initSaleThenSellNugg() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		test__system__item__sell__frank();
		forge.vm.prank(users.frank);
		nuggft.sell(token1, 90 ether);
		fragment__item__offerWar__ffrankSale__hf();
	}

	function test__system__item__initSaleThenLoanNugg() public clean {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		test__system__item__sell__frank();
		forge.vm.prank(users.frank);
		nuggft.loan(array.b24(token1));
		fragment__item__offerWar__ffrankSale__hf();
	}

	// function test__system__item__initSaleThenBurnNugg() public clean {
	//     uint24 token1 = mintable(0);
	//     uint24 token2 = mintable(99);
	//     uint24 token3 = mintable(48);
	//     test__system__item__sell__frank();
	//     forge.vm.prank(users.frank);
	//     // nuggft.burn(token1);
	//     fragment__item__offerWar__ffrankSale__hf();
	// }

	function fragment__item__offerWar__ffrankSale__hf() public {
		uint24 token1 = mintable(0);
		uint24 token2 = mintable(99);
		uint24 token3 = mintable(48);
		jumpStart();

		uint16 size = 20;
		uint256 money = 1000 ether;

		for (uint256 i = 0; i < size; i++) {
			tmpUsers.push(forge.vm.addr(100));
			tmpTokens.push(uint24(token2 + i));
			tmpIds.push(token1);
			tmpItemIds.push(itemId);

			uint256 value = nuggft.msp();
			uint24 tkn = uint24(token2 + i);

			mintHelper(tkn, tmpUsers[i], value);
		}

		for (uint256 i = 0; i < size; i++) {
			uint256 value = nuggft.msp();
			uint24 tkn = uint24(token2 + i);

			forge.vm.startPrank(tmpUsers[i]);
			forge.vm.deal(tmpUsers[i], money);

			money = nuggft.vfo(tkn, token1, itemId);
			nuggft.offer{value: money}(tkn, token1, itemId);

			forge.vm.stopPrank();
			money += 10 ether;
		}

		jumpSwap();

		// forge.vm.prank(tmpUsers[size - 3]);
		// nuggft.claim(tmpIds, tmpItemIds, tmpTokens);

		expect.claim().from(tmpUsers[size - 3]).execUnchecked(tmpIds, tmpTokens, tmpItemIds);
	}

	// function test__system__hotproof__pass() public clean {

	//     logHotproof();

	//     jumpStart();

	//     uint24 tokenId = nuggft.epoch();

	//     uint256 proofBeforeOffer = nuggft.proof(tokenId);

	//     expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, tokenId)}(tokenId);

	//     uint256 proofAfterOffer = nuggft.proof(tokenId);
	//     logHotproof();

	//     jumpUp(1);

	//     uint24 tokenId2 = nuggft.epoch();
	//     nuggft.check(users.frank, tokenId2);

	//     expect.offer().from(users.dee).exec{value: nuggft.vfo(users.dee, tokenId2)}(tokenId2);
	//     logHotproof();

	//     jumpSwap();

	//     uint256 proofBeforeClaim = nuggft.proof(tokenId);

	//     expect.claim().from(users.frank).exec(array.b24(tokenId), array.bAddress(users.frank));

	//     uint256 proofAfterClaim = nuggft.proof(tokenId);

	//     logHotproof();

	//     ds.emit_log_named_bytes32("proofBeforeOffer", bytes32(proofBeforeOffer));
	//     ds.emit_log_named_bytes32("proofAfterOffer", bytes32(proofAfterOffer));
	//     ds.emit_log_named_bytes32("proofBeforeClaim", bytes32(proofBeforeClaim));
	//     ds.emit_log_named_bytes32("proofAfterClaim", bytes32(proofAfterClaim));

	//     ds.assertNotEq(proofBeforeOffer, 0, "proofBeforeOffer should not be 0");
	//     ds.assertEq(proofAfterOffer, proofBeforeOffer, "proofAfterOffer should be proofBeforeOffer");
	//     ds.assertEq(proofBeforeClaim, proofBeforeOffer, "proofBeforeClaim should be proofBeforeOffer");
	//     ds.assertEq(proofAfterClaim, proofBeforeOffer, "proofAfterClaim should be proofBeforeOffer");
	// }

	// function logHotproof() public clean {

	//     for (uint256 i = 0; i < HOT_PROOF_AMOUNT; i++) {
	//         ds.emit_log_named_bytes32(strings.toAsciiString(i), bytes32(nuggft.hotproof(i)));
	//     }
	// }
}
