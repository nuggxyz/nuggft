// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/EpochMath.sol';

/**
 * @title IEpochable
 * @dev interface for Auctionable.sol
 */

interface IEpochable {
    function genesisBlock() external view returns (uint256 res);

    function interval() external view returns (uint256 res);

    function currentEpochId() external view returns (uint256 res);

    function currentEpoch() external view returns (EpochMath.Epoch memory res);

    function epochFromBlocknum(uint256 blocknum) external view returns (EpochMath.Epoch memory res);
}
