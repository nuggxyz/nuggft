// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/storage.sol';

import '../epoch/storage.sol';

import './pure.sol';

library ProofLogic {
    using ProofPure for uint256;

    event SetProof(uint256 tokenId, uint256[] items);
    event PopItem(uint256 tokenId, uint256 itemId);
    event PushItem(uint256 tokenId, uint256 itemId);
    event OpenSlot(uint256 tokenId);

    function setProof(uint256 tokenId, uint256 genesis) internal {
        require(!hasProof(global, tokenId), 'IL:M:0');

        (uint256 seed, uint256 epoch) = EpochLib.calculateSeed(genesis);

        require(seed != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        uint256 lendata = global._vault.lengthData;

        seed = ProofShiftLib.initFromSeed(lendata, seed);

        global._proofs[tokenId] = seed;

        (, uint256[] memory items, , ) = ProofShiftLib.parseProofLogic(seed);

        emit SetProof(tokenId, items);
    }

    function push(uint256 tokenId, uint256 itemId) internal {
        uint256 working = proofOf(global, tokenId);

        require(global._ownedItems[itemId] > 0, '1155:SBTF:1');

        global._ownedItems[itemId]--;

        working = ProofShiftLib.push(working, itemId);

        global._proofs[tokenId] = working;

        emit PushItem(tokenId, itemId);
    }

    function pop(uint256 tokenId, uint256 itemId) internal {
        uint256 working = proofOf(global, tokenId);

        require(working != 0, '1155:STF:0');

        working = ProofShiftLib.pop(working, itemId);

        global._proofs[tokenId] = working;

        global._ownedItems[itemId]++;

        emit PopItem(tokenId, itemId);
    }
}
