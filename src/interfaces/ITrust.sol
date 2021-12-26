// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface ITrust {
    event TrustUpdated(address indexed user, bool trust);

    function setIsTrusted(address user, bool trust) external;

    function isTrusted(address user) external view returns (bool);
}
