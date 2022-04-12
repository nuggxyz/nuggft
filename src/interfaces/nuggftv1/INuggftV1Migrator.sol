// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

// prettier-ignore

interface INuggftV1Migrator {
    event MigrateV1Accepted(address v1, uint24 tokenId, bytes32 proof, address owner, uint96 eth);

    function nuggftMigrateFromV1(uint24 tokenId, uint256 proof, address owner) external payable;
}
