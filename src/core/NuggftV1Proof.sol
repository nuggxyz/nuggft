// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Proof} from '../interfaces/nuggftv1/INuggftV1Proof.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {NuggftV1File} from './NuggftV1File.sol';

import {NuggftV1ProofType} from '../types/NuggftV1ProofType.sol';

abstract contract NuggftV1Proof is INuggftV1Proof, NuggftV1File {
    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                state
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    mapping(uint160 => uint256) proofs;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                           external functions
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Proof
    function rotateFeature(uint160 tokenId, uint8 feature) external override {
        require(_isOperatorForOwner(msg.sender, tokenId), 'P:A');

        uint256 working = checkedProofOf(tokenId);

        working = NuggftV1ProofType.rotateDefaultandExtra(working, feature);

        working = NuggftV1ProofType.clearAnchorOverridesForFeature(working, feature);

        proofs[tokenId] = working;

        emit RotateItem(tokenId, working, feature);
    }

    /// @inheritdoc INuggftV1Proof
    function setOverrides(
        uint160 tokenId,
        uint8[] memory xs,
        uint8[] memory ys
    ) external override {
        require(_isOperatorForOwner(msg.sender, tokenId), 'P:B');

        require(xs.length == 8 && ys.length == 8, 'P:C');

        uint256 working = checkedProofOf(tokenId);

        working = NuggftV1ProofType.setNewAnchorOverrides(working, xs, ys);

        proofs[tokenId] = working;

        emit SetAnchorOverrides(tokenId, working, xs, ys);
    }

    /// @inheritdoc INuggftV1Proof
    function proofOf(uint160 tokenId) public view virtual override returns (uint256) {
        return checkedProofOfIncludingPending(tokenId);
    }

    /// @inheritdoc INuggftV1Proof
    function parsedProofOf(uint160 tokenId)
        public
        view
        virtual
        override
        returns (
            uint256 proof,
            uint8[] memory defaultIds,
            uint8[] memory extraIds,
            uint8[] memory overxs,
            uint8[] memory overys
        )
    {
        return parsedProofOfIncludingPending(tokenId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                             internal functions
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function exists(uint160 tokenId) internal view override returns (bool) {
        return proofs[tokenId] != 0;
    }

    function checkedProofOf(uint160 tokenId) internal view returns (uint256 res) {
        res = proofs[tokenId];
        require(res != 0, 'P:0');
    }

    function checkedProofOfIncludingPending(uint160 tokenId) internal view returns (uint256 res) {
        (uint256 seed, uint256 epoch, uint256 proof, ) = pendingProof();

        if (epoch == tokenId && seed != 0) return proof;

        res = proofs[tokenId];

        require(res != 0, 'P:1');
    }

    function hasProof(uint160 tokenId) internal view returns (bool res) {
        res = proofs[tokenId] != 0;
    }

    function parsedProofOfIncludingPending(uint160 tokenId)
        internal
        view
        returns (
            uint256 proof,
            uint8[] memory defaultIds,
            uint8[] memory extraIds,
            uint8[] memory overxs,
            uint8[] memory overys
        )
    {
        proof = checkedProofOfIncludingPending(tokenId);

        return NuggftV1ProofType.fullProof(proof);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            SWAP MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function addItem(uint160 tokenId, uint16 itemId) internal {
        require(_isOperatorForOwner(msg.sender, tokenId), 'P:2');

        uint256 working = checkedProofOf(tokenId);

        working = NuggftV1ProofType.pushToExtra(working, itemId);

        proofs[tokenId] = working;

        emit PushItem(tokenId, working, itemId);
    }

    function removeItem(uint160 tokenId, uint16 itemId) internal {
        require(_isOperatorForOwner(msg.sender, tokenId), 'P:4');

        uint256 working = checkedProofOf(tokenId);

        working = NuggftV1ProofType.pullFromExtra(working, itemId);

        proofs[tokenId] = working;

        emit PopItem(tokenId, working, itemId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            INITIALIZATION
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function setProof(uint160 tokenId) internal {
        require(!hasProof(tokenId), 'P:5');

        uint256 randomEnoughSeed = uint256(keccak256(abi.encodePacked(hex'420690', tokenId, blockhash(block.number - 1))));

        (uint256 res, uint8[] memory picks) = initFromSeed(randomEnoughSeed);

        proofs[tokenId] = res;

        emit SetProof(tokenId, res, picks);
    }

    function setProofFromEpoch(uint160 tokenId) internal {
        require(!hasProof(tokenId), 'P:6');

        (, uint256 epoch, uint256 res, uint8[] memory picks) = pendingProof();

        require(epoch == tokenId, 'P:7');

        proofs[tokenId] = res;

        emit SetProof(tokenId, res, picks);
    }

    // TODO TO BE TESTED
    function initFromSeed(uint256 seed) internal view returns (uint256 res, uint8[] memory upd) {
        require(seed != 0, 'P:8');

        uint8[] memory lengths = ShiftLib.getArray(featureLengths, 0);

        upd = new uint8[](8);

        uint8[] memory picks = ShiftLib.getArray(seed, 0);

        upd[0] = (safeMod(picks[0], lengths[0])) + 1;
        upd[1] = (safeMod(picks[1], lengths[1])) + 1;
        upd[2] = (safeMod(picks[2], lengths[2])) + 1;

        if (picks[3] < 60) upd[3] = (safeMod(picks[4], lengths[3])) + 1;
        else if (picks[3] < 120) upd[4] = (safeMod(picks[4], lengths[4])) + 1;
        else if (picks[3] < 180) upd[5] = (safeMod(picks[4], lengths[5])) + 1;
        else if (picks[3] < 240) upd[6] = (safeMod(picks[4], lengths[6])) + 1;
        else upd[7] = (safeMod(picks[4], lengths[7])) + 1;

        res = ShiftLib.setArray(res, 0, upd);
    }

    function safeMod(uint8 value, uint8 modder) internal pure returns (uint8) {
        require(modder != 0, 'P:9');
        return value % modder;
    }

    function pendingProof()
        internal
        view
        returns (
            uint256 seed,
            uint256 epoch,
            uint256 proof,
            uint8[] memory defaultIds
        )
    {
        (seed, epoch) = calculateSeed();

        (proof, defaultIds) = initFromSeed(seed);
    }
}
