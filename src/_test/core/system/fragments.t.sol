// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';

contract fragments is NuggftV1Test {
    uint16 itemId;

    function userMints(address user, uint24 token) public {
        uint96 value = nuggft.msp();
        if (value < 1 ether) {
            value = 1 ether;
        }

        expect.mint().exec(token, lib.txdata(user, value, ''));
    }

    function deeSellsAnItem() public {
        uint96 value = 1 ether;

        expect.mint().exec(500, lib.txdata(users.dee, 0, ''));

        (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

        itemId = ids[1] | (1 << 8);

        expect.sell().exec(500, itemId, value, lib.txdata(users.dee, 0, ''));
    }
}
