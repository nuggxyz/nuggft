// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";
import {NuggftV1Proof} from "../../../core/NuggftV1Proof.sol";

abstract contract fragments is NuggftV1Test {
    uint16 itemId;

    function userMints(address user, uint24 token) public {
        uint96 value = nuggft.msp();
        if (value < 1 ether) {
            value = 1 ether;
        }

        expect.mint().exec(token, lib.txdata(user, value, ""));
    }

    function deeSellsAnItem() public {
        uint24 TOKEN1 = mintable(0);

        uint96 value = 1 ether;

        expect.mint().exec(TOKEN1, lib.txdata(users.dee, 0, ""));

        uint16[] memory f = nuggft.floop(TOKEN1);

        itemId = uint16(f[1]);

        expect.sell().exec(TOKEN1, itemId, value, lib.txdata(users.dee, 0, ""));
    }
}
