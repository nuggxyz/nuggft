// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

contract NoFallback {}

contract HasFallback {
    receive() external payable {}

    fallback() external {}
}
