// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

import '@openzeppelin/contracts/utils/Address.sol';

import '../token/TokenLib.sol';
import '../proof/ProofLib.sol';

import './Swap.sol';

import './SwapLib.sol';
import './SwapType.sol';

import '../libraries/EpochLib.sol';

library SwapItemLib {
    using EpochLib for uint256;
    using ShiftLib for uint256;
    using Address for address payable;
    using QuadMath for uint256;

    using SwapType for uint256;
    using Swap for Swap.Storage;

    using ProofLib for uint256;

    using Token for Token.Storage;

    event CommitItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);

    event OfferItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);

    event ClaimItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 endingEpoch);

    event SwapItem(uint256 sellingTokenId, uint256 itemId, uint256 eth);

    function getSwap(
        Token.Storage storage nuggft,
        uint256 sellingTokenId,
        uint256 itemId
    ) internal returns (Swap.Storage storage) {
        return nuggft._swaps[sellingTokenId].items[itemId];
    }

    function delegateItem(
        Token.Storage storage nuggft,
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 sendingTokenId
    ) internal {
        require(nuggft._ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        Swap.Storage storage _swap = nuggft._swaps[sellingTokenId].items[itemId];

        (uint256 swapData, uint256 offerData) = _swap.loadStorage(sendingTokenId);

        if (offerData == 0 && swapData.isOwner()) {
            commitItem(nuggft, genesis, sellingTokenId, itemId, sendingTokenId);
        } else {
            offerItem(nuggft, genesis, sellingTokenId, itemId, sendingTokenId);
        }
    }

    function commitItem(
        Token.Storage storage nuggft,
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 sendingTokenId
    ) internal {
        require(itemId < 0xffff, 'ML:CI:0');

        require(nuggft._ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        Swap.Storage storage _swap = nuggft._swaps[sellingTokenId].items[itemId];

        SwapLib._commitCore(_swap, genesis, sendingTokenId);

        emit CommitItem(sellingTokenId, itemId, sendingTokenId, msg.value);
    }

    function offerItem(
        Token.Storage storage nuggft,
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 sendingTokenId
    ) internal {
        require(itemId < 256, 'ML:OI:0');

        require(nuggft._ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        Swap.Storage storage _swap = nuggft._swaps[sellingTokenId].items[itemId];

        SwapLib._offerCore(_swap, genesis, sendingTokenId);

        emit OfferItem(sellingTokenId, itemId, sendingTokenId, msg.value);
    }

    function claimItem(
        Token.Storage storage nuggft,
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint256 endingEpoch,
        uint160 buyingTokenId
    ) internal {
        require(nuggft._ownerOf(buyingTokenId) == msg.sender, 'AUC:TT:3');

        require(itemId < 0xffff, 'ML:CI:0');

        Swap.Storage storage _swap = nuggft._swaps[sellingTokenId].items[itemId];

        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = _swap.loadStorage(buyingTokenId, endingEpoch);

        delete _swap.offers[endingEpoch][buyingTokenId];

        if (Swap.checkClaimer(buyingTokenId, swapData, offerData, activeEpoch)) {
            delete _swap.data;

            ProofLib.push(nuggft, buyingTokenId, itemId);
        } else {
            payable(msg.sender).sendValue(offerData.eth());
        }

        emit ClaimItem(sellingTokenId, itemId, endingEpoch, buyingTokenId);
    }

    function swapItem(
        Token.Storage storage nuggft,
        uint256 itemId,
        uint256 floor,
        uint160 sellingTokenId
    ) internal {
        require(nuggft._ownerOf(sellingTokenId) == msg.sender, 'AUC:TT:3');

        require(itemId < 0xffff, 'ML:SI:0');

        Swap.Storage storage _swap = nuggft._swaps[sellingTokenId].items[itemId];

        (uint256 swapData, ) = _swap.loadStorage(sellingTokenId);

        // make sure swap does not exist
        require(swapData == 0, 'NS:SS:0');

        // build starting swap data
        (swapData, ) = swapData.account(sellingTokenId).isOwner(true).eth(floor);

        _swap.data = swapData;

        ProofLib.pop(nuggft, sellingTokenId, itemId);

        emit SwapItem(sellingTokenId, itemId, floor);
    }
}
