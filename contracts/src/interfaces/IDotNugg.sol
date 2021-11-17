// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/**
 * @title IDotNugg
 * @dev interface for Launchable.sol
 */
interface IDotNugg {
    function nuggify(
        bytes memory _collection,
        bytes[] memory _items,
        address _resolver,
        string memory name,
        string memory description,
        uint256 tokenId,
        bytes32 seed,
        bytes memory data
    ) external view returns (string memory image);

    struct Matrix {
        uint8 width;
        uint8 height;
        Pixel[][] data;
        uint8 currentUnsetX;
        uint8 currentUnsetY;
        bool init;
        uint8 startX;
    }

    struct Rgba {
        uint8 r;
        uint8 g;
        uint8 b;
        uint8 a;
    }
    struct Pixel {
        int8 zindex;
        Rgba rgba;
        bool exists;
    }
}
