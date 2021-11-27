// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './ERC1155Breakable.mock.sol';

import './erc721/ERC721.sol';
import '../src/interfaces/INuggSwap.sol';
import '../src/libraries/EpochLib.sol';
import '../src/libraries/ItemLib.sol';

// import '../src/interfaces/IERC721Nuggable.sol';

contract MockERC721Breakable is ERC721 {
    using EpochLib for uint256;
    using ItemLib for ItemLib.Storage;

    address public immutable nuggswap;

    address public immutable xnugg;

    uint256 private immutable genesis;

    ItemLib.Storage private il_state;

    event PreMint(uint256 tokenId, uint256[] items);
    event PopItem(uint256 tokenId, uint256 itemId);
    event PushItem(uint256 tokenId, uint256 itemId);

    constructor(address _xnugg, address _nuggswap) ERC721('Mock ERC721 Breakable', 'MockERC721Breakable') {
        nuggswap = _nuggswap;
        genesis = INuggSwap(_nuggswap).genesis();
        xnugg = _xnugg;
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId) && _preminted(tokenId)) return nuggswap;
        return super.ownerOf(tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(msg.sender == nuggswap, 'NFT:STF:0');
        if (!_preminted(tokenId) && tokenId == EpochLib.activeEpoch(genesis)) _premint(tokenId);
        else if (!_exists(tokenId) && _preminted(tokenId)) _safeMint(to, tokenId);
        else if (to == nuggswap) super.transferFrom(from, to, tokenId);
        else super.safeTransferFrom(from, to, tokenId, _data);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(msg.sender == nuggswap, 'NFT:BTT:0');

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _preminted(uint256 tokenId) internal view returns (bool) {
        return il_state.tokenData[tokenId] != 0;
    }

    // /**
    //  * @dev Mints `tokenId` and transfers it to `to`.
    //  *
    //  * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
    //  *
    //  * Requirements:
    //  *
    //  * - `tokenId` must not exist.
    //  * - `to` cannot be the zero address.
    //  *
    //  * Emits a {Transfer} event.
    //  */
    // function _mint(address to, uint256 tokenId) internal override {
    //     require(to != address(0), 'ERC721: mint to the zero address');
    //     require(!_exists(tokenId), 'ERC721: token already minted');

    //     _beforeTokenTransfer(address(0), to, tokenId);

    //     _balances[to] += 1;
    //     _owners[tokenId] = to;

    //     emit Transfer(address(0), to, tokenId);
    // }

    function _premint(uint256 tokenId) internal {
        (uint256 itemData, uint256 epoch) = EpochLib.calculateSeed(genesis);
        require(itemData != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        itemData = itemData;

        uint256[] memory items = il_state.mint(tokenId, itemData);

        emit PreMint(tokenId, items);
    }

    function popItem(uint256 tokenId, uint256 itemId) public {
        require(msg.sender == nuggswap, '1155:SBTF:0');

        il_state.pop(tokenId, itemId);

        emit PopItem(tokenId, itemId);
    }

    function pushItem(uint256 tokenId, uint256 itemId) public {
        require(msg.sender == nuggswap, '1155:SBTF:0');

        il_state.push(tokenId, itemId);

        emit PushItem(tokenId, itemId);
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

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory res) {}
}
