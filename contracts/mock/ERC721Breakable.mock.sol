// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './ERC1155Breakable.mock.sol';

import './erc721/ERC721Enumerable.sol';
import '../src/interfaces/INuggSwap.sol';
import '../src/libraries/EpochLib.sol';
import '../src/libraries/ItemLib.sol';

// import '../src/interfaces/IERC721Nuggable.sol';

contract MockERC721Breakable is MockERC1155Breakable, ERC721Enumerable {
    address public immutable nuggswap;

    address public immutable xnugg;

    // MockERC1155Breakable public immutable

    uint256 private immutable genesis;

    event PreMint(uint256 tokenId, uint256 satchel);

    using EpochLib for uint256;
    using ItemLib for uint256;

    // mapping(uint256 => uint256) public satchels;

    constructor(address _xnugg, address _nuggswap)
        ERC721('Mock ERC721 Breakable', 'MockERC721Breakable')
        MockERC1155Breakable(_nuggswap)
    {
        nuggswap = _nuggswap;
        genesis = INuggSwap(_nuggswap).genesis();
        xnugg = _xnugg;
        // = new MockERC1155Breakable(_nuggswap);
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId) && _preminted(tokenId)) return nuggswap;
        return super.ownerOf(tokenId);
    }

    function tokenIdArray(uint256 tokenId, uint256 length) internal pure returns (uint256[] memory res) {
        res = new uint256[](length);
        for (uint256 i = 0; i < length; i++) res[i] = tokenId;
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
        // uint256[] memory empty;
        _safeMint(tokenId);

        super._beforeTokenTransfer(from, to, tokenId);
    }

    // function updateSachel(uint256 tokenId, uint256 to) public {
    //     require(msg.sender == address();
    //     satchels[tokenId] = to;
    // }

    function _preminted(uint256 tokenId) internal view returns (bool) {
        return get(tokenId) != 0;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal override {
        require(to != address(0), 'ERC721: mint to the zero address');
        require(!_exists(tokenId), 'ERC721: token already minted');

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _premint(uint256 tokenId) internal {
        (uint256 satchel, uint256 epoch) = EpochLib.calculateSeed(genesis);
        require(satchel != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        satchel = satchel.body(satchel.body() % 20).size(0x4);

        set(tokenId, satchel);

        emit PreMint(tokenId, satchel);
    }

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory res) {}
}
