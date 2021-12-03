// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface IxNUGG is IERC20 {
    event Receive(address sender, uint256 eth);

    event Send(address receiver, uint256 eth);

    event Genesis();

    function genesis() external view returns (uint256 res);

    function ownershipOf(address account) external view returns (uint256 res);

    function totalEth() external view returns (uint256 res);

    function ethOf(address account) external view returns (uint256 res);

    function mint() external payable;

    function burn(uint256 amount) external;

    function totalSupply() external view override(IERC20) returns (uint256 res);

    function balanceOf(address from) external view override(IERC20) returns (uint256 res);
}
