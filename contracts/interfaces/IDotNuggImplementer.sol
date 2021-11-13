// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/**
 * @title IDotNuggImplementer
 */
interface IDotNuggImplementer {
    function lockDeployers(address[] calldata deployers) external;

    function delayedDeployment(bytes calldata data) external;
}
