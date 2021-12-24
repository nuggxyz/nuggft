// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IProofExternal} from '../interfaces/nuggft/IProofExternal.sol';

import {Proof} from './ProofStorage.sol';

import {EpochCore} from '../epoch/EpochCore.sol';

import {ProofCore} from './ProofCore.sol';
import {ProofPure} from './ProofPure.sol';

import {TokenView} from '../token/TokenView.sol';

abstract contract ProofExternal is IProofExternal {
    /// @inheritdoc IProofExternal
    function rotateFeature(uint160 tokenId, uint8 feature) external override {
        require(TokenView.isOperatorForOwner(msg.sender, tokenId), 'P:A');

        uint256 working = ProofCore.checkedProofOf(tokenId);

        working = ProofPure.rotateDefaultandExtra(working, feature);

        working = ProofPure.clearAnchorOverridesForFeature(working, feature);

        Proof.sstore(tokenId, working);

        emit RotateItem(tokenId, working, feature);
    }

    /// @inheritdoc IProofExternal
    function setOverrides(
        uint160 tokenId,
        uint8[] memory xs,
        uint8[] memory ys
    ) external override {
        require(TokenView.isOperatorForOwner(msg.sender, tokenId), 'P:B');

        require(xs.length == 8 && ys.length == 8, 'P:C');

        uint256 working = ProofCore.checkedProofOf(tokenId);

        working = ProofPure.setNewAnchorOverrides(working, xs, ys);

        Proof.sstore(tokenId, working);

        emit SetAnchorOverrides(tokenId, working, xs, ys);
    }

    /// @inheritdoc IProofExternal
    function proofOf(uint160 tokenId) public view virtual override returns (uint256) {
        return ProofCore.checkedProofOfIncludingPending(tokenId);
    }

    /// @inheritdoc IProofExternal
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
