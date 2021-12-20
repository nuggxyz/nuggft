// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Swap} from './SwapStorage.sol';
import {SwapPure} from '../swap/SwapPure.sol';

import {StakeView} from '../stake/StakeView.sol';
import {StakeCore} from '../stake/StakeCore.sol';

import {ProofCore} from '../proof/ProofCore.sol';

import {TokenCore} from '../token/TokenCore.sol';
import {TokenView} from '../token/TokenView.sol';

library SwapCore {
    using SafeCastLib for uint256;
    using SwapPure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event DelegateMint(uint256 epoch, address account, uint96 eth);
    event DelegateCommit(uint160 tokenId, address account, uint96 eth);
    event DelegateOffer(uint160 tokenId, address account, uint96 eth);
    event SwapClaim(uint160 tokenId, address account, uint32 epoch);
    event SwapStart(uint160 tokenId, address account, uint96 eth);

    event DelegateCommitItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint96 eth);
    event DelegateOfferItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint96 eth);
    event SwapClaimItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint32 epoch);
    event SwapItemStart(uint160 sellingTokenId, uint16 itemId, uint96 eth);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            TOKEN SWAP FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice Explain to an end user what this does
    /// @dev E
    /// @param tokenId a
    /// @custom:test hardhat
    ///
    function delegate(uint160 tokenId) internal {
        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise

        if (m.activeEpoch == tokenId && m.swapData == 0) {
            // we do not need this, could take tokenId out as an argument - but do not want to give users
            // the ability to accidently place an offer for nugg A and end up minting nugg B.
            mint(s, m);

            emit DelegateMint(tokenId, msg.sender, msg.value.safe96());

            return;
        }

        require(!m.offerData.isOwner(), 'SL:HSO:0');

        require(m.swapData != 0, 'NS:0:0');

        if (m.offerData == 0 && m.swapData.isOwner()) {
            require(msg.value >= StakeView.getActiveEthPerShare(), 'SL:S:0');

            commit(s, m);

            emit DelegateCommit(tokenId, msg.sender, msg.value.safe96());
        } else {
            offer(s, m);

            emit DelegateOffer(tokenId, msg.sender, msg.value.safe96());
        }
    }

    function mint(Swap.Storage storage s, Swap.Memory memory m) internal {
        require(m.swapData == 0 && m.offerData == 0, 'NS:M:D');

        (uint256 dat, ) = SwapPure.buildSwapData(m.activeEpoch, uint160(msg.sender), msg.value.safe96(), false);

        s.data = dat;

        StakeCore.addStakedShareAndEth(msg.value.safe96());

        ProofCore.setProof(m.activeEpoch);
    }

    function claim(uint160 tokenId) internal {
        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        Swap.deleteTokenOffer(tokenId, uint160(msg.sender));

        if (checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteTokenSwap(tokenId);

            // if this is a minting nugg
            if (tokenId == m.swapData.epoch()) {
                TokenCore.checkedMintTo(msg.sender, tokenId);
            } else {
                TokenCore.checkedTransferFromSelf(msg.sender, tokenId);
            }
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, m.offerData.eth());
        }

        emit SwapClaim(tokenId, msg.sender, m.swapData.epoch());
    }

    function unsafeClaimERC721To(uint160 tokenId, address to) internal {}

    function swap(uint160 tokenId, uint96 floor) internal {
        require(floor >= StakeView.getActiveEthPerShare(), 'SL:S:0');

        TokenCore.approvedTransferToSelf(tokenId);

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        // make sure swap does not exist - this logically should never happen
        assert(m.swapData == 0);

        (uint256 dat, ) = SwapPure.buildSwapData(0, uint160(msg.sender), msg.value.safe96(), true);

        s.data = dat;

        emit SwapStart(tokenId, msg.sender, floor);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            ITEM SWAP FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function delegateItem(
        uint160 sellingTokenId,
        uint16 itemId,
        uint160 sendingTokenId
    ) internal {
        require(TokenView.ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadItemSwap(sellingTokenId, itemId, sendingTokenId);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!m.offerData.isOwner(), 'SL:HSO:0');

        if (m.offerData == 0 && m.swapData.isOwner()) {
            commit(s, m);

            emit DelegateCommitItem(sellingTokenId, itemId, sendingTokenId, msg.value.safe96());
        } else {
            offer(s, m);

            emit DelegateOfferItem(sellingTokenId, itemId, sendingTokenId, msg.value.safe96());
        }
    }

    function claimItem(
        uint160 sellingTokenId,
        uint16 itemId,
        uint160 buyingTokenId
    ) internal {
        require(TokenView.ownerOf(buyingTokenId) == msg.sender, 'AUC:TT:3');

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

    function swapItem(
        uint16 itemId,
        uint96 floor,
        uint160 sellingTokenId
    ) internal {
        require(TokenView.ownerOf(sellingTokenId) == msg.sender, 'AUC:TT:3');

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
                            COMMON FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkClaimerIsWinnerOrLoser(Swap.Memory memory m) internal pure returns (bool winner) {
        require(m.offerData != 0, 'SL:CC:1');

        bool isOver = m.activeEpoch > m.swapData.epoch();
        bool isLeader = m.offerData.account() == m.swapData.account();
        bool isOwner = m.swapData.isOwner();

        return isOwner || (isLeader && isOver);
    }

    function commit(Swap.Storage storage s, Swap.Memory memory m) internal {
        assert(m.offerData == 0 && m.swapData != 0);

        assert(m.swapData.isOwner());

        (uint256 newSwapData, uint256 increment, uint256 dust) = SwapPure.updateSwapDataWithEpoch(
            m.swapData,
            m.activeEpoch + 1,
            m.sender,
            msg.value.safe96()
        );

        s.data = newSwapData;

        s.offers[m.swapData.account()] = m.swapData;

        StakeCore.addStakedEth((increment + dust).safe96());
    }

    function offer(Swap.Storage storage s, Swap.Memory memory m) internal {
        // make sure swap is still active
        require(m.activeEpoch <= m.swapData.epoch(), 'SL:OBP:3');

        if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

        (uint256 newSwapData, uint256 increment, uint256 dust) = SwapPure.updateSwapData(
            m.swapData,
            m.sender,
            m.offerData.eth() + msg.value.safe96()
        );

        s.data = newSwapData;

        StakeCore.addStakedEth((increment + dust).safe96());
    }
}
