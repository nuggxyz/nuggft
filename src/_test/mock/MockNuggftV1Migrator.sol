// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;

import {INuggftV1Migrator} from "../../interfaces/nuggftv1/INuggftV1Migrator.sol";

contract MockNuggftV1Migrator is INuggftV1Migrator {
    function nuggftMigrateFromV1(
        uint24 tokenId,
        uint256 proof,
        address owner
    ) external payable override {
        emit MigrateV1Accepted(msg.sender, tokenId, bytes32(proof), owner, uint96(msg.value));
    }
}
