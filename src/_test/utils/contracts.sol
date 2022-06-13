// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;

contract NoFallback {}

contract HasFallback {
    receive() external payable {}

    fallback() external {}
}
