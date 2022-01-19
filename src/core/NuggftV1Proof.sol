// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Proof} from '../interfaces/nuggftv1/INuggftV1Proof.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {CastLib} from '../libraries/CastLib.sol';

import {NuggftV1Dotnugg} from './NuggftV1Dotnugg.sol';

import {NuggftV1ProofType} from '../types/NuggftV1ProofType.sol';

abstract contract NuggftV1Proof is INuggftV1Proof, NuggftV1Dotnugg {
    using CastLib for uint160;
    using CastLib for uint256;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                state
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    mapping(uint160 => uint256) proofs;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                           external functions
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Proof
    function rotate(
        uint160 tokenId,
        uint8 index0,
        uint8 index1
    ) external override {
        require(isAgent(msg.sender, tokenId), hex'60');

        uint256 working = proofOf(tokenId);

        working = NuggftV1ProofType.swapIndexs(working, index0, index1);

        proofs[tokenId] = working;
    }

    /// @inheritdoc INuggftV1Proof
    function proofOf(uint160 tokenId) public view virtual override returns (uint256) {
        if (proofs[tokenId] != 0) return proofs[tokenId];

        (uint256 seed, uint256 epoch, uint256 proof) = pendingProof();

        if (epoch == tokenId && seed != 0) return proof;
        else return 0;
    }

    /// @inheritdoc INuggftV1Proof
    function proofToDotnuggMetadata(uint160 tokenId)
        public
        view
        virtual
        override
        returns (
            uint256 proof,
            uint8[] memory defaultIds,
            uint8[] memory overxs,
            uint8[] memory overys,
            string[] memory styles,
            string memory background
        )
    {
        proof = proofOf(tokenId);

        if (proof == 0) {
            proof = initFromSeed(tryCalculateSeed(tokenId.to24()));
            require(proof != 0, 'P:L');
        }

        defaultIds = new uint8[](8);
        overxs = new uint8[](8);
        overys = new uint8[](8);
        styles = new string[](8);

        defaultIds[0] = uint8(proof & 0x3);

        for (uint8 i = 0; i < 7; i++) {
            uint16 item = NuggftV1ProofType.getIndex(proof, i);

            if (item == 0) continue;

            (uint8 feature, uint8 pos) = NuggftV1ProofType.parseItemId(item);

            if (defaultIds[feature] == 0) {
                uint256 overrides = settings[tokenId].anchorOverrides[item];
                overys[feature] = uint8(overrides >> 6);
                overxs[feature] = uint8(overrides & ShiftLib.mask(6));
                styles[feature] = settings[tokenId].styles[item];

                defaultIds[feature] = pos;
            }
        }

        background = settings[tokenId].background;
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                             internal functions
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function exists(uint160 tokenId) internal view override returns (bool) {
        return proofOf(tokenId) != 0;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            SWAP MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function addItem(uint160 tokenId, uint16 itemId) internal {
        require(isAgent(msg.sender, tokenId), "SHOULDN'T HAPPEN 1");

        uint256 working = proofOf(tokenId);

        working = NuggftV1ProofType.setIndex(working, NuggftV1ProofType.search(working, 0), itemId);

        proofs[tokenId] = working;
    }

    function removeItem(uint160 tokenId, uint16 itemId) internal {
        require(isAgent(msg.sender, tokenId), "SHOULDN'T HAPPEN 2");

        uint256 working = proofOf(tokenId);

        working = NuggftV1ProofType.setIndex(working, NuggftV1ProofType.search(working, itemId), 0);

        proofs[tokenId] = working;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            INITIALIZATION
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function setProof(uint160 tokenId) internal {
        require(proofs[tokenId] == 0, 'P:5');

        uint256 randomEnoughSeed = uint256(keccak256(abi.encodePacked(hex'420690', tokenId, blockhash(block.number - 1))));

        uint256 res = initFromSeed(randomEnoughSeed & ShiftLib.mask(88));

        proofs[tokenId] = res;
    }

    function setProofFromEpoch(uint160 tokenId) internal {
        require(proofs[tokenId] == 0, 'P:6');

        (, uint256 epoch, uint256 res) = pendingProof();

        require(epoch == tokenId, 'P:7');

        proofs[tokenId] = res;
    }

    // TODO TO BE TESTED
    function initFromSeed(uint256 seed) internal view returns (uint256 res) {
        require(seed != 0, 'P:8');

        uint256 l = featureLengths;

        // assembly {
        //     function seeder(dat, feat) -> b {
        //         b := and(shr(mul(feat, 8), dat), 0xff)
        //     }

        //     function id(feat) -> b {
        //         b := shl(0x8, feat)
        //     }

        //     function build(s, dat, feat) -> b {
        //         b := and(shr(mul(feat, 8), dat), 0xff)
        //         if iszero(b) {
        //             revert(0, 0)
        //         }
        //         b := add(0x1, mod(seeder(s, feat), b))

        //         b := or(id(feat), b)

        //         b := shl(add(mul(gt(feat, 0), 3), mul(0xb, feat)), b)
        //     }

        //     let dats := featureLengths.slot

        //     res := or(res, build(seed, l, 0))

        //     res := or(res, build(seed, l, 1))

        //     res := or(res, build(seed, l, 2))

        //     let p1 := seeder(seed, 16)
        //     let p2 := seeder(seed, 17)

        //     switch lt(p1, 128)
        //     case 1 {
        //         res := or(res, build(seed, l, 3))
        //     }
        //     default {
        //         res := or(res, build(seed, l, 5))
        //     }

        //     if lt(p1, 128) {

        //     }

        //     // let ptr := mload(0x40)

        //     // mstore(ptr, sload(featureLengths.slot))
        // }

        res |= ((safeMod(seed & 0xff, _lengthOf(l, 0))) + 1);

        res |= ((1 << 8) | (((((seed >>= 8) & 0xff) % _lengthOf(l, 1))) + 1)) << 3;

        res |= ((2 << 8) | (((((seed >>= 8) & 0xff) % _lengthOf(l, 2))) + 1)) << (14);

        uint256 selA = ((seed >>= 8) & 0xff);

        selA = selA < 128 ? 3 : 4;

        res |= ((selA << 8) | ((safeMod(((seed >>= 8) & 0xff), _lengthOf(l, uint8(selA)))) + 1)) << (3 + 22);

        uint256 selB = ((seed >>= 8) & 0xff);

        selB = selB < 30 ? 5 : selB < 55 ? 6 : selB < 75 ? 7 : 0;

        if (selB != 0) {
            res |= ((selB << 8) | ((safeMod(((seed >>= 8) & 0xff), _lengthOf(l, uint8(selB)))) + 1)) << (3 + 33);
        }

        uint256 selC = ((seed >>= 8) & 0xff);

        selC = selC < 30 ? 5 : selC < 55 ? 6 : selC < 75 ? 7 : selC < 115 ? 4 : selC < 155 ? 3 : selC < 205 ? 2 : 1;

        res |= ((selC << 8) | ((safeMod((seed >>= 8) & 0xff, _lengthOf(l, uint8(selC)))) + 1)) << (3 + 77);
    }

    function safeMod(uint256 value, uint8 modder) internal pure returns (uint256) {
        require(modder != 0, 'P:9');
        return value.to8() % modder;
    }

    function pendingProof()
        internal
        view
        returns (
            uint256 seed,
            uint256 epoch,
            uint256 proof
        )
    {
        (seed, epoch) = calculateSeed();

        proof = initFromSeed(seed);
    }
}
