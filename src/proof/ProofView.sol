// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {Global} from '../global/GlobalStorage.sol';

import {EpochView} from '../epoch/EpochView.sol';

import {ProofCore} from './ProofCore.sol';

import {ProofPure} from './ProofPure.sol';

import {Proof} from './ProofStorage.sol';

// OK
library ProofView {
    function checkedProofOf(uint160 tokenId) internal view returns (uint256 res) {
        res = Proof.get(tokenId);
        require(res != 0, 'PROOF:PO:0');
    }

    function checkedProofOfIncludingPending(uint160 tokenId) internal view returns (uint256 res) {
        (uint256 seed, uint256 epoch, uint256 proof, ) = ProofCore.pendingProof();

        if (epoch == tokenId && seed != 0) return proof;

        res = Proof.get(tokenId);

        require(res != 0, 'PO:1');
    }

    function hasProof(uint160 tokenId) internal view returns (bool res) {
        res = Proof.get(tokenId) != 0;
    }

    // function parseProof(uint160 tokenId)
    //     internal
    //     view
    //     returns (
    //         uint256 proof,
    //         uint8[] memory defaultIds,
    //         uint8[] memory extraIds,
    //         uint8[] memory overxs,
    //         uint8[] memory overys
    //     )
    // {
    //     proof = checkedProofOf(tokenId);

    //     return ProofPure.fullProof(proof);
    // }

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
}
