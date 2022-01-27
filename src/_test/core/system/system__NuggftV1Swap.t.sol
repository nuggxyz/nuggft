// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';

contract system__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    address[] tmpUsers;
    uint160[] tmpTokens;
    uint16 sellingItemId;

    function setUp() public {
        reset__system();
        delete tmpUsers;
        delete tmpTokens;
        delete sellingItemId;
    }

    function test__system__frankBidsOnANuggThenClaims() public {
        jump(3000);
        uint96 value = 1 gwei;
        forge.vm.startPrank(users.frank);
        {
            bytes memory odat = startExpectOffer(3000, users.frank, value);
            nuggft.offer{value: value}(3000);
            stopExpectOffer(odat);
            jump(3001);
            bytes memory dat = startExpectClaim(lib.sarr160(3000), lib.sarrAddress(users.frank), users.frank);
            nuggft.claim(lib.sarr160(3000), lib.sarrAddress(users.frank));
            stopExpectClaim(dat);
        }
        forge.vm.stopPrank();
    }

    function test__system__frankSellsANuggThenReclaims() public {
        jump(3000);
        uint96 value = 1 gwei;
        forge.vm.startPrank(users.frank);
        {
            startExpectMint(500, users.frank, value);
            nuggft.mint{value: value}(500);
            endExpectMint();

            nuggft.sell(500, 1 gwei);

            jump(3001);

            bytes memory dat = startExpectClaim(lib.sarr160(500), lib.sarrAddress(users.frank), users.frank);
            nuggft.claim(lib.sarr160(500), lib.sarrAddress(users.frank));
            stopExpectClaim(dat);
        }
        forge.vm.stopPrank();
    }

    function test__system__frankBidsOnAnItemThenClaims() public {
        //dee buys a nugg and sells an item
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

        jump(3000);

        forge.vm.startPrank(users.frank);
        {
            startExpectMint(501, users.frank, nuggft.msp());
            nuggft.mint{value: nuggft.msp()}(501);
            endExpectMint();

            //bytes memory odat = startExpectOffer(3000, users.frank, value);
            nuggft.offer{value: value}(501, 500, sellingItemId);
            // stopExpectOffer(odat);
            jump(3002);
            bytes memory dat = startExpectClaim(lib.sarr160(encItemIdClaim(500, sellingItemId)), lib.sarrAddress(address(501)), users.frank);
            nuggft.claim(lib.sarr160(encItemIdClaim(500, sellingItemId)), lib.sarr160(501));
            stopExpectClaim(dat);
        }
        forge.vm.stopPrank();
    }

    function test__system__nuggFactory() public {
        uint16 nugg__size = 100;
        uint256 user__count = 0;

        nuggft.mint{value: 0.02 ether}(500);

        for (uint16 i = 0; i < nugg__size; i++) {
            tmpTokens.push(3000 + i);
            jump(uint24(tmpTokens[i]));
            for (; user__count < i * 10; user__count++) {
                tmpUsers.push(forge.vm.addr(user__count + 100));
                uint96 money = nuggft.vfo(tmpUsers[user__count], tmpTokens[i]);
                forge.vm.deal(tmpUsers[user__count], money);
                bytes memory odat = startExpectOffer(tmpTokens[i], tmpUsers[user__count], money);
                forge.vm.prank(tmpUsers[user__count]);
                nuggft.offer{value: money}(tmpTokens[i]);
                stopExpectOffer(odat);
            }
        }

        jump(3001 + nugg__size);
        user__count = 0;

        for (uint16 i = 0; i < nugg__size; i++) {
            for (; user__count < i * 10; user__count++) {
                bytes memory dat = startExpectClaim(lib.sarr160(tmpTokens[i]), lib.sarrAddress(tmpUsers[user__count]), tmpUsers[user__count]);
                forge.vm.prank(tmpUsers[user__count]);
                nuggft.claim(lib.sarr160(tmpTokens[i]), lib.sarrAddress(tmpUsers[user__count]));
                stopExpectClaim(dat);
            }
        }
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
                    uint96 money = nuggft.vfo(user__list[j], 3000 + p);
                    forge.vm.deal(user__list[j], money);
                    bytes memory odat = startExpectOffer(3000 + p, user__list[j], money);
                    forge.vm.prank(user__list[j]);
                    nuggft.offer{value: money}(3000 + p);
                    stopExpectOffer(odat);
                }
            }

            jump(3000 + p + 1);
            nuggft.epoch();
        }
        // uint256 i = 1;
        for (uint256 i = 0; i < size; i++) {
            bytes memory dat = startExpectClaim(lib.sarr160(tmpTokens[i]), lib.sarrAddress(tmpUsers[i]), tmpUsers[i]);
            forge.vm.prank(tmpUsers[i]);
            nuggft.claim(lib.sarr160(tmpTokens[i]), lib.sarrAddress(tmpUsers[i]));
            stopExpectClaim(dat);
        }

        // forge.vm.prank(users.dennis);
        // nuggft.claim(tmpTokens, tmpUsers);
        // endExpectClaim();

        // delete tmpTokens;
        // delete tmpUsers;

        stakeHelper();
    }

    function test__system__revert__0x24__offerWarClaimTwice() public {
        test__system__offerWar();
        // bytes memory mem = startExpectClaim(lib.sarr160(tmpTokens[1]), lib.sarrAddress(tmpUsers[1]), tmpUsers[1]);
        forge.vm.expectRevert(hex'24');
        forge.vm.prank(tmpUsers[1]);
        nuggft.claim(lib.sarr160(tmpTokens[1]), lib.sarrAddress(tmpUsers[1]));
        // stopExpectClaim(mem);
    }

    function test__system__revert__0x24__claim__twice__frank() public {
        forge.vm.startPrank(users.frank);
        jump(4000);
        nuggft.offer{value: 0.2 gwei}(4000);
        jump(4001);
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.expectRevert(hex'24');
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    function test__system__revert__0x67__claim__early__frank() public {
        forge.vm.startPrank(users.frank);
        jump(4000);
        nuggft.offer{value: 0.2 gwei}(4000);
        forge.vm.expectRevert(hex'67');
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    // 3165405880233807789653026790548718548040
    // 79228162514264337593543950336

    function test__system__item__sell__frank() public {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 gwei}(500);

        (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

        sellingItemId = ids[1] | (1 << 8);

        // nuggft.floop(500);
        nuggft.sell(500, sellingItemId, 50 gwei);
        // nuggft.sell(500, 90 gwei);
        // nuggft.floop(500);
        // nuggft.rotate(500, 1, 8);
        // nuggft.floop(500);

        // nuggft.proofToDotnuggMetadata(500);

        forge.vm.stopPrank();
    }

    function test__system__revert__0x0F__item__sellThenOffer__frank() public {
        // jump(3000);
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 gwei}(500);

        (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

        sellingItemId = ids[1] | (1 << 8);

        nuggft.sell(500, sellingItemId, 50 gwei);
        forge.vm.expectRevert(hex'0F');
        nuggft.offer{value: 1 gwei}(500, 500, sellingItemId);

        forge.vm.stopPrank();
    }

    function test__system__item__sellWaitThenOffer__frank() public {
        jump(3000);
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 gwei}(500);

        (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

        sellingItemId = ids[1] | (1 << 8);

        // nuggft.floop(500);
        nuggft.sell(500, sellingItemId, 1 gwei);
        // forge.vm.expectRevert(hex'0F');
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dee);
        nuggft.mint{value: nuggft.msp()}(501);
        nuggft.offer{value: 1.1 gwei}(501, 500, sellingItemId);
        forge.vm.stopPrank();

        forge.vm.prank(users.frank);
        nuggft.offer{value: 1.2 gwei}(500, 500, sellingItemId);
        // nuggft.sell(500, 90 gwei);
        // nuggft.floop(500);
        // nuggft.rotate(500, 1, 8);s
        // nuggft.floop(500);

        // nuggft.proofToDotnuggMetadata(500);
    }

    function test__system__item__sellTwo__frank() public {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 gwei}(500);

        (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

        sellingItemId = ids[1] | (1 << 8);

        nuggft.sell(500, sellingItemId, 50 gwei);
        // nuggft.claim(lib.sarr160(encItemIdClaim(500, sellingItemId)), lib.sarr160(500));

        nuggft.floop(500);

        sellingItemId = ids[2] | (2 << 8);

        nuggft.sell(500, sellingItemId, 50 gwei);

        forge.vm.stopPrank();
    }

    function test__system__item__sellTwoClaimBack__frank() public {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 gwei}(500);

        (, uint8[] memory ids, , , , ) = nuggft.proofToDotnuggMetadata(500);

        sellingItemId = ids[1] | (1 << 8);
        nuggft.sell(500, sellingItemId, 50 gwei);
        nuggft.claim(lib.sarr160(encItemIdClaim(500, sellingItemId)), lib.sarr160(500));

        nuggft.floop(500);

        sellingItemId = ids[2] | (2 << 8);
        nuggft.sell(500, sellingItemId, 50 gwei);
        nuggft.claim(lib.sarr160(encItemIdClaim(500, sellingItemId)), lib.sarr160(500));

        forge.vm.stopPrank();
    }

    function test__system__item__offerWar__frankSale() public {
        test__system__item__sell__frank();
        jump(3000);
        uint16 size = 20;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(i + 100));
            tmpTokens.push(uint160(501 + i));
            forge.vm.deal(tmpUsers[i], 100 ether);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: nuggft.msp()}(tmpTokens[i]);
            nuggft.offer{value: nuggft.vfo(tmpTokens[i], 500, sellingItemId)}(tmpTokens[i], 500, sellingItemId);
            forge.vm.stopPrank();
        }
    }

    function test__system__item__everyoneClaimsTheirOwn__offerWar__frankSale() public {
        test__system__item__offerWar__frankSale();

        jump(3002);

        for (uint16 i = 0; i < tmpTokens.length; i++) {
            forge.vm.prank(tmpUsers[i]);
            nuggft.claim(lib.sarr160(encItemIdClaim(500, sellingItemId)), lib.sarr160(tmpTokens[i]));
        }
    }

    function test__system__revert__0x88__item__oneClaimsAll__offerWar__frankSale() public {
        test__system__item__offerWar__frankSale();

        jump(3002);

        forge.vm.expectRevert(hex'88');
        forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
        nuggft.claim(lib.m160(encItemIdClaim(500, sellingItemId), uint16(tmpUsers.length)), tmpTokens);
    }

    function test__system__item__trustlessWinnerClaim__offerWar__frankSale() public {
        test__system__item__offerWar__frankSale();

        jump(3002);

        forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
        nuggft.claim(lib.sarr160(encItemIdClaim(500, sellingItemId)), lib.sarr160(tmpTokens[tmpUsers.length - 1]));
    }

    uint160[] tmpIds;

    function test__system__item__offerWar__ffrankSale__holy__fuck() public {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.sell(500, 90 gwei);
        jump(3000);

        // nuggft.mint{value: 200 gwei}(509);

        uint16 size = 20;
        uint96 money = 1000 gwei;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(100));
            tmpTokens.push(uint160(501 + i));
            tmpIds.push(encItemIdClaim(500, sellingItemId));
            uint256 value = nuggft.msp();
            uint160 tkn = uint160(501 + i);
            money = nuggft.vfo(tkn, 500, sellingItemId);

            forge.vm.deal(tmpUsers[i], 100 ether);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: value}(tkn);
            nuggft.offer{value: money}(tkn, 500, sellingItemId);

            money = nuggft.vfo(forge.vm.addr(100), 500);

            bytes memory odat = startExpectOffer(500, tmpUsers[i], money);
            nuggft.offer{value: money}(500);
            stopExpectOffer(odat);

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
        nuggft.claim(tmpIds, tmpTokens);
    }

    function test__system__item__initSaleThenSellNugg() public {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.sell(500, 90 gwei);
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function test__system__item__initSaleThenLoanNugg() public {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.loan(lib.sarr160(500));
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function test__system__item__initSaleThenBurnNugg() public {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.burn(500);
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function fragment__item__offerWar__ffrankSale__holy__fuck() public {
        jump(3000);

        uint16 size = 20;
        uint256 money = 1000 gwei;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(100));
            tmpTokens.push(uint160(501 + i));
            tmpIds.push(encItemIdClaim(500, sellingItemId));
            uint256 value = nuggft.msp();
            uint160 tkn = uint160(501 + i);
            money = nuggft.vfo(tkn, 500, sellingItemId);

            forge.vm.deal(tmpUsers[i], 100 ether);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: value}(tkn);
            nuggft.offer{value: money}(tkn, 500, sellingItemId);

            forge.vm.stopPrank();
            money += 10 gwei;
        }

        jump(3002);

        forge.vm.prank(tmpUsers[size - 3]);
        nuggft.claim(tmpIds, tmpTokens);
    }
}
