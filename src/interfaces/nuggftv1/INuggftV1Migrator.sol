// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

// prettier-ignore

interface INuggftV1Migrator {
    event MigrateV1Accepted(address v1, uint160 tokenId, uint256 proof, address owner, uint96 eth);

    function nuggftMigrateFromV1(uint160 tokenId, uint256 proof, address owner) external payable;
}
