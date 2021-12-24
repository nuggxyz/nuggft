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
    using SwapPure for uint96;

    using SafeCastLib for uint256;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  delegate
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc ISwapExternal
    function delegate(address sender, uint160 tokenId) external payable override {
        require(TokenView.isOperatorFor(msg.sender, sender), 'S:0');

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, sender);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise

        if (m.activeEpoch == tokenId && m.swapData == 0) {
            // to ensure we at least have enough to increment the offer amount by 2%
            require(msg.value >= SwapPure.MIN_OFFER, 'S:1');

            // we do not need this, could take tokenId out as an argument - but do not want to give users
            // the ability to accidently place an offer for nugg A and end up minting nugg B.
            assert(m.offerData == 0);

            (uint256 data, ) = SwapPure.buildSwapData(m.activeEpoch, m.sender, msg.value.safe96(), false);

            s.data = data;

            StakeCore.addStakedShareFromMsgValue();

            ProofCore.setProofFromEpoch(tokenId);

            TokenCore.emitTransferEvent(address(0), address(this), tokenId);

            emit DelegateMint(tokenId, m.sender, msg.value.safe96());
        } else {
            require(m.swapData != 0, 'S:4');

            if (m.offerData != 0) {
                require(!m.offerData.isOwner() && m.offerData.epoch() == m.activeEpoch, 'S:3');
            }

            // forces user to claim previously

            if (m.swapData.isOwner()) {
                require(msg.value >= StakeCore.activeEthPerShare(), 'S:5');

                commit(s, m);

                // @todo - this msg.value is incorrect
                emit DelegateCommit(tokenId, msg.sender, msg.value.safe96());
            } else {
                offer(s, m);

                // @todo - this msg.value is incorrect
                emit DelegateOffer(tokenId, msg.sender, msg.value.safe96());
            }
        }
    }

    /// @inheritdoc ISwapExternal
    function delegateItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable override {
        require(TokenView.isOperatorForOwner(msg.sender, buyerTokenId), 'S:6');

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadItemSwap(sellerTokenId, itemId, address(buyerTokenId));

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!m.offerData.isOwner(), 'S:7');

        if (m.offerData == 0 && m.swapData.isOwner()) {
            commit(s, m);

            // @todo - this msg.value is incorrect
            emit DelegateCommitItem(sellerTokenId, itemId, buyerTokenId, msg.value.safe96());
        } else {
            offer(s, m);

            // @todo - this msg.value is incorrect
            emit DelegateOfferItem(sellerTokenId, itemId, buyerTokenId, msg.value.safe96());
        }
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  claim
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc ISwapExternal
    function claim(address sender, uint160 tokenId) external override {
        require(TokenView.isOperatorFor(msg.sender, sender), 'S:8');

        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, sender);

        Swap.deleteTokenOffer(tokenId, sender);

        if (checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteTokenSwap(tokenId);

            TokenCore.checkedTransferFromSelf(sender, tokenId);
        } else {
            SafeTransferLib.safeTransferETH(sender, m.offerData.eth());
        }

        emit SwapClaim(tokenId, sender, m.offerData.epoch());
    }

    /// @inheritdoc ISwapExternal
    function claimItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external override {
        require(TokenView.isOperatorForOwner(msg.sender, buyerTokenId), 'S:9');

        (, Swap.Memory memory m) = Swap.loadItemSwap(sellerTokenId, itemId, address(buyerTokenId));

        Swap.deleteItemOffer(sellerTokenId, itemId, address(buyerTokenId));

        if (checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteItemSwap(sellerTokenId, itemId);

            ProofCore.addItem(buyerTokenId, itemId);
        } else {
            SafeTransferLib.safeTransferETH(TokenView.ownerOf(buyerTokenId), m.offerData.eth());
        }

        emit SwapClaimItem(sellerTokenId, itemId, buyerTokenId, m.swapData.epoch());
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  swap
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc ISwapExternal
    function swap(uint160 tokenId, uint96 floor) external override {
        address sender = TokenView.ownerOf(tokenId);

        require(TokenView.isOperatorFor(msg.sender, sender), 'S:A');

        require(floor >= StakeCore.activeEthPerShare(), 'S:B');

        TokenCore.approvedTransferToSelf(tokenId);

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, sender);

        // make sure swap does not exist - this logically should never happen
        assert(m.swapData == 0);

        (uint256 dat, ) = SwapPure.buildSwapData(0, sender, floor, true);

        s.data = dat;

        emit SwapStart(tokenId, sender, floor);
    }

    /// @inheritdoc ISwapExternal
    function swapItem(
        uint160 sellerTokenId,
        uint16 itemId,
        uint96 floor
    ) external override {
        require(TokenView.isOperatorForOwner(msg.sender, sellerTokenId), 'S:C');

        // will revert if they do not have the item
        ProofCore.removeItem(sellerTokenId, itemId);

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadItemSwap(sellerTokenId, itemId, address(sellerTokenId));

        // cannot sell two of the same item at same time
        require(m.swapData == 0, 'S:D');

        (uint256 dat, ) = SwapPure.buildSwapData(0, address(sellerTokenId), floor, true);

        s.data = dat;

        emit SwapItemStart(sellerTokenId, itemId, dat.eth());
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    view
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // / @inheritdoc ISwapExternal
    function valueForDelegate(address sender, uint160 tokenId)
        external
        view
        override
        returns (
            bool canDelegate,
            uint96 nextSwapAmount,
            uint96 senderCurrentOffer
        )
    {
        canDelegate = true;

        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, sender);

        if (m.swapData == 0) {
            if (m.activeEpoch == tokenId) {
                nextSwapAmount = StakeCore.minSharePrice().compressEthRoundUp();
            } else {
                // swap does not exist
                return (false, 0, 0);
            }
        } else {
            if (m.offerData.isOwner()) canDelegate = false;

            senderCurrentOffer = m.offerData.eth();

            nextSwapAmount = m.swapData.eth();

            if (nextSwapAmount < StakeCore.activeEthPerShare()) {
                nextSwapAmount = StakeCore.activeEthPerShare();
            }
        }

        if (nextSwapAmount == 0) {
            nextSwapAmount = SwapPure.MIN_OFFER;
        } else {
            nextSwapAmount = nextSwapAmount.addIncrement();
        }
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function checkClaimerIsWinnerOrLoser(Swap.Memory memory m) internal pure returns (bool winner) {
        require(m.offerData != 0, 'S:E');

        bool isOver = m.activeEpoch > m.swapData.epoch();
        bool isLeader = m.offerData.account() == m.swapData.account();
        bool isOwner = m.swapData.isOwner() && m.offerData.isOwner();

        return isLeader && (isOwner || isOver);
    }

    function commit(Swap.Storage storage s, Swap.Memory memory m) internal {
        assert(m.offerData == 0 && m.swapData != 0);

        assert(m.swapData.isOwner());

        (uint256 newSwapData, uint96 increment, uint96 dust) = updateSwapDataWithEpoch(
            m.swapData,
            m.activeEpoch + 1,
            m.sender,
            msg.value.safe96()
        );

        s.data = newSwapData;

        s.offers[m.swapData.account()] = m.swapData.epoch(m.activeEpoch + 1).isOwner(false);

        StakeCore.addStakedEth(increment + dust);
    }

    function offer(Swap.Storage storage s, Swap.Memory memory m) internal {
        // make sure swap is still active
        require(m.activeEpoch <= m.swapData.epoch(), 'S:F');

        if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

        (uint256 newSwapData, uint96 increment, uint96 dust) = updateSwapData(m.swapData, m.sender, m.offerData.eth() + msg.value.safe96());

        s.data = newSwapData;

        StakeCore.addStakedEth(increment + dust);
    }

    // @test  manual
    function updateSwapData(
        uint256 prevSwapData,
        address account,
        uint96 newUserOfferEth
    )
        internal
        pure
        returns (
            uint256 res,
            uint96 increment,
            uint96 dust
        )
    {
        return updateSwapDataWithEpoch(prevSwapData, prevSwapData.epoch(), account, newUserOfferEth);
    }

    // @test  unit
    function updateSwapDataWithEpoch(
        uint256 prevSwapData,
        uint32 epoch,
        address account,
        uint96 newUserOfferEth
    )
        internal
        pure
        returns (
            uint256 res,
            uint96 increment,
            uint96 dust
        )
    {
        uint96 baseEth = prevSwapData.eth();

        require(baseEth.addIncrement() <= newUserOfferEth, 'S:G');

        (res, dust) = SwapPure.buildSwapData(epoch, account, newUserOfferEth, false);

        increment = newUserOfferEth - baseEth;
    }
}
