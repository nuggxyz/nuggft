// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IStakeable.sol';
import '../interfaces/IEscrowable.sol';
import '../erc20/IERC20.sol';

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface INuggETH is IERC20, IStakeable, IEscrowable {
    function depositRewards(address sender) external payable override(IStakeable);

    function deposit() external payable;

    function totalSupply() external view override(IERC20, IStakeable) returns (uint256 res);

    function balanceOf(address from) external view override(IERC20) returns (uint256 res);

    function balanceOfMinted(address from) external view returns (uint256 res);

    function totalSupplyMinted() external view returns (uint256 res);
}
