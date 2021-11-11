// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/**
 * @title ILaunchable
 * @dev interface for Launchable.sol
 */
interface ILaunchable {
    function deployer() external returns (address);

    function launched() external returns (bool);
}
