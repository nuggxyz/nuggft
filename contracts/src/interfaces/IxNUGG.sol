// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../erc20/IERC20.sol';

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface IxNUGG is IERC20 {
    event ShareAdd(address indexed account, uint256 shares, uint256 value);
    event ShareSub(address indexed account, uint256 shares, uint256 value);
    event ValueAdd(address indexed sender, uint256 value);

    function ownershipOfX128(address account) external view returns (uint256 res);

    function totalShares() external view returns (uint256 res);

    function sharesOf(address account) external view returns (uint256 res);

    function mint() external payable;

    function burn(uint256 amount) external;

    function totalSupply() external view override(IERC20) returns (uint256 res);

    function balanceOf(address from) external view override(IERC20) returns (uint256 res);
}
