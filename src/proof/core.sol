// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {EpochView} from '../epoch/view.sol';

import {ProofPure} from './pure.sol';
import {ProofView} from './view.sol';
import {Proof} from './storage.sol';

import {VaultPure} from '../vault/pure.sol';
import {Vault} from '../vault/storage.sol';

library ProofCore {
    using ProofPure for uint256;

    event SetProof(uint256 tokenId, uint256[] items);
    event PopItem(uint256 tokenId, uint256 itemId);
    event PushItem(uint256 tokenId, uint256 itemId);

    // event OpenSlot(uint256 tokenId);

    function setProof(uint256 tokenId) internal {
        // Print.log(tokenId, 'tokenId');

        if (ProofView.hasProof(tokenId)) {
            // Print.log(ProofView.checkedProofOf(tokenId), 'ProofView.checkedProofOf(tokenId)');
        }

        require(!ProofView.hasProof(tokenId), 'IL:M:0');

        (uint256 seed, uint256 epoch) = EpochView.calculateSeed();

        require(seed != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        seed = initFromSeed(seed);

        Proof.set(tokenId, seed);

        // Print.log(tokenId, 'tokenId');

        (, uint256[] memory items, , ) = ProofPure.parseProofLogic(seed);

        emit SetProof(tokenId, items);
    }

    function push(uint256 tokenId, uint256 itemId) internal {
        uint256 working = ProofView.checkedProofOf(tokenId);

        require(Proof.ptr().protcolItems[itemId] > 0, '1155:SBTF:1');

        Proof.ptr().protcolItems[itemId]--;

        working = ProofPure.push(working, itemId);

        Proof.set(tokenId, working);

        emit PushItem(tokenId, itemId);
    }

    function pop(uint256 tokenId, uint256 itemId) internal {
        uint256 working = ProofView.checkedProofOf(tokenId);

        require(working != 0, '1155:STF:0');

        working = ProofPure.pop(working, itemId);

        Proof.set(tokenId, working);

        Proof.ptr().protcolItems[itemId]++;

        emit PopItem(tokenId, itemId);
    }

    function initFromSeed(uint256 seed) internal view returns (uint256 res) {
        require(seed != 0, 'seed');

        uint256 lendata = Vault.ptr().lengthData;

        uint256[] memory upd = new uint256[](4);

        uint256 ID_SIZE = 16;
        uint256 ID_FEATURE_SIZE = 4;
        uint256 ID_NUMBER_SIZE = 12;

        uint256 pick0 = ((seed >> (4 + ID_SIZE * 0)) & ShiftLib.mask(ID_NUMBER_SIZE)) % VaultPure.length(lendata, 0);
        uint256 pick1 = ((seed >> (4 + ID_SIZE * 1)) & ShiftLib.mask(ID_NUMBER_SIZE)) % VaultPure.length(lendata, 1);
        uint256 pick2 = ((seed >> (4 + ID_SIZE * 2)) & ShiftLib.mask(ID_NUMBER_SIZE)) % VaultPure.length(lendata, 2);

        uint256 pick3 = (seed >> 69) % 256;

        uint256 num = (seed >> (4 + ID_SIZE * 3)) & ShiftLib.mask(ID_NUMBER_SIZE);

        if (pick3 < 96) {
            pick3 = (3 << ID_NUMBER_SIZE) | (num % (VaultPure.length(lendata, 3)));
        } else if (pick3 < 192) {
            pick3 = (4 << ID_NUMBER_SIZE) | (num % (VaultPure.length(lendata, 4)));
        } else if (pick3 < 250) {
            pick3 = (5 << ID_NUMBER_SIZE) | (num % (VaultPure.length(lendata, 5)));
        } else {
            pick3 = (6 << ID_NUMBER_SIZE) | (num % (VaultPure.length(lendata, 6)));
        }

        upd[0] = pick0;
        upd[1] = pick1 | (1 << ID_NUMBER_SIZE);
        upd[2] = pick2 | (2 << ID_NUMBER_SIZE);
        upd[3] = pick3;

        // Print.log(upd, 'upd');

        res = ShiftLib.setDynamicArray(res, upd, 16, 0, 4, 8);
    }
}
