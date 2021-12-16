// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../token/TokenLib.sol';
import '../proof/ProofLib.sol';

import './Swap.sol';

import './SwapLib.sol';
import './SwapShiftLib.sol';

import '../libraries/SafeTransferLib.sol';

import '../libraries/EpochLib.sol';
import '../stake/StakeLib.sol';

import '../_test/utils/Print.sol';

library SwapLib {
    using EpochLib for uint256;
    using ShiftLib for uint256;
    using SafeTransferLib for address;
    using QuadMath for uint256;
    using SwapShiftLib for uint256;
    using ProofLib for uint256;

    using Swap for Swap.Storage;
    using StakeLib for Token.Storage;
    using ProofLib for Token.Storage;
    using TokenLib for Token.Storage;

    event Mint(uint256 epoch, address account, uint256 eth);
    event Commit(uint256 tokenid, address account, uint256 eth);
    event Offer(uint256 tokenid, address account, uint256 eth);
    event Claim(uint256 tokenid, uint256 endingEpoch, address account);
    event StartSwap(uint256 tokenid, address account, uint256 eth);

    function checkClaimer(
        uint160 account,
        uint256 swapData,
        uint256 offerData,
        uint256 activeEpoch
    ) internal view returns (bool winner) {
        require(offerData != 0, 'SL:CC:1');

        bool over = activeEpoch > swapData.epoch();

        return swapData.isOwner() || (account == swapData.account() && over);
    }

    function delegate(uint256 genesis, uint256 tokenid) internal {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = nuggft._swaps[tokenid].self.loadStorage(msg.sender);

        if (activeEpoch == tokenid && swapData == 0) {
            mint(nuggft, genesis, tokenid);
        } else if (offerData == 0 && swapData.isOwner()) {
            commit(nuggft, genesis, tokenid);
        } else {
            offer(nuggft, genesis, tokenid);
        }
    }

    function mint(uint256 genesis, uint256 tokenid) internal returns (uint256 newSwapData) {
        require(msg.value >= nuggft.getActiveEthPerShare(), 'SL:M:0');

        Swap.Storage storage _swap = nuggft._swaps[tokenid].self;

        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = _swap.loadStorage(msg.sender);

        // we do not need this, could take tokenid out as an argument - but do not want to give users
        // the ability to accidently place an offer for nugg A and end up minting nugg B.
        require(activeEpoch == tokenid, 'NS:M:0');

        require(swapData == 0 && offerData == 0, 'NS:M:D');

        (newSwapData, ) = uint256(0).epoch(activeEpoch).account(uint160(msg.sender)).eth(msg.value);

        _swap.data = newSwapData;

        nuggft.setProof(tokenid, genesis);

        nuggft.addStakedSharesAndEth(1, msg.value);

        emit Mint(activeEpoch, msg.sender, newSwapData.eth());
    }

    function commit(uint256 genesis, uint256 tokenId) internal {
        Swap.Storage storage _swap = nuggft._swaps[tokenId].self;

        require(msg.value >= nuggft.getActiveEthPerShare(), 'SL:S:0');

        _commitCore(nuggft, _swap, genesis, uint160(msg.sender));

        emit Commit(tokenId, msg.sender, msg.value);
    }

    function _commitCore(
        Swap.Storage storage _swap,
        uint256 genesis,
        uint160 sender
    ) internal {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = _swap.loadStorage(sender);

        require(msg.value > 0, 'SL:COM:2');

        require(offerData == 0 && swapData != 0, 'SL:HSO:0');

        require(swapData.isOwner(), 'SL:HSO:1');

        uint256 _epoch = activeEpoch + 1;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(_epoch).account(sender).eth(msg.value);

        require(swapData.eth().mulDiv(100, 10000) < newSwapData.eth(), 'SL:OBP:4');

        _swap.offers[_epoch][swapData.account()] = swapData;

        _swap.data = newSwapData;

        nuggft.addStakedEth(newSwapData.eth() - swapData.eth() + dust);
    }

    function offer(uint256 genesis, uint256 tokenid) internal {
        Swap.Storage storage _swap = nuggft._swaps[tokenid].self;

        _offerCore(nuggft, _swap, genesis, uint160(msg.sender));

        emit Offer(tokenid, msg.sender, msg.value);
    }

    function _offerCore(
        Swap.Storage storage _swap,
        uint256 genesis,
        uint160 sender
    ) internal {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = _swap.loadStorage(sender);

        require(msg.value > 0, 'SL:OBP:2');

        require(swapData != 0, 'NS:0:0');

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!offerData.isOwner(), 'SL:HSO:0');

        // if (swapData.epoch() == 0 && swapData.isOwner()) swapData = swapData.epoch(activeEpoch + 1);

        // make sure swap is still active
        require(activeEpoch <= swapData.epoch(), 'SL:OBP:3');

        // save prev offers data
        if (swapData.account() != sender) _swap.offers[swapData.epoch()][swapData.account()] = swapData;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(swapData.epoch()).account(sender).eth(offerData.eth() + msg.value);

        require(swapData.eth().mulDiv(100, 10000) < newSwapData.eth(), 'SL:OBP:4');

        _swap.data = newSwapData;

        nuggft.addStakedEth(newSwapData.eth() - swapData.eth() + dust);
    }

    function claim(
        uint256 genesis,
        uint256 tokenid,
        uint256 endingEpoch
    ) internal {
        Swap.Storage storage _swap = nuggft._swaps[tokenid].self;

        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = _swap.loadStorage(msg.sender, endingEpoch);

        delete _swap.offers[endingEpoch][uint160(msg.sender)];

        if (Swap.checkClaimer(uint160(msg.sender), swapData, offerData, activeEpoch)) {
            delete _swap.data;

            if (endingEpoch == swapData.epoch()) {
                nuggft.checkedMintTo(msg.sender, tokenid);
            } else {
                nuggft.checkedTransferFromSelf(msg.sender, tokenid);
            }
        } else {
            msg.sender.safeTransferETH(offerData.eth());
        }

        emit Claim(tokenid, endingEpoch, msg.sender);
    }

    function swap(uint256 tokenid, uint256 floor) internal {
        require(floor >= nuggft.getActiveEthPerShare(), 'SL:S:0');

        Swap.Storage storage _swap = nuggft._swaps[tokenid].self;

        (uint256 swapData, ) = _swap.loadStorage(msg.sender);

        // make sure swap does not exist
        require(swapData == 0, 'NS:SS:0');

        // build starting swap data
        (swapData, ) = swapData.account(uint160(msg.sender)).isOwner(true).eth(floor);

        _swap.data = swapData;

        nuggft.approvedTransferToSelf(msg.sender, tokenid);

        emit StartSwap(tokenid, msg.sender, floor);
    }

    event CommitItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);
    event OfferItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);
    event ClaimItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 endingEpoch);
    event SwapItem(uint256 sellingTokenId, uint256 itemId, uint256 eth);

    function getItemSwap(uint256 sellingTokenId, uint256 itemId) internal view returns (Swap.Storage storage) {
        return nuggft._swaps[sellingTokenId].items[itemId];
    }

    function delegateItem(
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
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 sendingTokenId
    ) internal {
        require(itemId < 0xffff, 'ML:CI:0');

        require(nuggft._ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        Swap.Storage storage _swap = nuggft._swaps[sellingTokenId].items[itemId];

        SwapLib._commitCore(nuggft, _swap, genesis, sendingTokenId);

        emit CommitItem(sellingTokenId, itemId, sendingTokenId, msg.value);
    }

    function offerItem(
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 sendingTokenId
    ) internal {
        require(itemId < 256, 'ML:OI:0');

        require(nuggft._ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        Swap.Storage storage _swap = nuggft._swaps[sellingTokenId].items[itemId];

        SwapLib._offerCore(nuggft, _swap, genesis, sendingTokenId);

        emit OfferItem(sellingTokenId, itemId, sendingTokenId, msg.value);
    }

    function claimItem(
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint256 endingEpoch,
        uint160 buyingTokenId
    ) internal {
        require(nuggft._ownerOf(buyingTokenId) == msg.sender, 'AUC:TT:3');

        require(itemId <= 0xffff, 'ML:CI:0');

        Swap.Storage storage _swap = nuggft._swaps[sellingTokenId].items[itemId];

        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = _swap.loadStorage(buyingTokenId, endingEpoch);

        delete _swap.offers[endingEpoch][buyingTokenId];

        if (Swap.checkClaimer(buyingTokenId, swapData, offerData, activeEpoch)) {
            delete _swap.data;

            ProofLib.push(nuggft, buyingTokenId, itemId);
        } else {
            msg.sender.safeTransferETH(offerData.eth());
        }

        emit ClaimItem(sellingTokenId, itemId, buyingTokenId, endingEpoch);
    }

    function swapItem(
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
