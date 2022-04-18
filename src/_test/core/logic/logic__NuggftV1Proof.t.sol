// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";
import {ShiftLib} from "../../helpers/ShiftLib.sol";
import {NuggftV1Proof} from "../../../core/NuggftV1Proof.sol";

abstract contract logic__NuggftV1Proof is NuggftV1Test {
    //     function dotnuggV1ImplementerCallback(uint256 tokenId) public view override returns (IDotnuggV1Metadata.Memory memory data) {}
    //     function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {}
    //     function trustedMint(uint24 tokenId, address to) external payable override requiresTrust {}
    //     function mint(uint24 tokenId) public payable override {}
    //     function setUp() public {}
    //     /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //         [pure] toProof
    //        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    //     // function approve(address user, uint256 tokenId) public payable override(NuggftV1Test, NuggftV1Token) {}
    function test__logic__NuggftV1Proof__initFromSeed() public {
        uint256 seed = uint256(keccak256(abi.encodePacked(uint256(0x420691333))));
        uint8[] memory lens = new uint8[](8);
        uint256[] memory trickery = new uint256[](8);

        lens[0] = DotnuggV1Lib.lengthOf(address(processor), 0);
        lens[1] = DotnuggV1Lib.lengthOf(address(processor), 1);
        lens[2] = DotnuggV1Lib.lengthOf(address(processor), 2);
        lens[3] = DotnuggV1Lib.lengthOf(address(processor), 3);
        lens[4] = DotnuggV1Lib.lengthOf(address(processor), 4);
        lens[5] = DotnuggV1Lib.lengthOf(address(processor), 5);
        lens[6] = DotnuggV1Lib.lengthOf(address(processor), 6);
        lens[7] = DotnuggV1Lib.lengthOf(address(processor), 7);

        trickery[0] = ShiftLib.mask(lens[0]);
        trickery[1] = ShiftLib.mask(lens[1]);
        trickery[2] = ShiftLib.mask(lens[2]);
        trickery[3] = ShiftLib.mask(lens[3]);
        trickery[4] = ShiftLib.mask(lens[4]);
        trickery[5] = ShiftLib.mask(lens[5]);
        trickery[6] = ShiftLib.mask(lens[6]);
        trickery[7] = ShiftLib.mask(lens[7]);

        for (uint24 i = 0; i < 3000; i++) {
            for (uint8 j = 0; j < 8; j++) {
                trickery[j] &= ShiftLib.imask(1, nuggft.external__search(j, (seed << 16) | i) - 1);
            }
        }
        bool broken;
        for (uint256 j = 0; j < 8; j++) {
            broken = broken || trickery[j] != 0;
            console.log(j, Uint256.toHexString(trickery[j], 32));
        }
        assertFalse(broken);
    }
}
