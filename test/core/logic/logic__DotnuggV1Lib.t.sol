// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "@nuggft-v1-core/test/main.sol";
import {DotnuggV1Lib} from "@dotnugg-v1-core/src/DotnuggV1Lib.sol";

abstract contract logic__DotnuggV1Lib is NuggftV1Test {
	function test__logic__DotnuggV1Lib__ratityX128__2() public {
		mintHelper(mintable(100), users.frank, 1 ether);
		ds.inject.log(DotnuggV1Lib.lengthOf(dotnugg, 0));
		// ds.inject.logBytes32(bytes32(DotnuggV1Lib.rarityX128(address( dotnugg), nuggft.proof(600))));
	}

	function test__logic__DotnuggV1Lib__ratityX128() public {
		ds.inject.logBytes32(bytes32(bytes2(DotnuggV1Lib.rarity(dotnugg, 0, 2))));
	}
}
