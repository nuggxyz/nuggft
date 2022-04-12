pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

import {CastLib} from "../../helpers/CastLib.sol";

import {parseItemId, decodeProof} from "../../../libraries/DotnuggV1Lib.sol";

abstract contract logic__Rarity is NuggftV1Test {
    error Stupid(uint256);
    error Stupid2(uint256, uint256);

    mapping(uint8 => uint256) picks;
    mapping(uint8 => mapping(uint8 => uint256)) cuml;
    mapping(uint16 => mapping(uint16 => uint16)) rarity;
    mapping(uint8 => uint8) count;

    function grrr(uint24 offset) public {
        uint24 start = offset * 10000;
        uint24 end = start + 10000;
        for (uint24 i = start; i < end; i++) {
            uint16[] memory proof;

            uint24 tokenId = mintable(uint24(i));
            nuggft.mint(tokenId);
            proof = nuggft.floop(tokenId);
            for (uint256 j = 0; j < 16; j++) {
                uint16 item = proof[j];
                (uint8 feature, uint8 pos) = parseItemId(item);
                if (item != 0) {
                    if (cuml[feature][pos] == 0) {
                        // all.push(item);
                        count[feature]++;
                        rarity[feature][pos] = nuggft.rarity(feature, pos);
                    }
                    cuml[feature][pos]++;
                    picks[feature]++;
                }
            }
        }
    }

    function test__logic__Rarity__cumlative() public {
        jumpStart();
        jumpSwap();
        for (uint24 i = 0; i < 5; i++) this.grrr(i);

        for (uint8 feature = 0; feature < 8; feature++) {
            uint256 countfeat = nuggft.featureLength(feature);
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
