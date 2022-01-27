// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';

contract fragments is NuggftV1Test {
    uint16 sellingItemId;

    function userMints(address user, uint24 token) public {
        forge.vm.startPrank(user);
        uint96 value = 1 gwei;//nuggft.msp();
        if (value < 1 gwei) {
            value = 1 gwei;
        }
        startExpectMint(token, users.frank, value);
        nuggft.mint{value: value}(token);
        endExpectMint();
        forge.vm.stopPrank();
    }

    function deeSellsAnItem() public {
        uint96 value = 1 gwei;
        forge.vm.startPrank(users.dee);
        {
            startExpectMint(500, users.frank, value);
            nuggft.mint{value: value}(500);
            endExpectMint();

            (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);
            sellingItemId = ids[1] | (1 << 8);

            nuggft.sell(500, sellingItemId, value);
        }
        forge.vm.stopPrank();
    }
}
