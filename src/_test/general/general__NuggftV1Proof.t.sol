// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';
import {ShiftLib} from '../../libraries/ShiftLib.sol';
import {NuggftV1Proof} from '../../core/NuggftV1Proof.sol';
import {NuggftV1Token} from '../../core/NuggftV1Token.sol';

contract general__NuggftV1Proof is NuggftV1Test, NuggftV1Proof {
    function dotnuggV1ImplementerCallback(uint256 tokenId) public view override returns (IDotnuggV1Metadata.Memory memory data) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {}

    function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {}

    function mint(uint160 tokenId) public payable override {}

    uint256[] trickery;

    function setUp() public {
        trickery.push(ShiftLib.mask(2));
        trickery.push(ShiftLib.mask(92));
        trickery.push(ShiftLib.mask(80));
        trickery.push(ShiftLib.mask(40));
        trickery.push(ShiftLib.mask(34));
        trickery.push(ShiftLib.mask(11));
        trickery.push(ShiftLib.mask(12));
        trickery.push(ShiftLib.mask(14));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toProof
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // function approve(address user, uint256 tokenId) public payable override(NuggftV1Test, NuggftV1Token) {}

    function test__general__NuggftV1Proof__initFromSeed() public {
        featureLengths |= (6 + 2) << (0 * 8);
        featureLengths |= (150 + 92) << (1 * 8);
        featureLengths |= (150 + 80) << (2 * 8);
        featureLengths |= (150 + 40) << (3 * 8);
        featureLengths |= (150 + 34) << (4 * 8);
        featureLengths |= (150 + 11) << (5 * 8);
        featureLengths |= (150 + 12) << (6 * 8);
        featureLengths |= (150 + 14) << (7 * 8);

        for (uint160 i = 0; i < 10000; i++) {
            uint160 woo = 3048309458309485654654654655465129458309483045 + i;

            uint256 seed = uint256(keccak256(abi.encode(woo)));

            uint256 res = initFromSeed(seed);

            proofs[woo] = res;

            (, uint8[] memory ids, , , , ) = proofToDotnuggMetadata(woo);

            for (uint256 j = 0; j < 8; j++) {
                if (ids[j] != 0) {
                    trickery[j] &= ShiftLib.fullsubmask(1, ids[j] - 1);
                    // assertTrue(ids[j] != 1);
                }
            }
        }

        bool broken;
        for (uint256 j = 0; j < 8; j++) {
            broken = broken || trickery[j] != 0;

            console.log(j, trickery[j], broken, Uint256.toHexString(trickery[j], 32));
        }

        assertTrue(!broken);
    }
}
