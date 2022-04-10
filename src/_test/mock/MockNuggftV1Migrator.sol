// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {INuggftV1Migrator} from "../../interfaces/nuggftv1/INuggftV1Migrator.sol";

contract MockNuggftV1Migrator is INuggftV1Migrator {
    function nuggftMigrateFromV1(
        uint160 tokenId,
        uint256 proof,
        address owner
    ) external payable override {
        emit MigrateV1Accepted(msg.sender, tokenId, proof, owner, uint96(msg.value));
    }
}
