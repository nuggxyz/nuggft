// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IStakeable.sol';
import '../interfaces/IEscrowable.sol';
import '../erc20/IERC20.sol';
import '../erc2981/IERC2981Receiver.sol';

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface INuggETH is IERC20, IStakeable, IEscrowable, IERC2981Receiver {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function totalSupply() external view override(IERC20, IStakeable) returns (uint256 res);

    function balanceOf(address from) external view override(IERC20) returns (uint256 res);

    function balanceOfMinted(address from) external view returns (uint256 res);

    function totalSupplyMinted() external view returns (uint256 res);
}
