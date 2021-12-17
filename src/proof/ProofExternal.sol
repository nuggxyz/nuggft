// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IProofExternal} from '../interfaces/INuggFT.sol';

import {Proof} from './ProofStorage.sol';

import {EpochView} from '../epoch/EpochView.sol';

import {ProofCore} from './ProofCore.sol';
import {ProofView} from './ProofView.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ProofExternal is IProofExternal {
    function proofOf(uint256 tokenId) public view virtual override returns (uint256) {
        if (tokenId == EpochView.activeEpoch()) {
            (uint256 p, , , ) = ProofView.pendingProof();
            return p;
        }

        return ProofView.checkedProofOfIncludingPending(tokenId);
    }

    function parsedProofOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (
            uint256 proof,
            uint16[] memory defaultIds,
            uint16[] memory extraIds,
            uint16[] memory overrides
        )
    {
        return ProofView.parseProof(tokenId);
    }
}
