// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {INuggftV1Proof} from '../interfaces/nuggftv1/INuggftV1Proof.sol';

import {DotnuggV1Lib} from '../libraries/DotnuggV1Lib.sol';

import {NuggftV1Dotnugg} from './NuggftV1Dotnugg.sol';

abstract contract NuggftV1Proof is INuggftV1Proof, NuggftV1Dotnugg {
    mapping(uint160 => uint256) proofs;

    /// @inheritdoc INuggftV1Proof
    function proofOf(uint160 tokenId) public view override returns (uint256 res) {
        if (proofs[tokenId] != 0) return proofs[tokenId];

        uint24 epoch = epoch();

        if (tokenId == epoch + 1) epoch++;

        uint256 seed = calculateSeed(epoch);

        if (seed != 0) return initFromSeed(seed);

        // TODO revert here after playing with graph
    }

    function floop(uint160 tokenId) public view returns (bytes2[] memory arr) {
        arr = new bytes2[](16);
        uint256 proof = proofOf(tokenId);
        uint256 max = 0;
        for (uint256 i = 0; i < 16; i++) {
            uint16 check = uint16(proof) & 0xfff;
            proof >>= 16;
            if (check != 0) {
                arr[i] = bytes2(check);
                max = i + 1;
            }
        }
    }

    /// @notice parses the external itemId into a feautre and position
    /// @dev this follows dotnugg v1 specification
    /// @param itemId -> the external itemId
    /// @return feat -> the feautre of the item
    /// @return pos -> the file storage position of the item
    function parseItemId(uint16 itemId) internal pure returns (uint8 feat, uint8 pos) {
        feat = uint8(itemId >> 8);
        pos = uint8(itemId & 0xff);
    }

    /// @inheritdoc INuggftV1Proof
    function rotate(
        uint160 tokenId,
        uint8[] calldata index0s,
        uint8[] calldata index1s
    ) external override {
        assembly {
            function iso(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }

            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore(0x04, code)
                revert(0x00, 0x05)
            }

            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)
            let buyerTokenAgency := sload(keccak256(0x00, 0x40))

            // ensure the caller is the agent
            if iszero(eq(iso(buyerTokenAgency, 96, 96), caller())) {
                panic(Error__0xA2__NotItemAgent)
            }

            let flag := shr(254, buyerTokenAgency)

            // ensure the caller is really the agent
            if and(eq(flag, 0x3), iszero(iszero(iso(buyerTokenAgency, 2, 232)))) {
                panic(Error__0xA3__NotItemAuthorizedAgent)
            }

            mstore(0x20, proofs.slot)

            let proof__sptr := keccak256(0x00, 0x40)

            let proof := sload(proof__sptr)

            // extract length of tokenIds array from calldata
            let len := calldataload(sub(index0s.offset, 0x20))

            // ensure arrays the same length
            if iszero(eq(len, calldataload(sub(index1s.offset, 0x20)))) {
                panic(Error__0x76__InvalidArrayLengths)
            }
            mstore(0x00, proof)

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

                proof := mload(0x00)

                let pos0 := mul(sub(0xf, index0), 0x2)
                let pos1 := mul(sub(0xf, index1), 0x2)
                let item0 := and(shr(mul(index0, 16), proof), 0xffff)
                let item1 := and(shr(mul(index1, 16), proof), 0xffff)

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

        res |=
            DotnuggV1Lib.search(address(dotnuggV1), 0, seed) |
            (uint256(0x0100 | DotnuggV1Lib.search(address(dotnuggV1), 1, seed)) << (0x10)) |
            (uint256(0x0200 | DotnuggV1Lib.search(address(dotnuggV1), 2, seed)) << (0x20)) |
            (uint256((uint16(selA) << 8) | DotnuggV1Lib.search(address(dotnuggV1), selA, seed)) << (0x30)) |
            (selB == 0 ? 0 : (uint256((uint16(selB) << 8) | DotnuggV1Lib.search(address(dotnuggV1), selB, seed)) << (0x40))) |
            (uint256((uint16(selC) << 8) | DotnuggV1Lib.search(address(dotnuggV1), selC, seed >> 8)) << (0x80));
    }
}
