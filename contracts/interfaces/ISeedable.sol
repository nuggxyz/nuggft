// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface ISeedable {
    function getSeed(uint256 id) external view returns (bytes32 res);

    function seedExists(uint256 id) external view returns (bool res);

    function calculateCurrentSeed() external view returns (bytes32 res);
}
