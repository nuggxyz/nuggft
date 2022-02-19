// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import '../../NuggftV1.test.sol';
import {ShiftLib} from '../../helpers/ShiftLib.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';
import {NuggftV1Token} from '../../../core/NuggftV1Token.sol';

abstract contract logic__NuggftV1Proof is NuggftV1Test {
    //     function dotnuggV1ImplementerCallback(uint256 tokenId) public view override returns (IDotnuggV1Metadata.Memory memory data) {}
    //     function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {}
    //     function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {}
    //     function mint(uint160 tokenId) public payable override {}
    //     function setUp() public {}
    //     /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //         [pure] toProof
    //        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    //     // function approve(address user, uint256 tokenId) public payable override(NuggftV1Test, NuggftV1Token) {}
    //     function test__logic__NuggftV1Proof__initFromSeed() public {
    //         uint256 seed = uint256(keccak256(abi.encodePacked(uint256(0x420691333))));
    //         uint8[] memory lens = new uint8[](8);
    //         uint256[] memory trickery = new uint256[](8);
    //         // lens[0] = (uint8(seed >> 160) & 7) + 1;
    //         // lens[1] = (uint8(seed >> (160 + (8 * 1))) & 0x60) + 1;
    //         // lens[2] = (uint8(seed >> (160 + (8 * 2))) & 0x60) + 1;
    //         // lens[3] = (uint8(seed >> (160 + (8 * 3))) & 0x60) + 1;
    //         // lens[4] = (uint8(seed >> (160 + (8 * 4))) & 0x60) + 1;
    //         // lens[5] = (uint8(seed >> (160 + (8 * 5))) & 0x60) + 1;
    //         // lens[6] = (uint8(seed >> (160 + (8 * 6))) & 0x60) + 1;
    //         // lens[7] = (uint8(seed >> (160 + (8 * 7))) & 0x60) + 1;
    //         lens[0] = 2;
    //         // lens[1] = 92;
    //         // lens[2] = 80;
    //         // lens[3] = 40;
    //         // lens[4] = 34;
    //         // lens[5] = 11;
    //         // lens[6] = 12;
    //         // lens[7] = 14;
    //         // trickery[0] = ShiftLib.mask(lens[0]);
    //         // trickery[1] = ShiftLib.mask(lens[1]);
    //         // trickery[2] = ShiftLib.mask(lens[2]);
    //         // trickery[3] = ShiftLib.mask(lens[3]);
    //         // trickery[4] = ShiftLib.mask(lens[4]);
    //         // trickery[5] = ShiftLib.mask(lens[5]);
    //         // trickery[6] = ShiftLib.mask(lens[6]);
    //         // trickery[7] = ShiftLib.mask(lens[7]);
    //         // featureLengths |= uint256(lens[0]) << (0 * 8);
    //         // featureLengths |= uint256(lens[1]) << (1 * 8);
    //         // featureLengths |= uint256(lens[2]) << (2 * 8);
    //         // featureLengths |= uint256(lens[3]) << (3 * 8);
    //         // featureLengths |= uint256(lens[4]) << (4 * 8);
    //         // featureLengths |= uint256(lens[5]) << (5 * 8);
    //         // featureLengths |= uint256(lens[6]) << (6 * 8);
    //         // featureLengths |= uint256(lens[7]) << (7 * 8);
    //         // for (uint160 i = 0; i < 1000; i++) {
    //         //     uint256 res = initFromSeed(uint256(keccak256(abi.encode(seed + i))));
    //         //     proofs[i] = res;
    //         //     (, uint8[] memory ids, , , , ) = proofToDotnuggMetadata(i);
    //         //     for (uint256 j = 0; j < 8; j++) {
    //         //         if (ids[j] != 0) {
    //         //             trickery[j] &= ShiftLib.imask(1, ids[j] - 1);
    //         //         }
    //         //     }
    //         // }
    //         // bool broken;
    //         // for (uint256 j = 0; j < 8; j++) {
    //         //     broken = broken || trickery[j] != 0;
    //         //     console.log(j, lens[j], broken, Uint256.toHexString(trickery[j], 32));
    //         // }
    //         // assertFalse(broken);
    //     }
}
