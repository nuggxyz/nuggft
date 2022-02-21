// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

interface INuggftV1Trust {
    event TrustUpdated(address indexed user, bool trust);

    function setIsTrusted(address user, bool trust) external;

    function isTrusted(address user) external view returns (bool);
}
