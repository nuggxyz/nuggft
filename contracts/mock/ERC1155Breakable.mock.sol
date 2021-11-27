// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

// import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

import '../src/interfaces/INuggSwap.sol';
// import './ERC721Breakable.mock.sol';
import '../src/libraries/ItemLib.sol';

// import '../src/interfaces/IERC1155Nuggable.sol';

abstract contract MockERC1155Breakable {
    // using ItemLib for uint256;
    // address private immutable nuggswap;
    // mapping(uint256 => ItemLib.Storage) private sl_state;
    // mapping(uint256 => uint256) private nuggswap_storage;
    // constructor(address _nuggswap) {
    //     nuggswap = _nuggswap;
    // }
    // function set(uint256 tokenId, uint256 data) internal {
    //     require(sl_state[tokenId].data == 0, '1155:SET:0');
    //     sl_state[tokenId].data = data;
    // }
    // function itemsOf(uint256 tokenId)
    //     public
    //     view
    //     returns (
    //         uint256[] memory items,
    //         uint256 size,
    //         uint256 base
    //     )
    // {
    //     uint256 data = sl_state[tokenId].data;
    //     require(data != 0, '1155:IO:0');
    //     items = data.items();
    //     size = data.size();
    //     base = data.base();
    // }
    // function get(uint256 tokenId) internal view returns (uint256 data) {
    //     data = sl_state[tokenId].data;
    // }
    // event ReceiveItems(uint256 tokenId, uint256[] ids);
    // event SwapItems(uint256 tokenId, uint256[] ids);
    // function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
    //     uint256[] memory array = new uint256[](1);
    //     array[0] = element;
    //     return array;
    // }
}
