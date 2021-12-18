// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {EpochView} from '../epoch/EpochView.sol';

import {ProofPure} from './ProofPure.sol';
import {ProofView} from './ProofView.sol';
import {Proof} from './ProofStorage.sol';

import {VaultPure} from '../vault/VaultPure.sol';
import {Vault} from '../vault/VaultStorage.sol';


import {Print} from '../_test/utils/Print.sol';

library ProofCore {
    using SafeCastLib for uint256;
    using ProofPure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event SetProof(uint160 tokenId, uint16[] items);
    event PopItem(uint160 tokenId, uint16 itemId);
    event PushItem(uint160 tokenId, uint16 itemId);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            ITEM MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function push(uint160 tokenId, uint16 itemId) internal {
        uint256 working = ProofView.checkedProofOf(tokenId);

        require(Proof.ptr().protcolItems[itemId] > 0, '1155:SBTF:1');

        Proof.ptr().protcolItems[itemId]--;

        working = ProofPure.push(working, itemId);

        Proof.set(tokenId, working);

        emit PushItem(tokenId, itemId);
    }

    function pop(uint160 tokenId, uint16 itemId) internal {
        uint256 working = ProofView.checkedProofOf(tokenId);

        require(working != 0, '1155:STF:0');

        working = ProofPure.pop(working, itemId);

        Proof.set(tokenId, working);

        Proof.ptr().protcolItems[itemId]++;

        emit PopItem(tokenId, itemId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            INITIALIZATION
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function setProof(uint160 tokenId) internal {
        require(!ProofView.hasProof(tokenId), 'IL:M:0');

        (uint256 seed, uint256 epoch) = EpochView.calculateSeed();

        require(seed != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        seed = initFromSeed(seed);

        Proof.set(tokenId, seed);

        (, uint16[] memory items, , ) = ProofPure.parseProofLogic(seed);

        // just for fun
        assembly {
            let ptr := mload(items)
            ptr := sub(ptr, 1)
            mstore(items, ptr)
        }

        emit SetProof(tokenId, items);
    }

    function initFromSeed(uint256 seed) internal view returns (uint256 res) {
        require(seed != 0, 'seed');

        uint256 lendata = Vault.ptr().lengthData;

        uint16[] memory upd = new uint16[](4);

        uint8 FULL_SIZE = 16;
        uint8 FEAT_SIZE = 4;
        uint8 POSITION_SIZE = 12;

        uint256 maxPosSize = ShiftLib.mask(POSITION_SIZE);

        uint256 pick0 = ((seed >> (4 + FULL_SIZE * 0)) & maxPosSize) % VaultPure.length(lendata, 0);
        uint256 pick1 = ((seed >> (4 + FULL_SIZE * 1)) & maxPosSize) % VaultPure.length(lendata, 1);

        Print.log(VaultPure.length(lendata, 2), "VaultPure.length(lendata, 2)", lendata, "lendata");
        uint256 pick2 = ((seed >> (4 + FULL_SIZE * 2)) & maxPosSize) % VaultPure.length(lendata, 2);

        uint256 pick3 = (seed >> 69) % 256;

        uint256 num = (seed >> (4 + FULL_SIZE * 3)) & maxPosSize;

        if (pick3 < 96) {
            pick3 = (3 << POSITION_SIZE) | (num % (VaultPure.length(lendata, 3)));
        } else if (pick3 < 192) {
            pick3 = (4 << POSITION_SIZE) | (num % (VaultPure.length(lendata, 4)));
        } else if (pick3 < 250) {
            pick3 = (5 << POSITION_SIZE) | (num % (VaultPure.length(lendata, 5)));
        } else {
            pick3 = (6 << POSITION_SIZE) | (num % (VaultPure.length(lendata, 6)));
        }

        upd[0] = pick0.safe16();
        upd[1] = (pick1 | (1 << POSITION_SIZE)).safe16();
        upd[2] = (pick2 | (2 << POSITION_SIZE)).safe16();
        upd[3] = pick3.safe16();

        res = ShiftLib.setDynamicArray(res, upd, 16, 0, 4, 8);
    }
}
