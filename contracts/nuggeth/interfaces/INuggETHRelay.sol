// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../../erc20/IERC20.sol';

interface INuggETHRelay {
    function depositETH() external payable;

    function rescueETH() external;

    function depositWETH(uint256 amount) external;

    function rescueWETH() external;

    function rescueERC20(IERC20 token, uint256 amount) external;
}
