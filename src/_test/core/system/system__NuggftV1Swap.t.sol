// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';

contract system__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    address[] tmpUsers;
    uint160[] tmpTokens;

    function setUp() public {
        reset__system();
        delete tmpUsers;
        delete tmpTokens;
    }

    function test__system__frankBidsOnATokenThenClaims() public {
        jump(3000);
        uint96 value = 1 gwei;
        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value}(3000);
            jump(3001);
            nuggft.claim(lib.sarr160(3000), lib.sarrAddress(users.frank));
        }
        forge.vm.stopPrank();
    }

    function test__system__zero__offerWar() public {
        jump(3000);

        uint16 size = 2;

        address[] memory user__list = new address[](size);

        for (uint256 i = 0; i < size; i++) {
            user__list[i] = forge.vm.addr(i + 6);
        }

        for (uint256 i = 0; i < size; i++) {
            for (uint256 j = 0; j < size; j++) {
                uint96 amount = nuggft.msp();
                startExpectOffer(3000, user__list[j], amount);
                forge.vm.prank(user__list[j]);
                nuggft.offer{value: amount}(3000);
                endExpectOffer();
            }
        }

        jump(3001);
        nuggft.epoch();

        for (uint256 i = 0; i < size; i++) {
            startExpectClaim(lib.sarr160(3000), lib.sarrAddress(user__list[i]), users.dennis);
            forge.vm.prank(users.dennis);
            nuggft.claim(lib.sarr160(3000), lib.sarrAddress(user__list[i]));
            endExpectClaim();
        }
    }

    function test__system__value__offerWar() public {
        jump(3000);

        nuggft.mint{value: 0.02 ether}(500);

        uint16 size = 2;

        address[] memory user__list = new address[](size);

        for (uint256 i = 0; i < size; i++) {
            user__list[i] = forge.vm.addr(i + 6);
        }
        for (uint24 p = 0; p < size; p++) {
            for (uint256 i = 0; i < size; i++) {
                tmpUsers.push(user__list[i]);
                tmpTokens.push(3000 + p);
                for (uint256 j = 0; j < size; j++) {
                    (, uint96 next, uint96 userCurrentOffer) = nuggft.check(user__list[j], 3000 + p);
                    forge.vm.deal(user__list[j], next - userCurrentOffer);
                    startExpectOffer(3000 + p, user__list[j], next - userCurrentOffer);
                    forge.vm.prank(user__list[j]);
                    nuggft.offer{value: next - userCurrentOffer}(3000 + p);
                    endExpectOffer();
                }
            }

            jump(3000 + p + 1);
            nuggft.epoch();

            // for (uint256 i = 0; i < size; i++) {
            //     startExpectClaim(3000 + p, user__list[i]);
            //     endExpectClaim();
            // }
        }

        startExpectClaim(tmpTokens, tmpUsers, users.dennis);
        forge.vm.prank(users.dennis);
        nuggft.claim(tmpTokens, tmpUsers);
        endExpectClaim();

        // delete tmpTokens;
        // delete tmpUsers;

        stakeHelper();
    }

    // 3165405880233807789653026790548718548040
    // 79228162514264337593543950336

    function test__system__item__sell__frank() public {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(500);

        (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

        uint16 itemId = ids[1] | (1 << 8);

        nuggft.floop(500);
        nuggft.sellItem(500, itemId, 0.1 ether);
        nuggft.floop(500);
        nuggft.rotate(500, 1, 8);
        nuggft.floop(500);

        nuggft.proofToDotnuggMetadata(500);

        forge.vm.stopPrank();
    }

    // function test__system__item__sell__frank() public {
    //     forge.vm.startPrank(users.frank);
    //     nuggft.mint{value: 0.2 ether}(500);

    //     (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

    //     uint16 itemId = ids[1] | (1 << 8);

    //     nuggft.sellItem(500, itemId, 0.1 ether);

    //     forge.vm.stopPrank();
    // }
}
