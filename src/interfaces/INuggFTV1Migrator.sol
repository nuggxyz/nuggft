// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface INuggFTV1Migrator {
    event MigrateV1Accepted(address v1, uint160 tokenId, uint256 proof, address owner, uint96 eth);

    function nuggftMigrateFromV1(
        uint160 tokenId,
        uint256 proof,
        address owner
    ) external payable;
}
