// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './interfaces/INuggFT.sol';

import './libraries/EpochLib.sol';
import './libraries/ItemLib.sol';
import './libraries/SwapLib.sol';
import './libraries/ERC721Lib.sol';
import './libraries/ItemLib.sol';
import './libraries/MoveLib.sol';
import './base/NuggERC721.sol';

contract NuggFT is NuggERC721, INuggFT {
    using EpochLib for uint256;
    using ItemLib for ItemLib.Storage;
    using SwapLib for SwapLib.Storage;
    using ShiftLib for uint256;

    address payable public immutable override xnugg;

    uint256 public immutable override genesis;

    ItemLib.Storage private il_state;

    mapping(uint256 => SwapLib.Storage) internal sl_state;
    mapping(uint256 => mapping(uint256 => SwapLib.Storage)) internal sl_state_items;

    constructor(address _xnugg) NuggERC721('NUGGFT', 'Nugg Fungible Token') {
        xnugg = payable(_xnugg);
        genesis = block.number;

        emit Genesis();
    }

    function getActiveSwap(uint256 tokenid)
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
        (uint256 swapData, ) = sl_state[tokenid].loadStorage(address(0));
        require(swapData != 0, 'NS:GS:0');
        leader = address(swapData.account());
        amount = swapData.eth();
        _epoch = swapData.epoch();
        isOwner = swapData.isOwner();
    }

    function getOfferByAccount(
        uint256 tokenid,
        uint256 index,
        address account
    ) external view override returns (uint256 amount) {
        (, uint256 offerData) = sl_state[tokenid].loadStorage(account, index);
        require(offerData != 0, 'NS:GS:0');
        amount = offerData.eth();
    }

    function epoch() external view override returns (uint256 res) {
        res = genesis.activeEpoch();
    }

    function delegate(uint256 tokenid) external payable override {
        MoveLib.delegate(sl_state[tokenid], il_state, genesis, tokenid, xnugg);
    }

    function mint(uint256 tokenid) external payable override {
        MoveLib.mint(sl_state[tokenid], il_state, genesis, tokenid, xnugg);
    }

    function delegateItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external payable override {
        MoveLib.delegateItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            genesis,
            sellingTokenId,
            itemid,
            uint160(buyingTokenId),
            xnugg
        );
    }

    function commit(uint256 tokenid) external payable override {
        MoveLib.commit(sl_state[tokenid], tokenid, xnugg, genesis);
    }

    function commitItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external payable override {
        MoveLib.commitItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            genesis,
            sellingTokenId,
            itemid,
            uint160(buyingTokenId),
            xnugg
        );
    }

    function offer(uint256 tokenid) external payable override {
        MoveLib.offer(sl_state[tokenid], tokenid, xnugg, genesis);
    }

    function offerItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external payable override {
        MoveLib.offerItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            sellingTokenId,
            genesis,
            itemid,
            uint160(buyingTokenId),
            xnugg
        );
    }

    function claim(uint256 tokenid, uint256 endingEpoch) external override {
        MoveLib.claim(sl_state[tokenid], el_state, genesis, tokenid, endingEpoch);
    }

    function claimItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId,
        uint256 endingEpoch
    ) external override {
        MoveLib.claimItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            il_state,
            sellingTokenId,
            genesis,
            itemid,
            endingEpoch,
            uint160(buyingTokenId)
        );
    }

    function swap(uint256 tokenid, uint256 floor) external override {
        MoveLib.swap(sl_state[tokenid], el_state, tokenid, floor);
    }

    function swapItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 floor
    ) external override {
        MoveLib.swapItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            il_state,
            itemid,
            floor,
            uint160(sellingTokenId)
        );
    }

    function infoOf(uint256 tokenId)
        public
        view
        returns (
            uint256 base,
            uint256 size,
            uint256[] memory items
        )
    {
        return il_state.infoOf(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory res) {}
}