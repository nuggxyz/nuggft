// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';
import {fragments} from './fragments.t.sol';

abstract contract system__NuggftV1Swap is NuggftV1Test, fragments {
    using SafeCast for uint96;

    address[] tmpUsers;
    uint160[] tmpTokens;

    modifier clean() {
        delete tmpUsers;
        delete tmpTokens;
        delete itemId;
        _;
    }

    function test__system__frankMintsThenBurns() public {
        jump(3000);

        expect.mint().from(users.frank).value(1 ether).exec(500);
        // if nothing else is in the pool then value goes to 0 and tests fail
        expect.mint().from(users.frank).value(1 ether).exec(501);

        expect.burn().from(users.frank).exec(500);
    }

    function test__system__frankBidsOnANuggThenClaims() public {
        jump(3000);
        uint96 value = 1 ether;
        forge.vm.startPrank(users.frank);
        {
            expect.offer().start(3000, users.frank, value);
            nuggft.offer{value: value}(3000);
            expect.offer().stop();

            jump(3001);

            expect.claim2().exec(lib.sarr160(3000));
        }
        forge.vm.stopPrank();
    }

    function test__system__frankSellsANuggThenReclaims() public {
        jump(3000);
        uint96 value = 1 ether;
        forge.vm.startPrank(users.frank);
        {
            expect.mint().start(500, users.frank, value);
            nuggft.mint{value: value}(500);
            expect.mint().stop();

            nuggft.sell(500, 1 ether);

            jump(3001);

            expect.claim().start(lib.sarr160(500), lib.sarrAddress(users.frank), users.frank);
            nuggft.claim(lib.sarr160(500), lib.sarrAddress(users.frank));
            expect.claim().stop();
        }
        forge.vm.stopPrank();
    }

    function test__system__frankBidsOnAnItemThenClaims() public {
        deeSellsAnItem();

        uint96 value = 1.1 ether;

        jump(3000);

        expect.mint().from(users.frank).value(1 ether).exec(501);

        forge.vm.startPrank(users.frank);
        {
            //bytes memory odat = startExpectOffer(3000, users.frank, value);
            nuggft.offer{value: value}(501, 500, itemId);
            // expect.offer().stop();
            jump(3002);
            expect.claim().start(lib.sarr160(encItemIdClaim(500, itemId)), lib.sarrAddress(address(501)), users.frank);
            nuggft.claim(lib.sarr160(encItemIdClaim(500, itemId)), lib.sarr160(501));
            expect.claim().stop();
        }
        forge.vm.stopPrank();
    }

    function test__system__frankMulticlaimWinningItemAndNuggs() public {
        deeSellsAnItem();
        userMints(users.frank, 501);

        forge.vm.startPrank(users.frank);
        {
            for (uint16 i = 0; i < 100; i++) {
                jump(3000 + i);
                tmpTokens.push(3000 + i);
                uint96 value = nuggft.msp();

                expect.offer().exec(tmpTokens[i], lib.txdata(users.frank, value, ''));
            }

            expect.offer().exec(501, 500, itemId, lib.txdata(users.frank, nuggft.vfo(501, 500, itemId), ''));

            tmpTokens.push(encItemIdClaim(500, itemId));

            jump(uint24(3050 + tmpTokens.length));

            tmpUsers = lib.mAddress(users.frank, uint16(tmpTokens.length - 1));
            tmpUsers.push(address(501));

            expect.claim().exec(tmpTokens, tmpUsers, lib.txdata(users.frank, 0, ''));
        }
        forge.vm.stopPrank();
    }

    event log_array(uint160[] tmp);

    function test__system__frankMulticlaimLosingItemAndNuggs() public clean {
        deeSellsAnItem();
        userMints(users.frank, 501);
        userMints(users.dennis, 502);

        forge.vm.startPrank(users.frank);
        {
            for (uint16 i = 0; i < 100; i++) {
                jump(3000 + i);
                tmpTokens.push(3000 + i);
                uint96 value = nuggft.msp();
                expect.offer().exec(tmpTokens[i], lib.txdata(users.frank, value, ''));

                uint96 dennisIsABastardMan = nuggft.vfo(users.dennis, tmpTokens[i]);

                expect.offer().exec(tmpTokens[i], lib.txdata(users.dennis, dennisIsABastardMan, ''));
            }

            expect.offer().exec(501, 500, itemId, lib.txdata(users.frank, nuggft.vfo(501, 500, itemId), ''));

            expect.offer().exec(502, 500, itemId, lib.txdata(users.dennis, nuggft.vfo(502, 500, itemId), ''));

            tmpTokens.push(encItemIdClaim(500, itemId));

            jump(uint24(3050 + tmpTokens.length));

            tmpUsers = lib.mAddress(users.frank, uint16(tmpTokens.length - 1));
            tmpUsers.push(address(501));

            expect.claim().exec(tmpTokens, tmpUsers, lib.txdata(users.frank, 0, ''));
        }
        forge.vm.stopPrank();
    }

    function test__system__nuggFactory() public clean {
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
                expect.offer().start(tmpTokens[i], tmpUsers[user__count], money);
                forge.vm.prank(tmpUsers[user__count]);
                nuggft.offer{value: money}(tmpTokens[i]);
                expect.offer().stop();
            }
        }

        jump(3001 + nugg__size);
        user__count = 0;

        for (uint16 i = 0; i < nugg__size; i++) {
            for (; user__count < i * 10; user__count++) {
                expect.claim().start(lib.sarr160(tmpTokens[i]), lib.sarrAddress(tmpUsers[user__count]), tmpUsers[user__count]);
                forge.vm.prank(tmpUsers[user__count]);
                nuggft.claim(lib.sarr160(tmpTokens[i]), lib.sarrAddress(tmpUsers[user__count]));
                expect.claim().stop();
            }
        }
    }

    function test__system__offerWar() public clean {
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
                    expect.offer().start(3000 + p, user__list[j], money);
                    forge.vm.prank(user__list[j]);
                    nuggft.offer{value: money}(3000 + p);
                    expect.offer().stop();
                }
            }

            jump(3000 + p + 1);
            nuggft.epoch();
        }
        // uint256 i = 1;
        for (uint256 i = 0; i < size; i++) {
            expect.claim().start(lib.sarr160(tmpTokens[i]), lib.sarrAddress(tmpUsers[i]), tmpUsers[i]);
            forge.vm.prank(tmpUsers[i]);
            nuggft.claim(lib.sarr160(tmpTokens[i]), lib.sarrAddress(tmpUsers[i]));
            expect.claim().stop();
        }

        // forge.vm.prank(users.dennis);
        // nuggft.claim(tmpTokens, tmpUsers);
        // endExpectClaim();

        // delete tmpTokens;
        // delete tmpUsers;

        // stakeHelper();
    }

    function test__system__revert__0xA0__offerWarClaimTwice() public clean {
        test__system__offerWar();
        // bytes memory mem = expect.startExpectClaim(lib.sarr160(tmpTokens[1]), lib.sarrAddress(tmpUsers[1]), tmpUsers[1]);
        forge.vm.expectRevert(hex'7e863b48_A0');
        forge.vm.prank(tmpUsers[1]);
        nuggft.claim(lib.sarr160(tmpTokens[1]), lib.sarrAddress(tmpUsers[1]));
        // expect.claim().stop();
    }

    function test__system__revert__0xA0__claim__twice__frank() public clean {
        forge.vm.startPrank(users.frank);
        jump(4000);
        nuggft.offer{value: 0.2 ether}(4000);
        jump(4001);
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.expectRevert(hex'7e863b48_A0');
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    function test__system__revert__0x67__claim__early__frank() public clean {
        forge.vm.startPrank(users.frank);
        jump(4000);
        nuggft.offer{value: 0.2 ether}(4000);
        forge.vm.expectRevert(hex'7e863b48_67');
        nuggft.claim(lib.sarr160(4000), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    // 3165405740233807789653026790548718548040
    // 79228162514264337593543950336

    function test__system__item__sell__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(500);

        bytes2[] memory f = nuggft.floop(500);

        itemId = uint16(f[1]);

        // nuggft.floop(500);
        nuggft.sell(500, itemId, 50 ether);
        // nuggft.sell(500, 90 ether);
        // nuggft.floop(500);
        // nuggft.rotate(500, 1, 8);
        // nuggft.floop(500);

        // nuggft.proofToDotnuggMetadata(500);

        forge.vm.stopPrank();
    }

    function test__system__revert__0x99__item__sellThenOffer__frank() public clean {
        // jump(3000);
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(500);

        bytes2[] memory f = nuggft.floop(500);

        itemId = uint16(f[1]);

        nuggft.sell(500, itemId, 50 ether);
        forge.vm.expectRevert(hex'7e863b48_99');
        nuggft.offer{value: 1 ether}(500, 500, itemId);

        forge.vm.stopPrank();
    }

    function test__system__item__sellWaitThenOffer__frank() public clean {
        jump(3000);
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(500);

        bytes2[] memory f = nuggft.floop(500);

        itemId = uint16(f[1]);

        // nuggft.floop(500);
        nuggft.sell(500, itemId, 1 ether);
        // forge.vm.expectRevert(hex'7e863b48_99');
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dee);
        nuggft.mint{value: nuggft.msp()}(501);
        nuggft.offer{value: 1.1 ether}(501, 500, itemId);
        forge.vm.stopPrank();

        forge.vm.prank(users.frank);
        nuggft.offer{value: 1.2 ether}(500, 500, itemId);
        // nuggft.sell(500, 90 ether);
        // nuggft.floop(500);
        // nuggft.rotate(500, 1, 8);s
        // nuggft.floop(500);

        // nuggft.proofToDotnuggMetadata(500);
    }

    function test__system__item__sellTwo__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(500);

        bytes2[] memory f = nuggft.floop(500);

        itemId = uint16(f[1]);

        nuggft.sell(500, itemId, 50 ether);
        // nuggft.claim(lib.sarr160(encItemIdClaim(500, itemId)), lib.sarr160(500));

        nuggft.floop(500);

        itemId = uint16(f[2]);

        nuggft.sell(500, itemId, 50 ether);

        forge.vm.stopPrank();
    }

    function test__system__item__sellTwoClaimBack__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(500);

        bytes2[] memory f = nuggft.floop(500);

        itemId = uint16(f[1]);
        nuggft.sell(500, itemId, 50 ether);
        nuggft.claim(lib.sarr160(encItemIdClaim(500, itemId)), lib.sarr160(500));

        nuggft.floop(500);

        itemId = uint16(f[2]);
        nuggft.sell(500, itemId, 50 ether);
        nuggft.claim(lib.sarr160(encItemIdClaim(500, itemId)), lib.sarr160(500));

        forge.vm.stopPrank();
    }

    function test__system__item__offerWar__frankSale() public clean {
        test__system__item__sell__frank();
        jump(3000);
        uint16 size = 20;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(i + 100));
            tmpTokens.push(uint160(501 + i));
            forge.vm.deal(tmpUsers[i], 100 ether);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: nuggft.msp()}(tmpTokens[i]);
            nuggft.offer{value: nuggft.vfo(tmpTokens[i], 500, itemId)}(tmpTokens[i], 500, itemId);
            forge.vm.stopPrank();
        }
    }

    function test__system__item__everyoneClaimsTheirOwn__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jump(3002);

        for (uint16 i = 0; i < tmpTokens.length; i++) {
            forge.vm.prank(tmpUsers[i]);
            nuggft.claim(lib.sarr160(encItemIdClaim(500, itemId)), lib.sarr160(tmpTokens[i]));
        }
    }

    function test__system__revert__0x74__item__oneClaimsAll__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jump(3002);

        forge.vm.expectRevert(hex'7e863b48_74');
        forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
        nuggft.claim(lib.m160(encItemIdClaim(500, itemId), uint16(tmpUsers.length)), tmpTokens);
    }

    function test__system__item__trustlessWinnerClaim__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jump(3002);

        forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
        nuggft.claim(lib.sarr160(encItemIdClaim(500, itemId)), lib.sarr160(tmpTokens[tmpUsers.length - 1]));
    }

    uint160[] tmpIds;

    // function test__system__item__offerWar__ffrankSale__holy__fuck() clean public {
    //     test__system__item__sell__frank();
    //     forge.vm.prank(users.frank);
    //     nuggft.sell(500, .9 ether);
    //     jump(3000);

    //     // nuggft.mint{value: 200 ether}(509);

    //     uint16 size = 20;
    //     uint96 money = .69696969 ether;

    //     for (uint256 i = 0; i < size; i++) {
    //         tmpUsers.push(forge.vm.addr(100));
    //         tmpTokens.push(uint160(501 + i));
    //         tmpIds.push(encItemIdClaim(500, itemId));
    //         uint256 value = nuggft.msp();
    //         uint160 tkn = uint160(501 + i);
    //         money = nuggft.vfo(tkn, 500, itemId);

    //         forge.vm.startPrank(tmpUsers[i]);
    //         {
    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + value);

    //             nuggft.mint{value: value}(tkn);

    //             money = nuggft.vfo(forge.vm.addr(100), 500);

    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + money);

    //             expect.offer().start(500, tmpUsers[i], money);
    //             nuggft.offer{value: money}(tkn, 500, itemId);
    //             expect.offer().stop();

    //             money = nuggft.vfo(forge.vm.addr(100), 500);

    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + money);

    //             expect.offer().start(500, tmpUsers[i], money);
    //             nuggft.offer{value: money}(500);
    //             expect.offer().stop();
    //         }
    //         forge.vm.stopPrank();
    //         money += .42069696969 ether;
    //     }

    //     tmpUsers.push(forge.vm.addr(100));
    //     tmpIds.push(500);

    //     tmpTokens.push(uint160(forge.vm.addr(100)));

    //     jump(3002);

    //     // uint160[] memory tkn = uint160[](size);

    //     // for (uint16 i = 0; i<size; i++) {

    //     // }

    //     forge.vm.prank(tmpUsers[size - 3]);
    //     expect.claim().start(tmpIds, tmpTokens, tmpUsers[size - 3]);
    //     nuggft.claim(tmpIds, tmpTokens);
    // }

    function test__system__item__initSaleThenSellNugg() public clean {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.sell(500, 90 ether);
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function test__system__item__initSaleThenLoanNugg() public clean {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.loan(lib.sarr160(500));
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function test__system__item__initSaleThenBurnNugg() public clean {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.burn(500);
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function fragment__item__offerWar__ffrankSale__holy__fuck() public {
        jump(3000);

        uint16 size = 20;
        uint256 money = 1000 ether;

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
            nuggft.offer{value: money}(tkn, 500, itemId);

            forge.vm.stopPrank();
            money += 10 ether;
        }

        jump(3002);

        forge.vm.prank(tmpUsers[size - 3]);
        nuggft.claim(tmpIds, tmpTokens);
    }
}
