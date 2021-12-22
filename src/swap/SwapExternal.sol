// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ISwapExternal} from '../interfaces/nuggft/ISwapExternal.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {EpochCore} from '../epoch/EpochCore.sol';

import {StakeCore} from '../stake/StakeCore.sol';

import {Swap} from './SwapStorage.sol';
import {SwapCore} from './SwapCore.sol';
import {SwapPure} from './SwapPure.sol';
import {TokenCore} from '../token/TokenCore.sol';
import {TokenView} from '../token/TokenView.sol';
import {ProofCore} from '../proof/ProofCore.sol';

abstract contract SwapExternal is ISwapExternal {
    using SwapPure for uint256;
    using SafeCastLib for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  DELEGATE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc ISwapExternal
    function delegate(uint160 tokenId) external payable override {
        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise

        if (m.activeEpoch == tokenId && m.swapData == 0) {
            // we do not need this, could take tokenId out as an argument - but do not want to give users
            // the ability to accidently place an offer for nugg A and end up minting nugg B.
            require(m.swapData == 0 && m.offerData == 0, 'S:3');

            (uint256 dat, ) = SwapPure.buildSwapData(m.activeEpoch, uint160(msg.sender), msg.value.safe96(), false);

            s.data = dat;

            TokenCore.checkedPreMintFromSwap(m.activeEpoch);

            emit DelegateMint(tokenId, msg.sender, msg.value.safe96());

            return;
        }

        require(!m.offerData.isOwner(), 'S:0');

        require(m.swapData != 0, 'S:1');

        if (m.offerData == 0 && m.swapData.isOwner()) {
            //
            require(msg.value >= StakeCore.activeEthPerShare(), 'S:2');

            SwapCore.commit(s, m);

            emit DelegateCommit(tokenId, msg.sender, msg.value.safe96());
        } else {
            SwapCore.offer(s, m);

            emit DelegateOffer(tokenId, msg.sender, msg.value.safe96());
        }
    }

    /// @inheritdoc ISwapExternal
    function delegateItem(
        uint160 sellingTokenId,
        uint16 itemId,
        uint160 buyingTokenId
    ) external payable override {
        require(TokenView.ownerOf(buyingTokenId) == msg.sender, 'S:5');

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadItemSwap(sellingTokenId, itemId, buyingTokenId);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!m.offerData.isOwner(), 'SL:HSO:0');

        if (m.offerData == 0 && m.swapData.isOwner()) {
            SwapCore.commit(s, m);

            emit DelegateCommitItem(sellingTokenId, itemId, buyingTokenId, msg.value.safe96());
        } else {
            SwapCore.offer(s, m);

            emit DelegateOfferItem(sellingTokenId, itemId, buyingTokenId, msg.value.safe96());
        }
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  CLAIM
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc ISwapExternal
    function claim(uint160 tokenId) external override {
        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        Swap.deleteTokenOffer(tokenId, uint160(msg.sender));

        if (SwapCore.checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteTokenSwap(tokenId);

            TokenCore.checkedTransferFromSelf(msg.sender, tokenId);
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, m.offerData.eth());
        }

        emit SwapClaim(tokenId, msg.sender, m.swapData.epoch());
    }

    /// @inheritdoc ISwapExternal
    function claimItem(
        uint160 sellingTokenId,
        uint16 itemId,
        uint160 buyingTokenId
    ) external override {
        require(TokenView.ownerOf(buyingTokenId) == msg.sender, 'S:6');

        (, Swap.Memory memory m) = Swap.loadItemSwap(sellingTokenId, itemId, buyingTokenId);

        Swap.deleteItemOffer(sellingTokenId, itemId, buyingTokenId);

        if (SwapCore.checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteItemSwap(sellingTokenId, itemId);

            ProofCore.addItem(buyingTokenId, itemId);
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, m.offerData.eth());
        }

        emit SwapClaimItem(sellingTokenId, itemId, buyingTokenId, m.swapData.epoch());
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  SWAP
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc ISwapExternal
    function swap(uint160 tokenId, uint96 floor) external override {
        require(floor >= StakeCore.activeEthPerShare(), 'S:4');

        TokenCore.approvedTransferToSelf(tokenId);

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        // make sure swap does not exist - this logically should never happen
        assert(m.swapData == 0);

        (uint256 dat, ) = SwapPure.buildSwapData(0, uint160(msg.sender), floor, true);

        s.data = dat;

        emit SwapStart(tokenId, msg.sender, floor);
    }

    /// @inheritdoc ISwapExternal
    function swapItem(
        uint160 sellingTokenId,
        uint16 itemId,
        uint96 floor
    ) external override {
        require(TokenView.ownerOf(sellingTokenId) == msg.sender, 'S:7');

        // will revert if they do not have the item
        ProofCore.removeItem(sellingTokenId, itemId);

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadItemSwap(sellingTokenId, itemId, sellingTokenId);

        // cannot sell two of the same item at same time
        require(m.swapData == 0, 'SC:SI:0');

        (uint256 dat, ) = SwapPure.buildSwapData(0, sellingTokenId, floor, true);

        s.data = dat;

        emit SwapItemStart(sellingTokenId, itemId, dat.eth());
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc ISwapExternal
    function valueForDelegate(uint160 tokenId) external view override returns (uint96 amount) {
        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, address(0));

        if (m.activeEpoch == tokenId && m.swapData == 0) {
            return StakeCore.minSharePrice();
        }

        if (m.swapData == 0) return 0;

        uint96 nextOfferMin = uint256(m.swapData.eth()).addIncrement().safe96();

        if (m.offerData == 0 && m.swapData.isOwner() && nextOfferMin >= StakeCore.minSharePrice()) return 0;

        return nextOfferMin;
    }
}
