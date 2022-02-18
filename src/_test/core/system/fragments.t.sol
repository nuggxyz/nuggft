// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

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

        bytes2[] memory f = nuggft.floop(500);

        itemId = uint16(f[1]);

        expect.sell().exec(500, itemId, value, lib.txdata(users.dee, 0, ''));
    }
}
