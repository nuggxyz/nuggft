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

    function test__system__nuggFactory() public {
        uint16 nugg__size = 100;
        uint256 user__count = 0;

        for (uint16 i = 0; i < nugg__size; i++) {
            tmpTokens.push(3000 + i);
            jump(uint24(tmpTokens[i]));
            for (; user__count < i * 10; user__count++) {
                tmpUsers.push(forge.vm.addr(user__count + 100));
                (, uint96 next, uint96 userCurrentOffer) = nuggft.check(tmpUsers[user__count], tmpTokens[i]);
                forge.vm.deal(tmpUsers[user__count], next - userCurrentOffer);
                startExpectOffer(tmpTokens[i], tmpUsers[user__count], next - userCurrentOffer);
                forge.vm.prank(tmpUsers[user__count]);
                nuggft.offer{value: next - userCurrentOffer}(tmpTokens[i]);
                endExpectOffer();
            }
        }

        //TODO DANNY check claims
    }

    function test__system__offerWar() public {
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

    function test__revert__0x2E__system__offerWarClaimTwice() public {
        test__system__offerWar();
        forge.vm.expectRevert(hex'2E');
        forge.vm.prank(tmpUsers[1]);
        nuggft.claim(tmpTokens, tmpUsers);
    }

    function test__revert__0x24__system__claim__twice__frank() public {
        forge.vm.startPrank(users.frank);
        jump(4000);
        nuggft.offer{value: 0.2 gwei}(4000);
        jump(4001);
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.expectRevert(hex'24');
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    function test__revert__0x67__system__claim__early__frank() public {
        forge.vm.startPrank(users.frank);
        jump(4000);
        nuggft.offer{value: 0.2 gwei}(4000);
        forge.vm.expectRevert(hex'67');
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    // 3165405880233807789653026790548718548040
    // 79228162514264337593543950336

    function test__system__item__sell__frank() public returns (uint16) {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 gwei}(500);

        (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

        uint16 itemId = ids[1] | (1 << 8);

        // nuggft.floop(500);
        nuggft.sell(500, itemId, 50 gwei);
        nuggft.sell(500, 90 gwei);
        // nuggft.floop(500);
        // nuggft.rotate(500, 1, 8);
        // nuggft.floop(500);

        // nuggft.proofToDotnuggMetadata(500);

        forge.vm.stopPrank();
        return itemId;
    }

    function test__system__item__offerWar__frankSale() public {
        uint16 itemId = test__system__item__sell__frank();
        jump(3000);
        uint16 size = 20;
        uint256 money = 0.01 gwei;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(i + 100));
            tmpTokens.push(uint160(501 + i));
            uint256 value = nuggft.msp();
            forge.vm.deal(tmpUsers[i], 100 ether);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: value}(tmpTokens[i]);
            uint160 arguments = encItemId(tmpTokens[i], 500, itemId);
            nuggft.offer{value: money}(arguments);
            forge.vm.stopPrank();
            money += 0.0001 gwei;
        }
        jump(3002);

        // uint160[] memory tkn = uint160[](size);

        // for (uint16 i = 0; i<size; i++) {

        // }

        forge.vm.prank(tmpUsers[size - 2]);
        nuggft.claim(lib.m160(encItemIdClaim(500, itemId), size), abi.decode(abi.encode(tmpTokens), (address[])));
    }

    uint160[] tmpIds;

    function test__system__item__offerWar__frankSale__holy__fuck() public {
        uint16 itemId = test__system__item__sell__frank();
        jump(3000);

        // nuggft.mint{value: 200 gwei}(509);

        uint16 size = 20;
        uint256 money = 1000 gwei;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(100));
            tmpTokens.push(uint160(501 + i));
            tmpIds.push(encItemIdClaim(500, itemId));
            uint256 value = nuggft.msp();
            uint160 tkn = uint160(501 + i);
            money = nuggft.vfo(tkn, 500, itemId);

            forge.vm.deal(tmpUsers[i], 100 ether);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: value}(tkn);
            // uint160 arguments = encItemId(tkn, 500, itemId);
            nuggft.offer{value: money}(tkn, 500, itemId);

            money = nuggft.vfo(forge.vm.addr(100), 500);

            nuggft.offer{value: money}(500);

            forge.vm.stopPrank();
            money += 10 gwei;
        }

        tmpUsers.push(forge.vm.addr(100));
        tmpIds.push(500);

        tmpTokens.push(uint160(forge.vm.addr(100)));

        jump(3002);

        // uint160[] memory tkn = uint160[](size);

        // for (uint16 i = 0; i<size; i++) {

        // }

        forge.vm.prank(tmpUsers[size - 3]);
        nuggft.claim(tmpIds, abi.decode(abi.encode(tmpTokens), (address[])));
    }
}
// 198018000000000000
// 200000000000000000
