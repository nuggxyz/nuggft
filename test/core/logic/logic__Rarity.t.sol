pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

import {CastLib} from "../../helpers/CastLib.sol";
import {INuggftV1} from "git.nugg.xyz/nuggft/src/interfaces/INuggftV1.sol";
import {NuggFatherV1Extended} from "git.nugg.xyz/nuggft/test/extend.sol";

import {DotnuggV1Lib} from "git.nugg.xyz/dotnugg/src/DotnuggV1Lib.sol";

abstract contract logic__Rarity is NuggftV1Test {
	error Stupid(uint256);
	error Stupid2(uint256, uint256);

	mapping(uint8 => uint256) picks;
	mapping(uint8 => mapping(uint8 => uint256)) cuml;
	mapping(uint16 => mapping(uint16 => uint16)) rarity;
	mapping(uint8 => uint8) count;

	INuggftV1 instance;

	IxNuggftV1 _xnuggft_;

	IDotnuggV1 _dotnugg_;

	function grrr(uint24 offset) public {
		uint24 start = offset * 10000;
		uint24 end = start + 10000;

		for (uint24 i = start; i < end; i++) {
			uint16[16] memory proof;

			uint24 tokenId = earlyMintable(uint24(i));

			proof = _xnuggft_.floop(tokenId);

			for (uint256 j = 0; j < 16; j++) {
				uint16 item = proof[j];
				(uint8 feature, uint8 pos) = DotnuggV1Lib.parseItemId(item);
				if (item != 0) {
					if (cuml[feature][pos] == 0) {
						// all.push(item);
						count[feature]++;
						rarity[feature][pos] = DotnuggV1Lib.rarity(_dotnugg_, feature, pos);
					}
					cuml[feature][pos]++;
					picks[feature]++;
				}
			}
		}
	}

	function test__logic__Rarity__cumlative() public {
		forge.vm.deal(address(this), type(uint96).max);
		jumpStart();
		jumpSwap();

		NuggFatherV1Extended _instance = new NuggFatherV1Extended{value: STARTING_PRICE * 50000}(bytes32(keccak256("0x")));

		instance = INuggftV1(address(_instance.nuggft()));

		_dotnugg_ = instance.dotnuggv1();
		_xnuggft_ = instance.xnuggftv1();

		for (uint24 i = 0; i < 5; i++) this.grrr(i);

		for (uint8 feature = 0; feature < 8; feature++) {
			uint256 countfeat = _xnuggft_.featureSupply(feature);
			for (uint8 position = 1; position < countfeat + 1; position++) {
				uint16 expected = rarity[feature][position];
				uint16 real = uint16((uint32(cuml[feature][position]) * uint32(type(uint16).max)) / picks[feature]);
				bool negative = expected > real;
				uint16 diff = negative ? expected - real : real - expected;

				// if (uint256(diff) > uint256((uint256(expected) * 3) / 3)) {
				//     revert Stupid2(diff, (uint256(expected) * 3) / 3);
				// }
				ds.assertLt(uint256(diff), uint256((uint256(expected) * 90) / 100), "diff too high");

				// require(uint256(diff) < uint256((uint256(expected) * 3) / 3), "diff too high");
				console.log(
					feature,
					position,
					string.concat(
						" | ",
						negative ? " - " : " + ",
						strings.toAsciiString(diff),
						" | ",
						strings.toAsciiString(expected),
						" / ",
						strings.toAsciiString(real)
					)
				);
			}
			console.log("------------");
		}
	}
}
