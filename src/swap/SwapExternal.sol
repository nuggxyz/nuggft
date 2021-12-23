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

    event log_named_uint(string key, uint256 val);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  delegate
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc ISwapExternal
    function delegate(uint160 tokenId) external payable override {
        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        emit log_named_uint('m.activeEpoch', m.activeEpoch);

        emit log_named_uint('tokenId', tokenId);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise

        if (m.activeEpoch == tokenId && m.swapData == 0) {
            // require(msg.value > 0, 'S:9');

            // we do not need this, could take tokenId out as an argument - but do not want to give users
            // the ability to accidently place an offer for nugg A and end up minting nugg B.
            require(m.offerData == 0, 'S:3');

            (uint256 data, uint96 dust) = SwapPure.buildSwapData(m.activeEpoch, uint160(msg.sender), msg.value.safe96(), false);

            require(msg.value >= SwapPure.MIN_OFFER && dust != msg.value, 'S:13');

            s.data = data;

            StakeCore.addStakedShareAndEth(msg.value.safe96());

            ProofCore.setProofFromEpoch(tokenId);

            TokenCore.emitTransferEvent(address(0), address(this), tokenId);

            emit DelegateMint(tokenId, msg.sender, msg.value.safe96());
        } else {
            require(!m.offerData.isOwner(), 'S:0');

            // forces user to claim previously
            if (m.offerData != 0) require(m.offerData.epoch() == m.activeEpoch, 'S:EPO:12');

            require(m.swapData != 0, 'S:1');

            if (m.swapData.isOwner()) {
                require(msg.value >= StakeCore.activeEthPerShare(), 'S:2');

                commit(s, m);

                emit DelegateCommit(tokenId, msg.sender, msg.value.safe96());
            } else {
                offer(s, m);

                emit DelegateOffer(tokenId, msg.sender, msg.value.safe96());
            }
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
            commit(s, m);

            emit DelegateCommitItem(sellingTokenId, itemId, buyingTokenId, msg.value.safe96());
        } else {
            offer(s, m);

            emit DelegateOfferItem(sellingTokenId, itemId, buyingTokenId, msg.value.safe96());
        }
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  claim
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc ISwapExternal
    function claim(uint160 tokenId) external override {
        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        Swap.deleteTokenOffer(tokenId, uint160(msg.sender));

        if (checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteTokenSwap(tokenId);

            TokenCore.checkedTransferFromSelf(msg.sender, tokenId);
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, m.offerData.eth());
        }

        emit SwapClaim(tokenId, msg.sender, m.offerData.epoch());
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

        if (checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteItemSwap(sellingTokenId, itemId);

            ProofCore.addItem(buyingTokenId, itemId);
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, m.offerData.eth());
        }

        emit SwapClaimItem(sellingTokenId, itemId, buyingTokenId, m.swapData.epoch());
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  swap
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
                                    view
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    // / @inheritdoc ISwapExternal
    function valueForDelegate(uint160 tokenId, address user)
        external
        view
        override
        returns (
            bool canDelegate,
            uint96 nextSwapAmount,
            uint96 userCurrentOffer
        )
    {
        canDelegate = true;

        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, user);

        if (m.swapData == 0) {
            if (m.activeEpoch == tokenId) {
                nextSwapAmount = StakeCore.minSharePrice().compressEthRoundUp();
            } else {
                return (false, 0, 0);
            }
        } else {
            if (m.offerData.isOwner()) canDelegate = false;

            userCurrentOffer = m.offerData.eth();

            nextSwapAmount = m.swapData.eth();

            if (nextSwapAmount < StakeCore.activeEthPerShare()) {
                nextSwapAmount = StakeCore.activeEthPerShare();
            }
        }

        if (nextSwapAmount == 0) {
            nextSwapAmount = SwapPure.MIN_OFFER;
            // nextSwapAmount = nextSwapAmount.addIncrement();
        } else {
            nextSwapAmount = nextSwapAmount.addIncrement();
        }
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkClaimerIsWinnerOrLoser(Swap.Memory memory m) internal pure returns (bool winner) {
        require(m.offerData != 0, 'S:8');

        bool isOver = m.activeEpoch > m.swapData.epoch();
        bool isLeader = m.offerData.account() == m.swapData.account();
        bool isOwner = m.swapData.isOwner();

        return isOwner || (isLeader && isOver);
    }

    function commit(Swap.Storage storage s, Swap.Memory memory m) internal {
        assert(m.offerData == 0 && m.swapData != 0);

        assert(m.swapData.isOwner());

        (uint256 newSwapData, uint256 increment, uint256 dust) = updateSwapDataWithEpoch(
            m.swapData,
            m.activeEpoch + 1,
            m.sender,
            msg.value.safe96()
        );

        s.data = newSwapData;

        s.offers[m.swapData.account()] = m.swapData.epoch(m.activeEpoch + 1);

        StakeCore.addStakedEth((increment + dust).safe96());
    }

    function offer(Swap.Storage storage s, Swap.Memory memory m) internal {
        // make sure swap is still active
        require(m.activeEpoch <= m.swapData.epoch(), 'SL:OBP:3');

        if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

        (uint256 newSwapData, uint256 increment, uint256 dust) = updateSwapData(
            m.swapData,
            m.sender,
            m.offerData.eth() + msg.value.safe96()
        );

        s.data = newSwapData;

        StakeCore.addStakedEth((increment + dust).safe96());
    }

    // @test  manual
    function updateSwapData(
        uint256 prevSwapData,
        uint160 account,
        uint96 newUserOfferEth
    )
        internal
        pure
        returns (
            uint256 res,
            uint256 increment,
            uint256 dust
        )
    {
        return updateSwapDataWithEpoch(prevSwapData, prevSwapData.epoch(), account, newUserOfferEth);
    }

    // @test  unit
    function updateSwapDataWithEpoch(
        uint256 prevSwapData,
        uint32 epoch,
        uint160 account,
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

        require(baseEth.addIncrement() <= newUserOfferEth, 'E:1');

        (res, dust) = SwapPure.buildSwapData(epoch, account, newUserOfferEth, false);

        increment = newUserOfferEth - baseEth;
    }
}
