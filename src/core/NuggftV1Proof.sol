// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Proof} from '../interfaces/nuggftv1/INuggftV1Proof.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {NuggftV1Dotnugg} from './NuggftV1Dotnugg.sol';

import {NuggftV1ProofType} from '../types/NuggftV1ProofType.sol';

abstract contract NuggftV1Proof is INuggftV1Proof, NuggftV1Dotnugg {
    using SafeCastLib for uint160;
    using SafeCastLib for uint256;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                state
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    struct Settings {
        mapping(uint256 => uint256) anchorOverrides;
        // uint8 displayLen; // default 4
    }

    mapping(uint160 => uint256) proofs;

    mapping(uint160 => Settings) settings;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                           external functions
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Proof
    function rotate(
        uint160 tokenId,
        uint8 index0,
        uint8 index1
    ) external override {
        ensureOperatorForOwner(msg.sender, tokenId);

        uint256 working = proofOf(tokenId);

        working = NuggftV1ProofType.swapIndexs(working, index0, index1);

        proofs[tokenId] = working;
    }

    /// @inheritdoc INuggftV1Proof
    function anchor(
        uint160 tokenId,
        uint16 itemId,
        uint256 x,
        uint256 y
    ) external override {
        require(x < 64 && y < 64, 'UNTEESTED:1');

        ensureOperatorForOwner(msg.sender, tokenId);

        settings[tokenId].anchorOverrides[itemId] = x | (y << 6);
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
            uint8[] memory overys
        )
    {
        proof = proofOf(tokenId);

        if (proof == 0) {
            proof = initFromSeed(tryCalculateSeed(tokenId.safe32()));
            require(proof != 0, 'P:L');
        }

        defaultIds = new uint8[](8);
        overxs = new uint8[](8);
        overys = new uint8[](8);

        defaultIds[0] = uint8(proof & ShiftLib.mask(3));

        for (uint8 i = 0; i < 7; i++) {
            uint16 item = NuggftV1ProofType.getIndex(proof, i);

            if (item == 0) continue;

            (uint8 feature, uint8 pos) = NuggftV1ProofType.parseItemId(item);

            if (defaultIds[feature] == 0) {
                uint256 overrides = settings[tokenId].anchorOverrides[item];
                overys[feature] = uint8(overrides >> 6);
                overxs[feature] = uint8(overrides & ShiftLib.mask(6));

                defaultIds[feature] = pos;
            }
        }
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
        ensureOperatorForOwner(msg.sender, tokenId);

        uint256 working = proofOf(tokenId);

        working = NuggftV1ProofType.setIndex(working, NuggftV1ProofType.search(working, 0), itemId);

        proofs[tokenId] = working;
    }

    function removeItem(uint160 tokenId, uint16 itemId) internal {
        ensureOperatorForOwner(msg.sender, tokenId);

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

        uint256 res = initFromSeed(randomEnoughSeed);

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

        uint256 lengths = featureLengths;

        res |= ((safeMod(ShiftLib.get(seed, 8, 0), _lengthOf(lengths, 0))) + 1);
        res |= ((1 << 8) | ((safeMod(ShiftLib.get(seed, 8, 8), _lengthOf(lengths, 1))) + 1)) << 3;
        res |= ((2 << 8) | ((safeMod(ShiftLib.get(seed, 8, 16), _lengthOf(lengths, 2))) + 1)) << (3 + 11);

        uint256 selA = ShiftLib.get(seed, 8, 24);

        uint256 valA = ShiftLib.get(seed, 8, 32);

        uint256 selB = ShiftLib.get(seed, 8, 24);

        uint256 valB = ShiftLib.get(seed, 8, 40);

        if (selA < 128) valA = (3 << 8) | ((safeMod(valA, _lengthOf(lengths, 3))) + 1);
        else valA = (4 << 8) | ((safeMod(valA, _lengthOf(lengths, 4))) + 1);

        res |= (valA) << (3 + 22);

        if (selB < 30) valB = (5 << 8) | ((safeMod(valB, _lengthOf(lengths, 5))) + 1);
        else if (selB < 55) valB = (6 << 8) | ((safeMod(valB, _lengthOf(lengths, 6))) + 1);
        else if (selB < 75) valB = (7 << 8) | ((safeMod(valB, _lengthOf(lengths, 7))) + 1);
        else {
            return res;
        }

        res |= (valB) << (3 + 33);
    }

    function safeMod(uint256 value, uint8 modder) internal pure returns (uint256) {
        require(modder != 0, 'P:9');
        return value.safe8() % modder;
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
