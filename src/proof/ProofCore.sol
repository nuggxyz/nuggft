// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {EpochView} from '../epoch/EpochView.sol';

import {Proof} from './ProofStorage.sol';

import {ProofPure} from './ProofPure.sol';
import {ProofView} from './ProofView.sol';

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

    event SetProof(uint160 tokenId, uint8[] items);
    event PopItem(uint160 tokenId, uint16 itemId);
    event PushItem(uint160 tokenId, uint16 itemId);
    event RotateItem(uint160 tokenId, uint8 feature);

    // function migrate() internal {
    //     // send the tokenId, proof and value to new address
    //     // burn the token here
    // }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            ITEM MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function addItem(uint160 tokenId, uint16 itemId) internal {
        require(TokenView.ownerOf(tokenId) == msg.sender, 'PC:0');

        uint256 working = ProofView.checkedProofOf(tokenId);

        require(Proof.ptr().protcolItems[itemId] > 0, 'RC:3');

        Proof.ptr().protcolItems[itemId]--;

        working = ProofPure.pushToExtra(working, itemId);

        Proof.set(tokenId, working);

        emit PushItem(tokenId, itemId);
    }

    function removeItem(uint160 tokenId, uint16 itemId) internal {
        require(TokenView.ownerOf(tokenId) == msg.sender, 'PC:1');

        uint256 working = ProofView.checkedProofOf(tokenId);

        working = ProofPure.pullFromExtra(working, itemId);

        Proof.set(tokenId, working);

        Proof.ptr().protcolItems[itemId]++;

        emit PopItem(tokenId, itemId);
    }

    function rotateFeature(uint160 tokenId, uint8 feature) internal {
        require(TokenView.ownerOf(tokenId) == msg.sender, 'PC:2');

        uint256 working = ProofView.checkedProofOf(tokenId);

        working = ProofPure.rotateDefaultandExtra(working, feature);

        Proof.set(tokenId, working);

        emit RotateItem(tokenId, feature);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            INITIALIZATION
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

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
        (seed, epoch) = EpochView.calculateSeed();

        (proof, defaultIds) = ProofCore.initFromSeed(seed);
    }

    function setProof(uint160 tokenId) internal {
        require(!ProofView.hasProof(tokenId), 'IL:M:0');

        (uint256 seed, uint256 epoch, uint256 res, uint8[] memory picks) = pendingProof();

        require(seed != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        Proof.set(tokenId, res);

        emit SetProof(tokenId, picks);
    }

    function initFromSeed(uint256 seed) internal view returns (uint256 res, uint8[] memory upd) {
        require(seed != 0, 'seed');

        uint8[] memory lengths = FileView.totalLengths();

        upd = new uint8[](8);

        uint8[] memory picks = ShiftLib.getArray(seed, 0);

        upd[0] = (picks[0] % lengths[0]) + 1;
        upd[1] = (picks[1] % lengths[1]) + 1;
        upd[2] = (picks[2] % lengths[2]) + 1;

        if (picks[3] < 96) upd[3] = (picks[4] % lengths[3]) + 1;
        else if (picks[3] < 192) upd[4] = (picks[4] % lengths[4]) + 1;
        else if (picks[3] < 250) upd[5] = (picks[4] % lengths[5]) + 1;
        else upd[6] = (picks[4] % lengths[6]) + 1;

        res = ShiftLib.setArray(res, 0, upd);
    }
}

// uint256 pick3 = (seed >> 69) % mask;

// uint256 num = (seed >> (4 + FULL_SIZE * 3)) & mask;
// uint256 mask = type(uint8).max;

// upd[0] = ((seed >> (4 + FULL_SIZE * 0)) & mask) % lengths[0];
// upd[1] = ((seed >> (4 + FULL_SIZE * 1)) & mask) % lengths[2];
// upd[2] pick2 = ((seed >> (4 + FULL_SIZE * 2)) & mask) % lengths[2];
