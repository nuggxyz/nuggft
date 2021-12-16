// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IProofExternal} from '../interfaces/INuggFT.sol';

import {Proof} from './storage.sol';

import {EpochView} from '../epoch/view.sol';

import {ProofLogic} from './logic.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ProofExternal is IProofExternal {
    function proofOf(uint256 tokenId) public view virtual override returns (uint256) {
        if (tokenId == EpochView.activeEpoch()) {
            (uint256 p, , , ) = ProofLib.pendingProof();
            return p;
        }

        return ProofView.proofOf(tokenId);
    }

    function parsedProofOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (
            uint256 proof,
            uint256[] memory defaultIds,
            uint256[] memory extraIds,
            uint256[] memory overrides
        )
    {
        return ProofLib.parseProof(Global.ptr(), tokenId);
    }
}
