pragma solidity 0.8.4;
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import 'hardhat/console.sol';
import './ShiftLib.sol';
import './QuadMath.sol';
import './SwapLib.sol';
import './EpochLib.sol';
import './ERC721Lib.sol';
import './ItemLib.sol';

library MoveLib {
    using EpochLib for uint256;
    using SwapLib for SwapLib.Storage;
    using ShiftLib for uint256;
    using Address for address payable;
    using ERC721Lib for ERC721Lib.Storage;
    using ItemLib for ItemLib.Storage;

    using QuadMath for uint256;

    event Mint(uint256 epoch, address account, uint256 eth);

    event Commit(uint256 tokenid, address account, uint256 eth);

    event Offer(uint256 tokenid, address account, uint256 eth);

    event Claim(uint256 tokenid, uint256 endingEpoch, address account);

    event Swap(uint256 tokenid, address account, uint256 eth);

    event CommitItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);

    event OfferItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);

    event ClaimItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 endingEpoch);

    event SwapItem(uint256 sellingTokenId, uint256 itemId, uint256 eth);

    function delegate(
        SwapLib.Storage storage s,
        // ERC721Lib.Storage storage e,
        ItemLib.Storage storage i,
        uint256 genesis,
        uint256 tokenid,
        address payable xnugg
    ) internal {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = s.loadStorage(msg.sender);

        if (activeEpoch == tokenid && swapData == 0) {
            mint(s, i, genesis, tokenid, xnugg);
        } else if (offerData == 0 && swapData.isOwner()) {
            commit(s, tokenid, xnugg, genesis);
        } else {
            offer(s, tokenid, xnugg, genesis);
        }
    }

    function delegateItem(
        SwapLib.Storage storage s,
        ERC721Lib.Storage storage e,
        // ItemLib.Storage storage i,
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 sendingTokenId,
        address payable xnugg
    ) internal {
        require(e.ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        (uint256 swapData, uint256 offerData) = s.loadStorage(sendingTokenId);

        if (offerData == 0 && swapData.isOwner()) {
            commitItem(s, e, genesis, sellingTokenId, itemId, sendingTokenId, xnugg);
        } else {
            offerItem(s, e, genesis, sellingTokenId, itemId, sendingTokenId, xnugg);
        }
    }

    function mint(
        SwapLib.Storage storage s,
        ItemLib.Storage storage i,
        uint256 genesis,
        uint256 tokenid,
        address payable xnugg
    ) internal returns (uint256 newSwapData) {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = s.loadStorage(msg.sender);

        // we do not need this, could take tokenid out as an argument - but do not want to give users
        // the ability to accidently place an offer for nugg A and end up minting nugg B.
        require(activeEpoch == tokenid, 'NS:M:0');

        require(swapData == 0, 'NS:M:D');

        (newSwapData, ) = uint256(0).epoch(activeEpoch).account(uint160(msg.sender)).eth(msg.value);

        s.data = newSwapData;

        if (msg.value > 0) xnugg.sendValue(msg.value);

        i.premint(tokenid, genesis);

        emit Mint(activeEpoch, msg.sender, newSwapData.eth());
    }

    function commit(
        SwapLib.Storage storage s,
        uint256 tokenid,
        address payable xnugg,
        uint256 genesis
    ) internal {
        _commitCore(s, uint160(msg.sender), xnugg, genesis);

        emit Commit(tokenid, msg.sender, msg.value);
    }

    function commitItem(
        SwapLib.Storage storage s,
        ERC721Lib.Storage storage e,
        // ItemLib.Storage storage i,
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemId,
        uint160 sendingTokenId,
        address payable xnugg
    ) internal {
        require(itemId < 256, 'ML:CI:0');

        require(e.ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        _commitCore(s, sendingTokenId, xnugg, genesis);

        emit CommitItem(sellingTokenId, itemId, sendingTokenId, msg.value);
    }

    function _commitCore(
        SwapLib.Storage storage s,
        uint160 sender,
        address payable xnugg,
        uint256 genesis
    ) internal {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = s.loadStorage(sender);

        console.logBytes32(bytes32(swapData));

        require(msg.value > 0, 'SL:COM:2');

        require(offerData == 0, 'SL:HSO:0');

        require(swapData.isOwner(), 'SL:HSO:1');

        uint256 _epoch = activeEpoch + 1;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(_epoch).account(sender).eth(msg.value);

        require(swapData.eth().mulDiv(100, 10000) < newSwapData.eth(), 'SL:OBP:4');

        s.offers[_epoch][swapData.account()] = swapData;

        s.data = newSwapData;

        xnugg.sendValue(newSwapData.eth() - swapData.eth() + dust);

        // emit Commit(tokenid, sender, newSwapData.eth());
    }

    function offer(
        SwapLib.Storage storage s,
        uint256 tokenid,
        address payable xnugg,
        uint256 genesis
    ) internal {
        _offerCore(s, uint160(msg.sender), xnugg, genesis);

        emit Offer(tokenid, msg.sender, msg.value);
    }

    function offerItem(
        SwapLib.Storage storage s,
        ERC721Lib.Storage storage e,
        // ItemLib.Storage storage i,
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemid,
        uint160 sendingTokenId,
        address payable xnugg
    ) internal {
        require(itemid < 256, 'ML:OI:0');

        require(e.ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');

        _offerCore(s, sendingTokenId, xnugg, genesis);

        emit OfferItem(sellingTokenId, itemid, sendingTokenId, msg.value);
    }

    function _offerCore(
        SwapLib.Storage storage s,
        uint160 sender,
        address payable xnugg,
        uint256 genesis
    ) internal {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = s.loadStorage(sender);

        require(msg.value > 0, 'SL:OBP:2');

        require(swapData != 0, 'NS:0:0');

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!offerData.isOwner(), 'SL:HSO:0');

        // if (swapData.epoch() == 0 && swapData.isOwner()) swapData = swapData.epoch(activeEpoch + 1);

        // make sure swap is still active
        require(activeEpoch <= swapData.epoch(), 'SL:OBP:3');

        // save prev offers data
        if (swapData.account() != sender) s.offers[swapData.epoch()][swapData.account()] = swapData;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(swapData.epoch()).account(sender).eth(
            offerData.eth() + msg.value
        );

        require(swapData.eth().mulDiv(100, 10000) < newSwapData.eth(), 'SL:OBP:4');

        s.data = newSwapData;

        xnugg.sendValue(newSwapData.eth() - swapData.eth() + dust);
    }

    function claim(
        SwapLib.Storage storage s,
        ERC721Lib.Storage storage e,
        uint256 genesis,
        uint256 tokenid,
        uint256 endingEpoch
    ) internal {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = s.loadStorage(msg.sender, endingEpoch);

        delete s.offers[endingEpoch][uint160(msg.sender)];

        if (SwapLib.checkClaimer(uint160(msg.sender), swapData, offerData, activeEpoch)) {
            delete s.data;
            if (endingEpoch == swapData.epoch()) {
                e.checkedMintTo(msg.sender, tokenid);
            } else {
                e.checkedTransferFromSelf(msg.sender, tokenid);
            }
        } else {
            payable(msg.sender).sendValue(offerData.eth());
        }

        emit Claim(tokenid, endingEpoch, msg.sender);
    }

    function claimItem(
        SwapLib.Storage storage s,
        ERC721Lib.Storage storage e,
        ItemLib.Storage storage i,
        uint256 genesis,
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 endingEpoch,
        uint160 sendingTokenId
    ) internal {
        require(e.ownerOf(sendingTokenId) == msg.sender, 'AUC:TT:3');
        require(itemid < 256, 'ML:CI:0');

        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = s.loadStorage(sendingTokenId, endingEpoch);

        delete s.offers[endingEpoch][sendingTokenId];

        if (SwapLib.checkClaimer(sendingTokenId, swapData, offerData, activeEpoch)) {
            delete s.data;

            i.push(sendingTokenId, itemid);
        } else {
            payable(msg.sender).sendValue(offerData.eth());
        }

        emit ClaimItem(sellingTokenId, itemid, endingEpoch, sendingTokenId);
    }

    function swap(
        SwapLib.Storage storage s,
        ERC721Lib.Storage storage e,
        uint256 tokenid,
        uint256 floor
    ) internal {
        (uint256 swapData, ) = s.loadStorage(msg.sender);

        // make sure swap does not exist
        require(swapData == 0, 'NS:SS:0');

        // build starting swap data
        (swapData, ) = swapData.account(uint160(msg.sender)).isOwner(true).eth(floor);

        s.data = swapData;

        e.approvedTransferToSelf(msg.sender, tokenid);

        emit Swap(tokenid, msg.sender, floor);
    }

    function swapItem(
        SwapLib.Storage storage s,
        ERC721Lib.Storage storage e,
        ItemLib.Storage storage i,
        uint256 itemid,
        uint256 floor,
        uint160 sellingTokenId
    ) internal {
        require(e.ownerOf(sellingTokenId) == msg.sender, 'AUC:TT:3');

        require(itemid < 256, 'ML:SI:0');

        (uint256 swapData, ) = s.loadStorage(sellingTokenId);

        // make sure swap does not exist
        require(swapData == 0, 'NS:SS:0');

        // build starting swap data
        (swapData, ) = swapData.account(sellingTokenId).isOwner(true).eth(floor);

        s.data = swapData;

        i.pop(sellingTokenId, itemid);

        emit SwapItem(sellingTokenId, itemid, floor);
    }
}
