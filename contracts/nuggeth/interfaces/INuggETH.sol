// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../../interfaces/IStakeable.sol';
import '../../interfaces/IEscrowable.sol';
import '../../interfaces/IWETH9.sol';
import '../../erc20/IERC20.sol';
import './INuggETHRelay.sol';

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface INuggETH is IERC20, IWETH9, IStakeable, IEscrowable {
    function depositRewards(address sender) external payable override(IStakeable);

    function deposit() external payable override(IWETH9);

    function depositTo(address account) external payable;

    function withdrawFrom(address account, uint256 amount) external;

    function depositWethTo(address account, uint256 amount) external;

    function withdrawWethFrom(address account, uint256 amount) external;

    function withdraw(uint256 amount) external override(IWETH9);

    function depositWeth(uint256 amount) external;

    function withdrawWeth(uint256 amount) external;

    function relay() external view returns (INuggETHRelay res);

    function totalSupply() external view override(IERC20, IStakeable) returns (uint256 res);

    function balanceOf(address from) external view override(IERC20) returns (uint256 res);

    function balanceOfMinted(address from) external view returns (uint256 res);

    function totalSupplyMinted() external view returns (uint256 res);
}
