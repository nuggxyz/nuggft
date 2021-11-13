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
        bytes memory data
    ) external view returns (string memory image);

}
