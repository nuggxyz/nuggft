// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Swap} from './storage.sol';
import {StakeView} from '../stake/view.sol';
import {StakeCore} from '../stake/core.sol';
import {SwapPure} from '../swap/view.sol';

import {ProofCore} from '../proof/core.sol';

import {TokenCore} from '../token/core.sol';
import {TokenView} from '../token/view.sol';

library SwapCore {
    using SwapPure for uint256;

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Mint(uint256 epoch, address account, uint256 eth);
    event Commit(uint256 tokenId, address account, uint256 eth);
    event Offer(uint256 tokenId, address account, uint256 eth);
    event Claim(uint256 tokenId, uint256 endingEpoch, address account);
    event StartSwap(uint256 tokenId, address account, uint256 eth);

    event CommitItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);
    event OfferItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);
    event ClaimItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 endingEpoch);
    event SwapItem(uint256 sellingTokenId, uint256 itemId, uint256 eth);

    /*///////////////////////////////////////////////////////////////
                            TOKEN HANDLERS
    //////////////////////////////////////////////////////////////*/

    function delegate(uint256 tokenId) internal {
        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!m.offerData.isOwner(), 'SL:HSO:0');

        // // make sure swap is still active
        // require(m.activeEpoch <= m.swapData.epoch(), 'SL:OBP:3');

        // Print.log(m.activeEpoch, 'm.activeEpoch');

        if (m.activeEpoch == tokenId && m.swapData == 0) {
            // we do not need this, could take tokenId out as an argument - but do not want to give users
            // the ability to accidently place an offer for nugg A and end up minting nugg B.
            mint(s, m);

            emit Mint(m.activeEpoch, msg.sender, msg.value);
        } else if (m.offerData == 0 && m.swapData.isOwner()) {
            require(msg.value >= StakeView.getActiveEthPerShare(), 'SL:S:0');

            commit(s, m);

            emit Commit(tokenId, msg.sender, msg.value);
        } else {
            offer(s, m);
            emit Offer(tokenId, msg.sender, msg.value);
        }
    }

    function mint(Swap.Storage storage s, Swap.Memory memory m) internal {
        require(m.swapData == 0 && m.offerData == 0, 'NS:M:D');

        (uint256 newSwapData, ) = uint256(0).epoch(m.activeEpoch).account(uint160(msg.sender)).eth(msg.value);

        // indirectly guards against rentrancy
        s.data = newSwapData;

        StakeCore.addStakedSharesAndEth(1, msg.value);

        ProofCore.setProof(m.activeEpoch);
    }

    function claim(uint256 tokenId) internal {
        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        // require(m.offerData.epoch() == tokenId, 'C:0');

        Swap.deleteTokenOffer(tokenId, uint160(msg.sender));

        if (checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteTokenSwap(tokenId);

            if (tokenId == m.swapData.epoch()) {
                TokenCore.checkedMintTo(msg.sender, tokenId);
            } else {
                TokenCore.checkedTransferFromSelf(msg.sender, tokenId);
            }
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, m.offerData.eth());
        }

        emit Claim(tokenId, 0, msg.sender);
    }

    function swap(uint256 tokenId, uint256 floor) internal {
        require(floor >= StakeView.getActiveEthPerShare(), 'SL:S:0');

        TokenCore.approvedTransferToSelf(tokenId);

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, msg.sender);

        // make sure swap does not exist - this logically should never happen
        assert(m.swapData == 0);
        //  not anymore - as no external calls   protects against reentracy from token transfer
        // require(swapData == 0, 'NS:SS:0');

        // build starting swap data
        (m.swapData, ) = m.swapData.account(uint160(msg.sender)).isOwner(true).eth(floor);

        s.data = m.swapData;

        emit StartSwap(tokenId, msg.sender, floor);
    }

    /*///////////////////////////////////////////////////////////////
                            ITEM HANDLERS
    //////////////////////////////////////////////////////////////*/

    function delegateItem(
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 sendingTokenId
    ) internal {
        require(TokenView.ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadItemSwap(sellingTokenId, itemId, sendingTokenId);

        // Print.log(sellingTokenId, 'sellingTokenId', itemId, 'itemId', sendingTokenId, 'sendingTokenId');

        // Print.log(m.offerData, 'm.offerData', m.swapData, 'm.swapData');

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!m.offerData.isOwner(), 'SL:HSO:0');

        // // make sure swap is still active
        // require(m.activeEpoch <= m.swapData.epoch(), 'SL:OBP:3');

        if (m.offerData == 0 && m.swapData.isOwner()) {
            commit(s, m);

            emit CommitItem(sellingTokenId, itemId, sendingTokenId, msg.value);
        } else {
            offer(s, m);

            emit OfferItem(sellingTokenId, itemId, sendingTokenId, msg.value);
        }
    }

    function claimItem(
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 buyingTokenId
    ) internal {
        require(TokenView.ownerOf(buyingTokenId) == msg.sender, 'AUC:TT:3');

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadItemSwap(sellingTokenId, itemId, buyingTokenId);

        Swap.deleteItemOffer(sellingTokenId, itemId, buyingTokenId);

        if (checkClaimerIsWinnerOrLoser(m)) {
            Swap.deleteItemSwap(sellingTokenId, itemId);

            ProofCore.push(buyingTokenId, itemId);
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, m.offerData.eth());
        }

        emit ClaimItem(sellingTokenId, itemId, buyingTokenId, 0);
    }

    function swapItem(
        uint256 itemId,
        uint256 floor,
        uint160 sellingTokenId
    ) internal {
        require(TokenView.ownerOf(sellingTokenId) == msg.sender, 'AUC:TT:3');

        ProofCore.pop(sellingTokenId, itemId);

        (Swap.Storage storage s, Swap.Memory memory m) = Swap.loadItemSwap(sellingTokenId, itemId, sellingTokenId);

        assert(m.swapData == 0);

        // Print.log(m.offerData, 'm.offerData', m.swapData, 'm.swapData');

        // build starting swap data
        (uint256 dat, ) = uint256(0).account(sellingTokenId).isOwner(true).eth(floor);

        s.data = dat;

        // Print.log(m.offerData, 'm.offerData', m.swapData, 'm.swapData', dat, 'dat');

        // Print.log(sellingTokenId, 'sellingTokenId', itemId, 'itemId', m.sender, 'm.sender');

        emit SwapItem(sellingTokenId, itemId, floor);
    }

    /*///////////////////////////////////////////////////////////////
                            COMMON HANDLERS
    //////////////////////////////////////////////////////////////*/

    function checkClaimerIsWinnerOrLoser(Swap.Memory memory m) internal view returns (bool winner) {
        require(m.offerData != 0, 'SL:CC:1');

        bool isOver = m.activeEpoch > m.swapData.epoch();
        bool isLeader = m.offerData.account() == m.swapData.account();
        bool isOwner = m.swapData.isOwner();

        return isOwner || (isLeader && isOver);
    }

    function commit(Swap.Storage storage s, Swap.Memory memory m) internal {
        // @todo should only be checked externally from here
        // require(offerData == 0 && swapData != 0, 'SL:HSO:0');
        // require(swapData.isOwner(), 'SL:HSO:1');

        uint256 epoch = m.activeEpoch + 1;

        //  copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(epoch).account(m.sender).eth(msg.value);

        require(m.swapData.eth().addIncrement() < newSwapData.eth(), 'SL:OBP:4');

        s.data = newSwapData;

        s.offers[m.swapData.account()] = m.swapData;

        StakeCore.addStakedEth(newSwapData.eth() - m.swapData.eth() + dust);
    }

    function offer(Swap.Storage storage s, Swap.Memory memory m) internal {
        require(m.swapData != 0, 'NS:0:0');

        // make sure swap is still active
        require(m.activeEpoch <= m.swapData.epoch(), 'SL:OBP:3');

        // save prev offers data
        if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(m.swapData.epoch()).account(m.sender).eth(m.offerData.eth() + msg.value);

        require(m.swapData.eth().addIncrement() < newSwapData.eth(), 'SL:OBP:4');

        s.data = newSwapData;

        StakeCore.addStakedEth(newSwapData.eth() - m.swapData.eth() + dust);
    }
}
