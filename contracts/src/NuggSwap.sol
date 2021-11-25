// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';
import './interfaces/INuggSwap.sol';
import './libraries/EpochLib.sol';

import './libraries/ShiftLib.sol';
import './interfaces/IxNUGG.sol';
import './erc721/IERC721.sol';
import './erc2981/IERC2981.sol';
import './erc721/ERC721Holder.sol';
import './erc1155/ERC1155Holder.sol';

contract NuggSwap is INuggSwap, ERC721Holder, ERC1155Holder {
    using Address for address;
    using EpochLib for uint256;
    using ShiftLib for uint256;
    using SwapLib for uint256;

    IxNUGG public immutable override xnugg;

    uint256 private immutable genesis;

    constructor(address _xnugg) {
        xnugg = IxNUGG(_xnugg);
        genesis = IxNUGG(_xnugg).genesis();
    }

    function getActiveSwap(address token, uint256 tokenid)
        external
        view
        override
        returns (
            address leader,
            uint256 amount,
            uint256 epoch,
            bool isOwner
        )
    {
        (, uint256 swapData, ) = SwapLib.loadStorage(token, tokenid, address(0));
        require(swapData != 0, 'NS:GS:0');
        leader = swapData.account();
        amount = swapData.eth();
        epoch = swapData.epoch();
        isOwner = swapData.isOwner();
    }

    function getOfferLeader(
        address token,
        uint256 tokenid,
        uint256 index
    ) external view override returns (address leader, uint256 amount) {
        (, uint256 swapData, ) = SwapLib.loadStorage(token, tokenid, address(0), index);
        require(swapData != 0, 'NS:GS:0');
        leader = swapData.account();
        amount = swapData.eth();
    }

    function getOfferByAccount(
        address token,
        uint256 tokenid,
        uint256 index,
        address account
    ) external view override returns (uint256 amount) {
        (, , uint256 offerData) = SwapLib.loadStorage(token, tokenid, account, index);
        require(offerData != 0, 'NS:GS:0');
        amount = offerData.eth();
    }

    function delegate(address token, uint256 tokenid) external payable override {
        uint256 activeEpoch = genesis.activeEpoch();

        (, uint256 swapData, uint256 offerData) = SwapLib.loadStorage(token, tokenid, msg.sender);

        if (activeEpoch == tokenid && swapData == 0) mint(token, tokenid);
        else if (offerData == 0 && swapData.isOwner()) commit(token, tokenid);
        else offer(token, tokenid);
    }

    function mint(address token, uint256 tokenid) public payable override {
        uint256 activeEpoch = genesis.activeEpoch();

        // we do not need this, could take tokenid out as an argument - but do not want to give users
        // the ability to accidently place an offer for nugg A and end up minting nugg B.
        require(activeEpoch == tokenid, 'NS:M:0');

        (SwapLib.Storage storage s, uint256 swapData, ) = SwapLib.loadStorage(token, activeEpoch, msg.sender);

        require(swapData == 0, 'NS:M:D');

        (uint256 newSwapData, ) = uint256(0).epoch(activeEpoch).account(msg.sender).eth(msg.value);

        s.data = newSwapData;

        address(xnugg).sendValue(msg.value);

        emit Mint(token, activeEpoch, msg.sender, newSwapData.eth());
    }

    function commit(address token, uint256 tokenid) public payable override {
        (SwapLib.Storage storage s, uint256 swapData, uint256 offerData) = SwapLib.loadStorage(
            token,
            tokenid,
            msg.sender
        );

        require(offerData == 0, 'SL:HSO:0');

        require(swapData.isOwner(), 'SL:HSO:0');

        uint256 epoch = genesis.activeEpoch() + 1;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(epoch).account(msg.sender).eth(msg.value);

        require(swapData.eth().pointsWith(100) < newSwapData.eth(), 'SL:OBP:4');

        s.offers[epoch][swapData.account()] = swapData;

        s.data = newSwapData;

        uint256 increase = newSwapData.eth() - swapData.eth() + dust;

        address(xnugg).sendValue(increase);

        emit Commit(token, tokenid, epoch, msg.sender, newSwapData.eth());
    }

    function offer(address token, uint256 tokenid) public payable override {
        (SwapLib.Storage storage s, uint256 swapData, uint256 offerData) = SwapLib.loadStorage(
            token,
            tokenid,
            msg.sender
        );

        require(swapData != 0, 'NS:0:0');

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise
        require(!offerData.isOwner(), 'SL:HSO:0');

        // if (swapData.epoch() == 0 && swapData.isOwner()) swapData = swapData.epoch(activeEpoch + 1);
        uint256 activeEpoch = genesis.activeEpoch();

        // make sure swap is still active
        require(activeEpoch <= swapData.epoch(), 'SL:OBP:3');

        // save prev offers data
        if (swapData.account() != msg.sender) s.offers[swapData.epoch()][swapData.account()] = swapData;

        // copy relevent items from swapData to newSwapData
        (uint256 newSwapData, uint256 dust) = uint256(0).epoch(swapData.epoch()).account(msg.sender).eth(
            offerData.eth() + msg.value
        );

        require(swapData.eth().pointsWith(100) < newSwapData.eth(), 'SL:OBP:4');

        s.data = newSwapData;

        uint256 increase = newSwapData.eth() - swapData.eth() + dust;

        address(xnugg).sendValue(increase);

        emit Offer(token, tokenid, swapData.epoch(), msg.sender, newSwapData.eth());
    }

    function claim(
        address token,
        uint256 tokenid,
        uint256 index
    ) external override {
        (SwapLib.Storage storage s, uint256 swapData, uint256 offerData) = SwapLib.loadStorage(
            token,
            tokenid,
            msg.sender,
            index
        );

        uint256 activeEpoch = genesis.activeEpoch();

        delete s.offers[index][msg.sender];

        if (SwapLib.checkClaimer(msg.sender, swapData, offerData, activeEpoch)) {
            delete s.data;

            SwapLib.moveERC721(token, tokenid, address(this), msg.sender);
        } else {
            msg.sender.sendValue(offerData.eth());
        }

        emit Claim(token, tokenid, index, msg.sender);
    }

    function swap(
        address token,
        uint256 tokenid,
        uint256 requestedFloor
    ) external override {
        (SwapLib.Storage storage s, uint256 swapData, ) = SwapLib.loadStorage(token, tokenid, msg.sender);

        // make sure swap does not exist
        require(swapData == 0, 'NS:SS:0');

        // build starting swap data
        (swapData, ) = swapData.account(msg.sender).isOwner(true).eth(requestedFloor);

        s.data = swapData;

        SwapLib.moveERC721(token, tokenid, msg.sender, address(this));

        emit Swap(token, tokenid, msg.sender, requestedFloor);
    }
}
