// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IProofExternal} from '../interfaces/INuggFT.sol';

import {Proof} from './ProofStorage.sol';

import {EpochView} from '../epoch/EpochView.sol';

import {ProofCore} from './ProofCore.sol';
import {ProofView} from './ProofView.sol';

// OK
/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ProofExternal is IProofExternal {
    function rotateFeature(uint160 tokenId, uint8 feature) external override {
        ProofCore.rotateFeature(tokenId, feature);
    }

    function setOverrides(
        uint160 tokenId,
        uint8[] memory xs,
        uint8[] memory ys
    ) external override {
        ProofCore.setAnchorOverrides(tokenId, xs, ys);
    }

    function proofOf(uint160 tokenId) public view virtual override returns (uint256) {
        return ProofView.checkedProofOfIncludingPending(tokenId);
    }

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
        return ProofView.parsedProofOfIncludingPending(tokenId);
    }
}
