// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

contract NoFallback {}

contract HasFallback {
    receive() external payable {}

    fallback() external {}
}
