// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../erc20/IERC20.sol';

/**
 * @title IEscrowable
 * @dev interface for Escrow.sol
 */
interface IEscrowable {
    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     */
    function tummy() external returns (address);
}

/**
 * @title IEscrow
 * @dev interface for Escrow.sol
 */
interface IEscrow {
    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     */
    function deposit() external payable;

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     */
    function withdraw() external;

    function rescueERC20(IERC20 token, uint256 amount) external;

    function deposits() external view returns (uint256);
}
