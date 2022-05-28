// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

interface INuggftV1Trust {
    event TrustUpdated(address indexed user, bool trust);

    function setIsTrusted(address user, bool trust) external;

    function isTrusted(address user) external view returns (bool);
}
