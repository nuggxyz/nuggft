// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IProofExternal} from '../interfaces/nuggft/IProofExternal.sol';

import {Proof} from './ProofStorage.sol';

import {EpochCore} from '../epoch/EpochCore.sol';

import {ProofCore} from './ProofCore.sol';

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
        return ProofCore.checkedProofOfIncludingPending(tokenId);
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
        return ProofCore.parsedProofOfIncludingPending(tokenId);
    }
}
