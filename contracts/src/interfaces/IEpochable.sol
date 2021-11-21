// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/EpochMath.sol';

/**
 * @title IEpochable
 */

interface IEpochable {
    function getSeed(uint256 id) external view returns (bytes32 res);

    function getSeedWithOffset(uint256 id, uint256 offset) external view returns (bytes32 res);

    function seedExists(uint256 id) external view returns (bool res);

    function currentSeed() external view returns (bytes32 res);

    function genesisBlock() external view returns (uint256 res);

    function interval() external view returns (uint256 res);

    function currentEpochId() external view returns (uint48 res);

    function currentTokenId() external view returns (uint256 res);

    function epochFromBlocknum(uint256 blocknum) external view returns (EpochMath.Epoch memory res);
}
