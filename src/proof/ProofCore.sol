// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {EpochCore} from '../epoch/EpochCore.sol';

import {Proof} from './ProofStorage.sol';

import {ProofPure} from './ProofPure.sol';

import {TokenView} from '../token/TokenView.sol';

import {FileView} from '../file/FileView.sol';
import {File} from '../file/FileStorage.sol';

// OK
library ProofCore {
    using SafeCastLib for uint256;
    using ProofPure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event SetProof(uint160 tokenId, uint256 proof, uint8[] items);
    event PopItem(uint160 tokenId, uint256 proof, uint16 itemId);
    event PushItem(uint160 tokenId, uint256 proof, uint16 itemId);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkedProofOf(uint160 tokenId) internal view returns (uint256 res) {
        res = Proof.sload(tokenId);
        require(res != 0, 'P:0');
    }

    function checkedProofOfIncludingPending(uint160 tokenId) internal view returns (uint256 res) {
        (uint256 seed, uint256 epoch, uint256 proof, ) = ProofCore.pendingProof();

        if (epoch == tokenId && seed != 0) return proof;

        res = Proof.sload(tokenId);

        require(res != 0, 'P:1');
    }

    function hasProof(uint160 tokenId) internal view returns (bool res) {
        res = Proof.sload(tokenId) != 0;
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

        return ProofPure.fullProof(proof);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            SWAP MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function addItem(uint160 tokenId, uint16 itemId) internal {
        require(TokenView.isOperatorForOwner(msg.sender, tokenId), 'P:2');

        uint256 working = checkedProofOf(tokenId);

        require(Proof.spointer().protcolItems[itemId] > 0, 'P:3');

        Proof.spointer().protcolItems[itemId]--;

        working = ProofPure.pushToExtra(working, itemId);

        Proof.sstore(tokenId, working);

        emit PushItem(tokenId, working, itemId);
    }

    function removeItem(uint160 tokenId, uint16 itemId) internal {
        require(TokenView.isOperatorForOwner(msg.sender, tokenId), 'P:4');

        uint256 working = checkedProofOf(tokenId);

        working = ProofPure.pullFromExtra(working, itemId);

        Proof.sstore(tokenId, working);

        Proof.spointer().protcolItems[itemId]++;

        emit PopItem(tokenId, working, itemId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            INITIALIZATION
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function setProof(uint160 tokenId) internal {
        require(!hasProof(tokenId), 'P:5');

        uint256 randomEnoughSeed = uint256(keccak256(abi.encodePacked(hex'420690', tokenId, blockhash(block.number - 1))));

        (uint256 res, uint8[] memory picks) = ProofCore.initFromSeed(randomEnoughSeed);

        Proof.sstore(tokenId, res);

        emit SetProof(tokenId, res, picks);
    }

    function setProofFromEpoch(uint160 tokenId) internal {
        require(!hasProof(tokenId), 'P:6');

        (, uint256 epoch, uint256 res, uint8[] memory picks) = pendingProof();

        require(epoch == tokenId, 'P:7');

        Proof.sstore(tokenId, res);

        emit SetProof(tokenId, res, picks);
    }

    // TODO TO BE TESTED
    function initFromSeed(uint256 seed) internal view returns (uint256 res, uint8[] memory upd) {
        require(seed != 0, 'P:8');

        uint8[] memory lengths = FileView.totalLengths();

        upd = new uint8[](8);

        uint8[] memory picks = ShiftLib.getArray(seed, 0);

        upd[0] = (safeMod(picks[0], lengths[0])) + 1;
        upd[1] = (safeMod(picks[1], lengths[1])) + 1;
        upd[2] = (safeMod(picks[2], lengths[2])) + 1;

        if (picks[3] < 96) upd[3] = (safeMod(picks[4], lengths[3])) + 1;
        else if (picks[3] < 192) upd[4] = (safeMod(picks[4], lengths[4])) + 1;
        else if (picks[3] < 250) upd[5] = (safeMod(picks[4], lengths[5])) + 1;
        else upd[6] = (safeMod(picks[4], lengths[6])) + 1;

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
        (seed, epoch) = EpochCore.calculateSeed();

        (proof, defaultIds) = ProofCore.initFromSeed(seed);
    }
}
