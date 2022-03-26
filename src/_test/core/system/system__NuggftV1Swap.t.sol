// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";
import {NuggftV1Proof} from "../../../core/NuggftV1Proof.sol";
import {fragments} from "./fragments.t.sol";

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
        jump(OFFSET);

        expect.mint().from(users.frank).value(1 ether).exec(TRUSTED_MINT_TOKENS);
        // if nothing else is in the pool then value goes to 0 and tests fail
        expect.mint().from(users.frank).value(nuggft.msp()).exec(TRUSTED_MINT_TOKENS + 1);

        expect.burn().from(users.frank).exec(TRUSTED_MINT_TOKENS);
    }

    function test__system__frankBidsOnANuggThenClaims() public {
        jump(OFFSET);

        uint96 value = 1 ether;
        {
            expect.offer().from(users.frank).exec{value: value}(OFFSET);

            jump(OFFSET + 1);

            expect.claim().from(users.frank).exec(lib.sarr160(OFFSET), lib.sarrAddress(users.frank));
        }
    }

    function test__system__frankSellsANuggThenReclaims() public {
        jump(OFFSET);
        uint96 value = 1 ether;
        forge.vm.startPrank(users.frank);
        {
            expect.mint().start(TRUSTED_MINT_TOKENS, users.frank, value);
            nuggft.mint{value: value}(TRUSTED_MINT_TOKENS);
            expect.mint().stop();

            nuggft.sell(TRUSTED_MINT_TOKENS, 1 ether);

            jump(OFFSET + 1);

            expect.claim().start(lib.sarr160(TRUSTED_MINT_TOKENS), lib.sarrAddress(users.frank), users.frank);
            nuggft.claim(lib.sarr160(TRUSTED_MINT_TOKENS), lib.sarrAddress(users.frank));
            expect.claim().stop();
        }
        forge.vm.stopPrank();
    }

    function test__system__frankBidsOnAnItemThenClaims() public {
        deeSellsAnItem();

        uint96 value = 1.1 ether;

        jump(OFFSET);

        expect.mint().from(users.frank).value(1 ether).exec(TRUSTED_MINT_TOKENS + 1);

        forge.vm.startPrank(users.frank);
        {
            //bytes memory odat = startExpectOffer(OFFSET, users.frank, value);
            nuggft.offer{value: value}(TRUSTED_MINT_TOKENS + 1, TRUSTED_MINT_TOKENS, itemId);
            // expect.offer().stop();
            jump(OFFSET + 2);
            expect.claim().start(
                lib.sarr160(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId)),
                lib.sarrAddress(address(uint160(TRUSTED_MINT_TOKENS + 1))),
                users.frank
            );
            nuggft.claim(lib.sarr160(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId)), lib.sarr160(TRUSTED_MINT_TOKENS + 1));
            expect.claim().stop();
        }
        forge.vm.stopPrank();
    }

    function test__system__frankMulticlaimWinningItemAndNuggs() public {
        deeSellsAnItem();
        userMints(users.frank, TRUSTED_MINT_TOKENS + 1);

        // forge.vm.startPrank(users.frank);
        {
            for (uint16 i = 0; i < 100; i++) {
                jump(OFFSET + i);
                tmpTokens.push(OFFSET + i);
                uint96 value = nuggft.msp();

                expect.offer().exec(tmpTokens[i], lib.txdata(users.frank, value, ""));
            }

            expect.offer().exec(
                TRUSTED_MINT_TOKENS + 1,
                TRUSTED_MINT_TOKENS,
                itemId,
                lib.txdata(users.frank, nuggft.vfo(TRUSTED_MINT_TOKENS + 1, TRUSTED_MINT_TOKENS, itemId), "")
            );

            tmpTokens.push(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId));

            jump(uint24(OFFSET + 50 + tmpTokens.length));

            tmpUsers = lib.mAddress(users.frank, uint16(tmpTokens.length - 1));
            tmpUsers.push(address(uint160(TRUSTED_MINT_TOKENS + 1)));

            expect.claim().exec(tmpTokens, tmpUsers, lib.txdata(users.frank, 0, ""));
        }
        // forge.vm.stopPrank();
    }

    event log_array(uint160[] tmp);

    function test__system__frankMulticlaimLosingItemAndNuggs() public clean {
        deeSellsAnItem();
        userMints(users.frank, TRUSTED_MINT_TOKENS + 1);
        userMints(users.dennis, TRUSTED_MINT_TOKENS + 2);

        // forge.vm.startPrank(users.frank);
        {
            for (uint16 i = 0; i < 100; i++) {
                jump(OFFSET + i);
                tmpTokens.push(OFFSET + i);
                uint96 value = nuggft.msp();
                expect.offer().exec(tmpTokens[i], lib.txdata(users.frank, value, ""));

                uint96 dennisIsABastardMan = nuggft.vfo(users.dennis, tmpTokens[i]);

                expect.offer().exec(tmpTokens[i], lib.txdata(users.dennis, dennisIsABastardMan, ""));
            }

            expect.offer().exec(
                TRUSTED_MINT_TOKENS + 1,
                TRUSTED_MINT_TOKENS,
                itemId,
                lib.txdata(users.frank, nuggft.vfo(TRUSTED_MINT_TOKENS + 1, TRUSTED_MINT_TOKENS, itemId), "")
            );

            expect.offer().exec(
                TRUSTED_MINT_TOKENS + 2,
                TRUSTED_MINT_TOKENS,
                itemId,
                lib.txdata(users.dennis, nuggft.vfo(TRUSTED_MINT_TOKENS + 2, TRUSTED_MINT_TOKENS, itemId), "")
            );

            tmpTokens.push(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId));

            jump(uint24(OFFSET + 50 + tmpTokens.length));

            tmpUsers = lib.mAddress(users.frank, uint16(tmpTokens.length - 1));
            tmpUsers.push(address(uint160(TRUSTED_MINT_TOKENS + 1)));

            expect.claim().exec(tmpTokens, tmpUsers, lib.txdata(users.frank, 0, ""));
        }
        // forge.vm.stopPrank();
    }

    function test__system__nuggFactory() public clean {
        uint16 nugg__size = 100;
        uint256 user__count = 0;

        nuggft.mint{value: 0.02 ether}(TRUSTED_MINT_TOKENS);

        for (uint16 i = 0; i < nugg__size; i++) {
            tmpTokens.push(OFFSET + i);
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

        jump(OFFSET + 1 + nugg__size);
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
        jump(OFFSET);

        nuggft.mint{value: 0.02 ether}(TRUSTED_MINT_TOKENS);

        uint16 size = 2;

        address[] memory user__list = new address[](size);

        for (uint256 i = 0; i < size; i++) {
            user__list[i] = forge.vm.addr(i + 6);
        }
        for (uint24 p = 0; p < size; p++) {
            for (uint256 i = 0; i < size; i++) {
                tmpUsers.push(user__list[i]);
                tmpTokens.push(OFFSET + p);
                for (uint256 j = 0; j < size; j++) {
                    uint96 money = nuggft.vfo(user__list[j], OFFSET + p);
                    forge.vm.deal(user__list[j], money);
                    expect.offer().start(OFFSET + p, user__list[j], money);
                    forge.vm.prank(user__list[j]);
                    nuggft.offer{value: money}(OFFSET + p);
                    expect.offer().stop();
                }
            }

            jump(OFFSET + p + 1);
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
        forge.vm.expectRevert(hex"7e863b48_A0");
        forge.vm.prank(tmpUsers[1]);
        nuggft.claim(lib.sarr160(tmpTokens[1]), lib.sarrAddress(tmpUsers[1]));
        // expect.claim().stop();
    }

    function test__system__revert__0xA0__claim__twice__frank() public clean {
        forge.vm.startPrank(users.frank);
        jump(OFFSET + 1000);
        nuggft.offer{value: 0.2 ether}(OFFSET + 1000);
        jump(OFFSET + 1001);
        nuggft.claim(lib.sarr160(OFFSET + 1000), lib.sarrAddress(users.frank));
        forge.vm.expectRevert(hex"7e863b48_A0");
        nuggft.claim(lib.sarr160(OFFSET + 1000), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    function test__system__revert__0x67__claim__early__frank() public clean {
        forge.vm.startPrank(users.frank);
        jump(OFFSET + 1000);
        nuggft.offer{value: 0.2 ether}(OFFSET + 1000);
        forge.vm.expectRevert(hex"7e863b48_67");
        nuggft.claim(lib.sarr160(OFFSET + 1000), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    // 3165405740233807789653026790548718548040
    // 79228162514264337593543950336

    function test__system__item__sell__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(TRUSTED_MINT_TOKENS);

        bytes2[] memory f = nuggft.floop(TRUSTED_MINT_TOKENS);

        itemId = uint16(f[1]);

        // nuggft.floop(TRUSTED_MINT_TOKENS);
        nuggft.sell(TRUSTED_MINT_TOKENS, itemId, 50 ether);
        // nuggft.sell(TRUSTED_MINT_TOKENS, 90 ether);
        // nuggft.floop(TRUSTED_MINT_TOKENS);
        // nuggft.rotate(TRUSTED_MINT_TOKENS, 1, 8);
        // nuggft.floop(TRUSTED_MINT_TOKENS);

        // nuggft.proofToDotnuggMetadata(TRUSTED_MINT_TOKENS);

        forge.vm.stopPrank();
    }

    function test__system__revert__0x99__item__sellThenOffer__frank() public clean {
        // jump(OFFSET);
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(TRUSTED_MINT_TOKENS);

        bytes2[] memory f = nuggft.floop(TRUSTED_MINT_TOKENS);

        itemId = uint16(f[1]);

        nuggft.sell(TRUSTED_MINT_TOKENS, itemId, 50 ether);
        forge.vm.expectRevert(hex"7e863b48_99");
        nuggft.offer{value: 1 ether}(TRUSTED_MINT_TOKENS, TRUSTED_MINT_TOKENS, itemId);

        forge.vm.stopPrank();
    }

    function test__system__item__sellWaitThenOffer__frank() public clean {
        jump(OFFSET);
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(TRUSTED_MINT_TOKENS);

        bytes2[] memory f = nuggft.floop(TRUSTED_MINT_TOKENS);

        itemId = uint16(f[1]);

        // nuggft.floop(TRUSTED_MINT_TOKENS);
        nuggft.sell(TRUSTED_MINT_TOKENS, itemId, 1 ether);
        // forge.vm.expectRevert(hex'7e863b48_99');
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dee);
        nuggft.mint{value: nuggft.msp()}(TRUSTED_MINT_TOKENS + 1);
        nuggft.offer{value: 1.1 ether}(TRUSTED_MINT_TOKENS + 1, TRUSTED_MINT_TOKENS, itemId);
        forge.vm.stopPrank();

        forge.vm.prank(users.frank);
        nuggft.offer{value: 1.2 ether}(TRUSTED_MINT_TOKENS, TRUSTED_MINT_TOKENS, itemId);
        // nuggft.sell(TRUSTED_MINT_TOKENS, 90 ether);
        // nuggft.floop(TRUSTED_MINT_TOKENS);
        // nuggft.rotate(TRUSTED_MINT_TOKENS, 1, 8);s
        // nuggft.floop(TRUSTED_MINT_TOKENS);

        // nuggft.proofToDotnuggMetadata(TRUSTED_MINT_TOKENS);
    }

    function test__system__item__sellTwo__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(TRUSTED_MINT_TOKENS);

        bytes2[] memory f = nuggft.floop(TRUSTED_MINT_TOKENS);

        itemId = uint16(f[1]);

        nuggft.sell(TRUSTED_MINT_TOKENS, itemId, 50 ether);
        // nuggft.claim(lib.sarr160(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId)), lib.sarr160(TRUSTED_MINT_TOKENS));

        nuggft.floop(TRUSTED_MINT_TOKENS);

        itemId = uint16(f[2]);

        nuggft.sell(TRUSTED_MINT_TOKENS, itemId, 50 ether);

        forge.vm.stopPrank();
    }

    function test__system__item__sellTwoClaimBack__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(TRUSTED_MINT_TOKENS);

        bytes2[] memory f = nuggft.floop(TRUSTED_MINT_TOKENS);

        itemId = uint16(f[1]);
        nuggft.sell(TRUSTED_MINT_TOKENS, itemId, 50 ether);
        nuggft.claim(lib.sarr160(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId)), lib.sarr160(TRUSTED_MINT_TOKENS));

        nuggft.floop(TRUSTED_MINT_TOKENS);

        itemId = uint16(f[2]);
        nuggft.sell(TRUSTED_MINT_TOKENS, itemId, 50 ether);
        nuggft.claim(lib.sarr160(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId)), lib.sarr160(TRUSTED_MINT_TOKENS));

        forge.vm.stopPrank();
    }

    function test__system__item__offerWar__frankSale() public clean {
        test__system__item__sell__frank();
        jump(OFFSET);
        uint16 size = 20;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(i + 100));
            tmpTokens.push(uint160(TRUSTED_MINT_TOKENS + 1 + i));
            uint96 msp = nuggft.msp();
            uint96 vfo = nuggft.vfo(tmpTokens[i], TRUSTED_MINT_TOKENS, itemId);
            forge.vm.deal(tmpUsers[i], vfo + msp);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: msp}(tmpTokens[i]);
            nuggft.offer{value: vfo}(tmpTokens[i], TRUSTED_MINT_TOKENS, itemId);
            forge.vm.stopPrank();
        }
    }

    function test__system__item__everyoneClaimsTheirOwn__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jump(OFFSET + 2);

        for (uint16 i = 0; i < tmpTokens.length; i++) {
            forge.vm.prank(tmpUsers[i]);
            nuggft.claim(lib.sarr160(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId)), lib.sarr160(tmpTokens[i]));
        }
    }

    function test__system__revert__0x74__item__oneClaimsAll__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jump(OFFSET + 2);

        forge.vm.expectRevert(hex"7e863b48_74");
        forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
        nuggft.claim(lib.m160(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId), uint16(tmpUsers.length)), tmpTokens);
    }

    function test__system__item__trustlessWinnerClaim__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jump(OFFSET + 2);

        forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
        nuggft.claim(lib.sarr160(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId)), lib.sarr160(tmpTokens[tmpUsers.length - 1]));
    }

    uint160[] tmpIds;

    // function test__system__item__offerWar__ffrankSale__holy__fuck() clean public {
    //     test__system__item__sell__frank();
    //     forge.vm.prank(users.frank);
    //     nuggft.sell(TRUSTED_MINT_TOKENS, .9 ether);
    //     jump(OFFSET);

    //     // nuggft.mint{value: 200 ether}(509);

    //     uint16 size = 20;
    //     uint96 money = .69696969 ether;

    //     for (uint256 i = 0; i < size; i++) {
    //         tmpUsers.push(forge.vm.addr(100));
    //         tmpTokens.push(uint160(TRUSTED_MINT_TOKENS + 1 + i));
    //         tmpIds.push(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId));
    //         uint256 value = nuggft.msp();
    //         uint160 tkn = uint160(TRUSTED_MINT_TOKENS + 1 + i);
    //         money = nuggft.vfo(tkn, TRUSTED_MINT_TOKENS, itemId);

    //         forge.vm.startPrank(tmpUsers[i]);
    //         {
    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + value);

    //             nuggft.mint{value: value}(tkn);

    //             money = nuggft.vfo(forge.vm.addr(100), TRUSTED_MINT_TOKENS);

    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + money);

    //             expect.offer().start(TRUSTED_MINT_TOKENS, tmpUsers[i], money);
    //             nuggft.offer{value: money}(tkn, TRUSTED_MINT_TOKENS, itemId);
    //             expect.offer().stop();

    //             money = nuggft.vfo(forge.vm.addr(100), TRUSTED_MINT_TOKENS);

    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + money);

    //             expect.offer().start(TRUSTED_MINT_TOKENS, tmpUsers[i], money);
    //             nuggft.offer{value: money}(TRUSTED_MINT_TOKENS);
    //             expect.offer().stop();
    //         }
    //         forge.vm.stopPrank();
    //         money += .42069696969 ether;
    //     }

    //     tmpUsers.push(forge.vm.addr(100));
    //     tmpIds.push(TRUSTED_MINT_TOKENS);

    //     tmpTokens.push(uint160(forge.vm.addr(100)));

    //     jump(OFFSET + 2);

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
        nuggft.sell(TRUSTED_MINT_TOKENS, 90 ether);
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function test__system__item__initSaleThenLoanNugg() public clean {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.loan(lib.sarr160(TRUSTED_MINT_TOKENS));
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function test__system__item__initSaleThenBurnNugg() public clean {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.burn(TRUSTED_MINT_TOKENS);
        fragment__item__offerWar__ffrankSale__holy__fuck();
    }

    function fragment__item__offerWar__ffrankSale__holy__fuck() public {
        jump(OFFSET);

        uint16 size = 20;
        uint256 money = 1000 ether;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(100));
            tmpTokens.push(uint160(TRUSTED_MINT_TOKENS + 1 + i));
            tmpIds.push(encItemIdClaim(TRUSTED_MINT_TOKENS, itemId));
            uint256 value = nuggft.msp();
            uint160 tkn = uint160(TRUSTED_MINT_TOKENS + 1 + i);

            forge.vm.deal(tmpUsers[i], value + money);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: value}(tkn);
            money = nuggft.vfo(tkn, TRUSTED_MINT_TOKENS, itemId);
            nuggft.offer{value: money}(tkn, TRUSTED_MINT_TOKENS, itemId);

            forge.vm.stopPrank();
            money += 10 ether;
        }

        jump(OFFSET + 2);

        forge.vm.prank(tmpUsers[size - 3]);
        nuggft.claim(tmpIds, tmpTokens);
    }

    function test__system__hotproof__pass() public {
        logHotproof();

        jump(OFFSET);

        uint24 tokenId = nuggft.epoch();

        uint256 proofBeforeOffer = nuggft.proofOf(tokenId);

        expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, tokenId)}(tokenId);

        uint256 proofAfterOffer = nuggft.proofOf(tokenId);
        logHotproof();

        jump(tokenId + 1);

        uint24 tokenId2 = nuggft.epoch();
        nuggft.check(users.frank, tokenId2);

        expect.offer().from(users.dee).exec{value: nuggft.vfo(users.dee, tokenId2)}(tokenId2);
        logHotproof();

        jump(tokenId2 + 1);

        uint256 proofBeforeClaim = nuggft.proofOf(tokenId);

        expect.claim().from(users.frank).exec(array.b160(tokenId), array.bAddress(users.frank));

        uint256 proofAfterClaim = nuggft.proofOf(tokenId);

        logHotproof();

        ds.emit_log_named_bytes32("proofBeforeOffer", bytes32(proofBeforeOffer));
        ds.emit_log_named_bytes32("proofAfterOffer", bytes32(proofAfterOffer));
        ds.emit_log_named_bytes32("proofBeforeClaim", bytes32(proofBeforeClaim));
        ds.emit_log_named_bytes32("proofAfterClaim", bytes32(proofAfterClaim));

        ds.assertNotEq(proofBeforeOffer, 0, "proofBeforeOffer should not be 0");
        ds.assertEq(proofAfterOffer, proofBeforeOffer, "proofAfterOffer should be proofBeforeOffer");
        ds.assertEq(proofBeforeClaim, proofBeforeOffer, "proofBeforeClaim should be proofBeforeOffer");
        ds.assertEq(proofAfterClaim, proofBeforeOffer, "proofAfterClaim should be proofBeforeOffer");
    }

    function logHotproof() public {
        for (uint256 i = 0; i < HOT_PROOF_AMOUNT; i++) {
            ds.emit_log_named_bytes32(strings.toAsciiString(i), bytes32(nuggft.hotproof(i)));
        }
    }
}
