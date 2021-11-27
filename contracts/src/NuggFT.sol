// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './interfaces/INuggSwap.sol';

import './libraries/EpochLib.sol';
import './libraries/ItemLib.sol';
import './libraries/SwapLib.sol';
import './libraries/ERC721Lib.sol';
import './libraries/ItemLib.sol';
import './libraries/MoveLib.sol';
import './base/NuggERC721.sol';

contract NuggFT is NuggERC721 {
    using EpochLib for uint256;
    using ItemLib for ItemLib.Storage;

    // address public immutable nuggswap;

    address payable public immutable xnugg;

    uint256 private immutable genesis;

    event PreMint(uint256 tokenId, uint256[] items);
    event PopItem(uint256 tokenId, uint256 itemId);
    event PushItem(uint256 tokenId, uint256 itemId);

    ItemLib.Storage private il_state;

    mapping(uint256 => SwapLib.Storage) internal sl_state;
    mapping(uint256 => mapping(uint256 => SwapLib.Storage)) internal sl_state_items;

    constructor(address _xnugg) NuggERC721('NUGGFT', 'Nugg Fungible Token') {
        xnugg = payable(_xnugg);
        genesis = block.number;
    }

    function delegate(uint256 tokenid) external payable {
        MoveLib.delegate(sl_state[tokenid], il_state, genesis, tokenid, xnugg);
    }

    function mint(uint256 tokenid) external payable {
        MoveLib.mint(sl_state[tokenid], il_state, genesis, tokenid, xnugg);
    }

    function delegateItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 asToken
    ) external payable {
        MoveLib.delegateItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            genesis,
            sellingTokenId,
            itemid,
            uint160(asToken),
            xnugg
        );
    }

    function commit(uint256 tokenid) external payable {
        MoveLib.commit(sl_state[tokenid], tokenid, xnugg, genesis);
    }

    function commitItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 asToken
    ) external payable {
        MoveLib.commitItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            genesis,
            sellingTokenId,
            itemid,
            uint160(asToken),
            xnugg
        );
    }

    function offer(uint256 tokenid) external payable {
        MoveLib.offer(sl_state[tokenid], tokenid, xnugg, genesis);
    }

    function offerItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 asToken
    ) external payable {
        MoveLib.offerItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            sellingTokenId,
            genesis,
            itemid,
            uint160(asToken),
            xnugg
        );
    }

    function claim(uint256 tokenid, uint256 endingEpoch) external payable {
        MoveLib.claim(sl_state[tokenid], el_state, genesis, tokenid, endingEpoch);
    }

    function claimItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 asToken,
        uint256 endingEpoch
    ) external payable {
        MoveLib.claimItem(
            sl_state_items[sellingTokenId][itemid],
            el_state,
            il_state,
            sellingTokenId,
            genesis,
            itemid,
            endingEpoch,
            uint160(asToken)
        );
    }

    function swap(uint256 tokenid, uint256 floor) external payable {
        MoveLib.swap(sl_state[tokenid], el_state, tokenid, floor);
    }

    function swapItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 floor
    ) external payable {
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
