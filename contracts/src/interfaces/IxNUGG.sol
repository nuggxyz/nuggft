// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../erc20/IERC20.sol';

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface IxNUGG is IERC20 {
    event Mint(address account, uint256 shares, uint256 eth);
    event Burn(address account, uint256 shares, uint256 eth);
    event Move(address from, address to, uint256 shares, uint256 eth);
    event Take(address sender, uint256 eth);

    function ownershipOf(address account) external view returns (uint256 res);

    function totalShares() external view returns (uint256 res);

    function sharesOf(address account) external view returns (uint256 res);

    function mint() external payable;

    function genesis() external view returns (uint256 res);

    function burn(uint256 amount) external;

    function epoch() external view returns (uint256 res);

    function totalSupply() external view override(IERC20) returns (uint256 res);

    function balanceOf(address from) external view override(IERC20) returns (uint256 res);
}
