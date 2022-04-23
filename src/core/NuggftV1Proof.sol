// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {INuggftV1Proof} from "../interfaces/nuggftv1/INuggftV1Proof.sol";
import {IDotnuggV1Safe} from "../interfaces/dotnugg/IDotnuggV1Safe.sol";
import {IERC1155, IERC165} from "../interfaces/IERC721.sol";
import {INuggftV1} from "../interfaces/nuggftv1/INuggftV1.sol";
import {xNuggftV1} from "../xNuggftV1.sol";

import {DotnuggV1Lib, parseItemIdAsString} from "../libraries/DotnuggV1Lib.sol";

import {NuggftV1Epoch} from "./NuggftV1Epoch.sol";
import {NuggftV1Trust} from "./NuggftV1Trust.sol";

abstract contract NuggftV1Proof is INuggftV1Proof, NuggftV1Epoch, NuggftV1Trust {
    function calculateEarlySeed(uint24 tokenId) public view returns (uint256 seed) {
        return uint256(keccak256(abi.encodePacked(tokenId, earlySeed)));
    }

    function premintTokens() public view returns (uint24 first, uint24 last) {
        first = MINT_OFFSET;

        last = first + early - 1;
    }

    function trustedMintTokens() public view returns (uint24 first, uint24 last) {
        (, first) = premintTokens();

        last = first + TRUSTED_MINT_TOKENS;

        // to avoid having to subtract from last
        first++;
    }

    function mintTokens() public view returns (uint24 first, uint24 last) {
        (, first) = trustedMintTokens();

        last = MAX_TOKENS;

        first++;
    }

    /// @inheritdoc INuggftV1Proof
    function proofOf(uint24 tokenId) public view override returns (uint256 res) {
        if ((res = proof[tokenId]) != 0) return res;

        uint256 seed;

        (uint24 first, uint24 last) = premintTokens();

        if (tokenId >= first && tokenId <= last) {
            seed = calculateEarlySeed(tokenId);
        } else {
            uint24 epoch = epoch();

            if (tokenId == epoch + 1) epoch++;

            seed = calculateSeed(epoch);
        }

        if (seed != 0) return initFromSeed(seed);

        _panic(Error__0xAD__InvalidZeroProof);
    }

    function floop(uint24 tokenId) public view returns (uint16[] memory arr) {
        arr = new uint16[](16);
        uint256 proof = proofOf(tokenId);
        // uint256 max = 0;
        for (uint256 i = 0; i < 16; i++) {
            uint16 check = uint16(proof) & 0xffff;
            proof >>= 16;
            if (check != 0) {
                arr[i] = uint16(check);
                // max = i + 1;
            }
        }
    }

    /// @inheritdoc INuggftV1Proof
    function rotate(
        uint24 tokenId,
        uint8[] calldata index0s,
        uint8[] calldata index1s
    ) external override {
        assembly {
            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore8(31, code)
                revert(27, 0x5)
            }

            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)
            let buyerTokenAgency := sload(keccak256(0x00, 0x40))

            // ensure the caller is the agent
            if iszero(eq(juke(buyerTokenAgency, 96, 96), caller())) {
                panic(Error__0xA2__NotItemAgent)
            }

            let flag := shr(254, buyerTokenAgency)

            // ensure the caller is really the agent
            if and(eq(flag, 0x3), iszero(iszero(juke(buyerTokenAgency, 2, 232)))) {
                panic(Error__0xA3__NotItemAuthorizedAgent)
            }

            mstore(0x20, proof.slot)

            let proof__sptr := keccak256(0x00, 0x40)

            let _proof := sload(proof__sptr)

            // extract length of tokenIds array from calldata
            let len := calldataload(sub(index0s.offset, 0x20))

            // ensure arrays the same length
            if iszero(eq(len, calldataload(sub(index1s.offset, 0x20)))) {
                panic(Error__0x76__InvalidArrayLengths)
            }
            mstore(0x00, _proof)

            // prettier-ignore
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                // tokenIds[i]
                let index0 := calldataload(add(index0s.offset, mul(i, 0x20)))

                // accounts[i]
                let index1 := calldataload(add(index1s.offset, mul(i, 0x20)))

                // prettier-ignore
                if or(or(or( // ================================================
                    iszero(index0),           // since we are taking working with external input here, we want
                    iszero(index1)),          // + to make sure the indexs passed are valid (1 <= x <= 16)
                    iszero(gt(16, index0))),
                    iszero(gt(16, index1))
                 ) { panic(Error__0x73__InvalidProofIndex) } // ==============

                _proof := mload(0x00)

                let pos0 := mul(sub(15, index0), 0x2)
                let pos1 := mul(sub(15, index1), 0x2)
                let item0 := and(shr(mul(index0, 16), _proof), 0xffff)
                let item1 := and(shr(mul(index1, 16), _proof), 0xffff)

                mstore8(pos1, shr(8, item0))
                mstore8(add(pos1, 1), item0)
                mstore8(pos0, shr(8, item1))
                mstore8(add(pos0, 1), item1)
            }

            sstore(proof__sptr, mload(0x00))

            log2(0x00, 0x20, Event__Rotate, tokenId)
        }
    }

    // TODO TO BE TESTED
    function initFromSeed(uint256 seed) internal view returns (uint256 res) {
        uint8 selA = uint8((seed >> 8) & 0xff);
        uint8 selB = uint8((seed >> 16) & 0xff);
        uint8 selC = uint8((seed >> 24) & 0xff);

        selA = selA < 128 ? 3 : 4;
        selB = selB < 30 ? 5 : selB < 55 ? 6 : selB < 75 ? 7 : 0;
        selC = selC < 30 ? 5 : selC < 55 ? 6 : selC < 75 ? 7 : selC < 115 ? 4 : selC < 155 ? 3 : selC < 205 ? 2 : 1;

        uint256 a = DotnuggV1Lib.pickWithId(address(dotnuggv1), 0, seed);
        uint256 b = DotnuggV1Lib.pickWithId(address(dotnuggv1), 1, seed);
        uint256 c = DotnuggV1Lib.pickWithId(address(dotnuggv1), 2, seed);
        uint256 d = DotnuggV1Lib.pickWithId(address(dotnuggv1), selA, seed);
        uint256 e = DotnuggV1Lib.pickWithId(address(dotnuggv1), selB, seed);
        uint256 f = DotnuggV1Lib.pickWithId(address(dotnuggv1), selC, seed >> 8);

        res |=
            a |
            (b << (0x10)) | //
            (c << (0x20)) |
            (d << (0x30)) |
            (selB == 0 ? 0 : (e << (0x40))) |
            (f << (0x80));
    }
}
