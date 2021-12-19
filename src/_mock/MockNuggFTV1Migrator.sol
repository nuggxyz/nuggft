// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../interfaces/INuggFTV1Migrator.sol';
import '../_test/utils/Print.sol';

contract MockNuggFTV1Migrator is INuggFTV1Migrator {
    function nuggftMigrateFromV1(
        uint160 tokenId,
        uint256 proof,
        address owner
    ) external payable override {
        Print.log(tokenId, 'tokenId', proof, 'proof', uint160(owner), 'owner', msg.value, 'msg.value', uint160(msg.sender), 'msg.sender');
        emit MigrateV1Accepted(msg.sender, tokenId, proof, owner, uint96(msg.value));
    }
}
