// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';
import '@openzeppelin/contracts/utils/Address.sol';

import './interfaces/INuggSwap.sol';
import './interfaces/IxNUGG.sol';

import './libraries/SwapLib.sol';
import './libraries/EpochLib.sol';
import './libraries/ShiftLib.sol';

contract NuggSwap is INuggSwap, ERC721Holder {
    using Address for address payable;
    using EpochLib for uint256;
    using ShiftLib for uint256;
    using QuadMath for uint256;
    using SwapLib for SwapLib.Storage;

    address payable public immutable override xnugg;

    uint256 public immutable override genesis;

    mapping(address => mapping(uint256 => SwapLib.Storage)) internal sl_state;

    constructor(address _xnugg) {
        xnugg = payable(_xnugg);
        genesis = block.number;
    }

    function epoch() public view override returns (uint256 res) {
        return genesis.activeEpoch();
    }

    function getActiveSwap(address token, uint256 tokenid)
        external
        view
        override
        returns (
            address leader,
            uint256 amount,
            uint256 _epoch,
            bool isOwner
        )
    {
        (uint256 swapData, ) = sl_state[token][tokenid].loadStorage(address(0));
        require(swapData != 0, 'NS:GS:0');
        leader = swapData.account();
        amount = swapData.eth();
        _epoch = swapData.epoch();
        isOwner = swapData.isOwner();
    }

    function getOfferByAccount(
        address token,
        uint256 tokenid,
        uint256 index,
        address account
    ) external view override returns (uint256 amount) {
        (, uint256 offerData) = sl_state[token][tokenid].loadStorage(account, index);
        require(offerData != 0, 'NS:GS:0');
        amount = offerData.eth();
    }

    function delegate(address token, uint256 tokenid) external payable override {
        uint256 activeEpoch = genesis.activeEpoch();

        (uint256 swapData, uint256 offerData) = sl_state[token][tokenid].loadStorage(msg.sender);

        if (activeEpoch == tokenid && swapData == 0) mint(token, tokenid);
        else if (offerData == 0 && swapData.isOwner()) commit(token, tokenid);
        else offer(token, tokenid);
    }

    function delegateItem(
        address token,
        uint256 tokenid,
        uint256 itemid,
        uint256 senderTokenId
    ) external payable override {
        require(tokenid != senderTokenId, 'SL:VS:-1');

        uint256 customtokenid = SwapLib.itemTokenId(itemid, tokenid);

        (uint256 swapData, uint256 offerData) = sl_state[token][customtokenid].loadStorage(msg.sender);

        if (offerData == 0 && swapData.isOwner()) commitItem(token, tokenid, itemid, senderTokenId);
        else offerItem(token, tokenid, itemid, senderTokenId);
    }

    function mint(address token, uint256 tokenid) public payable override {
        uint256 activeEpoch = genesis.activeEpoch();

        // we do not need this, could take tokenid out as an argument - but do not want to give users
        // the ability to accidently place an offer for nugg A and end up minting nugg B.
        require(activeEpoch == tokenid, 'NS:M:0');

        (uint256 swapData, ) = sl_state[token][tokenid].loadStorage(msg.sender);

        require(swapData == 0, 'NS:M:D');

        (uint256 newSwapData, ) = uint256(0).epoch(activeEpoch).account(msg.sender).eth(msg.value);

        sl_state[token][tokenid].data = newSwapData;

        if (msg.value > 0) xnugg.sendValue(msg.value);

        SwapLib.moveERC721(token, tokenid, address(0), address(this));

        emit Mint(token, activeEpoch, msg.sender, newSwapData.eth());
    }

    function commit(address token, uint256 tokenid) public payable override {
        _commit(token, tokenid, msg.sender, false);
    }

    function commitItem(
        address token,
        uint256 tokenid,
        uint256 itemid,
        uint256 senderTokenId
    ) public payable override {
        require(tokenid != senderTokenId, 'SL:VS:-1');
        console.logBytes32(bytes32(senderTokenId));
        console.log(IERC721(token).ownerOf(senderTokenId), msg.sender);
        require(IERC721(token).ownerOf(senderTokenId) == msg.sender, 'SL:VS:0');
        _commit(token, SwapLib.itemTokenId(itemid, tokenid), SwapLib.tokenIdToAddress(senderTokenId), true);
    }

    function _commit(
        address token,
        uint256 tokenid,
        address sender,
        bool item
    ) internal {
        require(msg.value > 0, 'SL:COM:2');

        (uint256 swapData, uint256 offerData) = sl_state[token][tokenid].loadStorage(sender);

        require(offerData == 0, 'SL:HSO:0');

        require(swapData.isOwner(), 'SL:HSO:1');

        uint256 _epoch = genesis.activeEpoch() + 1;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(_epoch).account(sender).eth(msg.value);

        require(swapData.eth().mulDiv(100, 10000) < newSwapData.eth(), 'SL:OBP:4');

        sl_state[token][tokenid].offers[_epoch][swapData.account()] = swapData;

        sl_state[token][tokenid].data = newSwapData;

        xnugg.sendValue(newSwapData.eth() - swapData.eth() + dust);

        emit Commit(token, tokenid, _epoch, sender, newSwapData.eth());
    }

    function offer(address token, uint256 tokenid) public payable override {
        _offer(token, tokenid, msg.sender, false);
    }

    function offerItem(
        address token,
        uint256 tokenid,
        uint256 itemid,
        uint256 senderTokenId
    ) public payable override {
        require(tokenid != senderTokenId, 'SL:VS:-1');

        require(IERC721(token).ownerOf(senderTokenId) == msg.sender, 'SL:VS:0');

        _offer(token, SwapLib.itemTokenId(itemid, tokenid), SwapLib.tokenIdToAddress(senderTokenId), true);
    }

    function _offer(
        address token,
        uint256 tokenid,
        address sender,
        bool item
    ) internal {
        require(msg.value > 0, 'SL:OBP:2');

        (uint256 swapData, uint256 offerData) = sl_state[token][tokenid].loadStorage(sender);

        require(swapData != 0, 'NS:0:0');

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!offerData.isOwner(), 'SL:HSO:0');

        // if (swapData.epoch() == 0 && swapData.isOwner()) swapData = swapData.epoch(activeEpoch + 1);
        uint256 activeEpoch = genesis.activeEpoch();

        // make sure swap is still active
        require(activeEpoch <= swapData.epoch(), 'SL:OBP:3');

        // save prev offers data
        if (swapData.account() != sender)
            sl_state[token][tokenid].offers[swapData.epoch()][swapData.account()] = swapData;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(swapData.epoch()).account(sender).eth(
            offerData.eth() + msg.value
        );

        require(swapData.eth().mulDiv(100, 10000) < newSwapData.eth(), 'SL:OBP:4');

        sl_state[token][tokenid].data = newSwapData;

        xnugg.sendValue(newSwapData.eth() - swapData.eth() + dust);

        emit Offer(token, tokenid, swapData.epoch(), sender, newSwapData.eth());
    }

    function claim(
        address token,
        uint256 tokenid,
        uint256 index
    ) public override {
        _claim(token, tokenid, index, msg.sender, false);
    }

    function claimItem(
        address token,
        uint256 tokenid,
        uint256 index,
        uint256 itemid,
        uint256 senderTokenId
    ) public override {
        require(tokenid != senderTokenId, 'SL:VS:-1');

        require(IERC721(token).ownerOf(senderTokenId) == msg.sender, 'SL:VS:0');

        _claim(token, SwapLib.itemTokenId(itemid, tokenid), index, SwapLib.tokenIdToAddress(senderTokenId), true);
    }

    function _claim(
        address token,
        uint256 tokenid,
        uint256 index,
        address sender,
        bool
    ) internal {
        (uint256 swapData, uint256 offerData) = sl_state[token][tokenid].loadStorage(sender, index);

        uint256 activeEpoch = genesis.activeEpoch();

        delete sl_state[token][tokenid].offers[index][sender];

        if (SwapLib.checkClaimer(sender, swapData, offerData, activeEpoch)) {
            delete sl_state[token][tokenid].data;

            SwapLib.moveERC721(token, tokenid, address(this), sender);
        } else {
            payable(sender).sendValue(offerData.eth());
        }

        emit Claim(token, tokenid, index, sender);
    }

    function swap(
        address token,
        uint256 tokenid,
        uint256 floor
    ) external override {
        _swap(token, tokenid, floor, msg.sender, false);
    }

    function swapItem(
        address token,
        uint256 tokenid,
        uint256 floor,
        uint256 itemid
    ) external override {
        // require(tokenid != senderTokenId, 'SL:VS:-1');
        require(IERC721(token).ownerOf(tokenid) == msg.sender, 'SL:VS:0');
        _swap(token, SwapLib.itemTokenId(itemid, tokenid), floor, SwapLib.tokenIdToAddress(tokenid), true);
    }

    function _swap(
        address token,
        uint256 tokenid,
        uint256 floor,
        address sender,
        bool item
    ) internal {
        (uint256 swapData, ) = sl_state[token][tokenid].loadStorage(sender);

        // make sure swap does not exist
        require(swapData == 0, 'NS:SS:0');

        // build starting swap data
        (swapData, ) = swapData.account(sender).isOwner(true).eth(floor);

        sl_state[token][tokenid].data = swapData;

        !item ? SwapLib.moveERC721(token, tokenid, sender, address(this)) : SwapLib.moveERC1155(token, tokenid, false);

        emit Swap(token, tokenid, sender, floor);
    }
}
