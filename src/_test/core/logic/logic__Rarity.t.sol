pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

import {CastLib} from "../../helpers/CastLib.sol";

import {parseItemId} from "../../../libraries/DotnuggV1Lib.sol";

abstract contract logic__Rarity is NuggftV1Test {
    mapping(uint8 => uint256) picks;
    mapping(uint8 => mapping(uint8 => uint256)) cuml;
    mapping(uint16 => mapping(uint16 => uint16)) rarity;
    mapping(uint8 => uint8) count;

    function test__logic__Rarity__cumlative() public {
        jumpStart();
        jumpSwap();
        for (uint24 i = 0; i < 10000; i++) {
            uint160 tokenId = mintable(i);
            nuggft.mint(tokenId);
            uint16[] memory proof = nuggft.floop(tokenId);
            for (uint256 j = 0; j < 16; j++) {
                uint16 item = uint16(proof[j]);
                (uint8 feature, uint8 pos) = parseItemId(item);
                if (item != 0) {
                    if (cuml[feature][pos] == 0) {
                        // all.push(item);
                        count[feature]++;
                        rarity[feature][pos] = nuggft.rarity(uint8((item >> 8)), uint8(item));
                    }
                    cuml[feature][pos]++;
                    picks[feature]++;
                }
            }
        }
        for (uint8 feature = 0; feature < 8; feature++) {
            for (uint8 position = 1; position < count[feature] + 1; position++) {
                uint16 expected = rarity[feature][position];
                uint16 real = uint16((uint32(cuml[feature][position]) * uint32(type(uint16).max)) / picks[feature]);
                bool negative = expected > real;
                uint16 diff = negative ? expected - real : real - expected;
                ds.assertLt(uint256(diff), uint256((uint256(expected) * 3) / 3), "diff too high");
                // console.log(
                //     feature,
                //     position,
                //     string.concat(
                //         " | ",
                //         negative ? " - " : " + ",
                //         strings.toAsciiString(diff),
                //         " | ",
                //         strings.toAsciiString(expected),
                //         " / ",
                //         strings.toAsciiString(real)
                //     )
                // );
            }
            console.log("------------");
        }
    }
}
