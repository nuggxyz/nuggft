// SPDX-License-Identifier: BUSL-1.1

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

    uint160 private token1 = mintable(0);
    uint160 private token2 = mintable(99);
    uint160 private token3 = mintable(48);

    function test__system__frankMintsThenBurns() public {
        jumpStart();

        expect.mint().from(users.frank).value(1 ether).exec(token1);
        // if nothing else is in the pool then value goes to 0 and tests fail
        expect.mint().from(users.frank).value(nuggft.msp()).exec(token2);

        expect.burn().from(users.frank).exec(token1);
    }

    function test__system__frankBidsOnANuggThenClaims() public {
        jumpStart();

        uint160 token = nuggft.epoch();

        uint96 value = 1 ether;
        {
            expect.offer().from(users.frank).exec{value: value}(token);

            jumpSwap();

            expect.claim().from(users.frank).exec(lib.sarr160(token), lib.sarrAddress(users.frank));
        }
    }

    function test__system__frankSellsANuggThenReclaims() public {
        jumpStart();
        uint96 value = 1 ether;
        forge.vm.startPrank(users.frank);
        {
            expect.mint().start(token1, users.frank, value);
            nuggft.mint{value: value}(token1);
            expect.mint().stop();

            nuggft.sell(token1, 1 ether);

            jumpSwap();

            expect.claim().start(lib.sarr160(token1), lib.sarrAddress(users.frank), users.frank);
            nuggft.claim(lib.sarr160(token1), lib.sarrAddress(users.frank));
            expect.claim().stop();
        }
        forge.vm.stopPrank();
    }

    function test__system__frankBidsOnAnItemThenClaims() public {
        deeSellsAnItem();

        uint96 value = 1.1 ether;

        jumpStart();

        expect.mint().from(users.frank).value(1 ether).exec(token2);

        expect.offer().from(users.frank).exec{value: value}(token2, token1, itemId);

        jumpSwap();

        expect.claim().from(users.frank).exec(array.b160(encItemIdClaim(token1, itemId)), array.b160(token2));
    }

    function test__system__frankMulticlaimWinningItemAndNuggs() public {
        deeSellsAnItem();
        userMints(users.frank, token2);

        // forge.vm.startPrank(users.frank);
        {
            for (uint16 i = 0; i < 100; i++) {
                jumpUp(1);
                tmpTokens.push(nuggft.epoch());
                uint96 value = nuggft.msp();

                expect.offer().exec(tmpTokens[i], lib.txdata(users.frank, value, ""));
            }

            expect.offer().exec(token2, token1, itemId, lib.txdata(users.frank, nuggft.vfo(token2, token1, itemId), ""));

            tmpTokens.push(encItemIdClaim(token1, itemId));

            jumpSwap();

            tmpUsers = lib.mAddress(users.frank, uint16(tmpTokens.length - 1));
            tmpUsers.push(address(uint160(token2)));

            expect.claim().exec(tmpTokens, tmpUsers, lib.txdata(users.frank, 0, ""));
        }
        // forge.vm.stopPrank();
    }

    event log_array(uint160[] tmp);

    function test__system__frankMulticlaimLosingItemAndNuggs() public clean {
        deeSellsAnItem();
        userMints(users.frank, token2);
        userMints(users.dennis, token3);

        jumpStart();

        // forge.vm.startPrank(users.frank);
        {
            for (uint16 i = 0; i < 100; i++) {
                jumpUp(1);
                tmpTokens.push(nuggft.epoch());
                uint96 value = nuggft.msp();
                expect.offer().exec(tmpTokens[i], lib.txdata(users.frank, value, ""));

                uint96 dennisIsABastardMan = nuggft.vfo(users.dennis, tmpTokens[i]);

                expect.offer().exec(tmpTokens[i], lib.txdata(users.dennis, dennisIsABastardMan, ""));
            }

            expect.offer().exec(token2, token1, itemId, lib.txdata(users.frank, nuggft.vfo(token2, token1, itemId), ""));

            expect.offer().exec(token3, token1, itemId, lib.txdata(users.dennis, nuggft.vfo(token3, token1, itemId), ""));

            tmpTokens.push(encItemIdClaim(token1, itemId));

            jumpSwap();

            tmpUsers = lib.mAddress(users.frank, uint16(tmpTokens.length - 1));
            tmpUsers.push(address(uint160(token2)));

            expect.claim().exec(tmpTokens, tmpUsers, lib.txdata(users.frank, 0, ""));
        }
        // forge.vm.stopPrank();
    }

    function test__system__nuggFactory() public clean {
        uint16 nugg__size = 100;
        uint256 user__count = 0;

        nuggft.mint{value: 0.02 ether}(token1);

        for (uint16 i = 0; i < nugg__size; i++) {
            jumpUp(1);
            tmpTokens.push(nuggft.epoch());
            for (; user__count < i * 10; user__count++) {
                tmpUsers.push(address(uint160(uint256(keccak256("nuggfactory")) + user__count)));
                uint96 money = nuggft.vfo(tmpUsers[user__count], tmpTokens[i]);
                forge.vm.deal(tmpUsers[user__count], money);
                expect.offer().start(tmpTokens[i], tmpUsers[user__count], money);
                forge.vm.prank(tmpUsers[user__count]);
                nuggft.offer{value: money}(tmpTokens[i]);
                expect.offer().stop();
            }
        }

        jumpSwap();
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
        jumpStart();

        nuggft.mint{value: 0.02 ether}(token1);

        uint16 size = 2;

        address[] memory user__list = new address[](size);

        for (uint256 i = 0; i < size; i++) {
            user__list[i] = address(uint160(uint256(keccak256(abi.encodePacked(i + 6)))));
        }

        for (uint24 p = 0; p < size; p++) {
            for (uint256 i = 0; i < size; i++) {
                tmpUsers.push(user__list[i]);
                uint160 epoch = nuggft.epoch();
                tmpTokens.push(epoch);
                for (uint256 j = 0; j < size; j++) {
                    uint96 money = nuggft.vfo(user__list[j], epoch);
                    forge.vm.deal(user__list[j], money);
                    expect.offer().start(epoch, user__list[j], money);
                    forge.vm.prank(user__list[j]);
                    nuggft.offer{value: money}(epoch);
                    expect.offer().stop();
                }
            }

            jumpUp(1);
            nuggft.epoch();
        }
        jumpSwap();
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

        expect.claim().from(tmpUsers[1]).err(0xA0).exec(lib.sarr160(tmpTokens[1]), lib.sarrAddress(tmpUsers[1]));
    }

    function test__system__revert__0xA0__claim__twice__frank() public clean {
        forge.vm.startPrank(users.frank);
        jumpStart();
        jumpUp(1000);
        uint160 token = nuggft.epoch();
        nuggft.offer{value: 0.2 ether}(token);
        jumpSwap();
        nuggft.claim(lib.sarr160(token), lib.sarrAddress(users.frank));
        forge.vm.expectRevert(hex"7e863b48_A0");
        nuggft.claim(lib.sarr160(token), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    function test__system__revert__0x67__claim__early__frank() public clean {
        forge.vm.startPrank(users.frank);
        jumpStart();
        jumpUp(1000);
        uint160 token = nuggft.epoch();
        nuggft.offer{value: 0.2 ether}(token);
        forge.vm.expectRevert(hex"7e863b48_67");
        nuggft.claim(lib.sarr160(token), lib.sarrAddress(users.frank));
        forge.vm.stopPrank();
    }

    // 3165405740233807789653026790548718548040
    // 79228162514264337593543950336

    function test__system__item__sell__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(token1);

        uint16[] memory f = nuggft.floop(token1);

        itemId = uint16(f[1]);

        // nuggft.floop(token1);
        nuggft.sell(token1, itemId, 50 ether);
        // nuggft.sell(token1, 90 ether);
        // nuggft.floop(token1);
        // nuggft.rotate(token1, 1, 8);
        // nuggft.floop(token1);

        // nuggft.proofToDotnuggMetadata(token1);

        forge.vm.stopPrank();
    }

    function test__system__revert__0x99__item__sellThenOffer__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(token1);

        uint16[] memory f = nuggft.floop(token1);

        itemId = uint16(f[1]);

        nuggft.sell(token1, itemId, 50 ether);
        forge.vm.expectRevert(hex"7e863b48_99");
        nuggft.offer{value: 1 ether}(token1, token1, itemId);

        forge.vm.stopPrank();
    }

    function test__system__item__sellWaitThenOffer__frank() public clean {
        jumpStart();
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(token1);

        uint16[] memory f = nuggft.floop(token1);

        itemId = uint16(f[1]);

        // nuggft.floop(token1);
        nuggft.sell(token1, itemId, 1 ether);
        // forge.vm.expectRevert(hex'7e863b48_99');
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dee);
        nuggft.mint{value: nuggft.msp()}(token2);
        nuggft.offer{value: 1.1 ether}(token2, token1, itemId);
        forge.vm.stopPrank();

        forge.vm.prank(users.frank);
        nuggft.offer{value: 1.2 ether}(token1, token1, itemId);
        // nuggft.sell(token1, 90 ether);
        // nuggft.floop(token1);
        // nuggft.rotate(token1, 1, 8);s
        // nuggft.floop(token1);

        // nuggft.proofToDotnuggMetadata(token1);
    }

    function test__system__item__sellTwo__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(token1);

        uint16[] memory f = nuggft.floop(token1);

        itemId = uint16(f[1]);

        nuggft.sell(token1, itemId, 50 ether);
        // nuggft.claim(lib.sarr160(encItemIdClaim(token1, itemId)), lib.sarr160(token1));

        nuggft.floop(token1);

        itemId = uint16(f[2]);

        nuggft.sell(token1, itemId, 50 ether);

        forge.vm.stopPrank();
    }

    function test__system__item__sellTwoClaimBack__frank() public clean {
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: 0.2 ether}(token1);

        uint16[] memory f = nuggft.floop(token1);

        itemId = uint16(f[1]);
        nuggft.sell(token1, itemId, 50 ether);
        nuggft.claim(lib.sarr160(encItemIdClaim(token1, itemId)), lib.sarr160(token1));

        nuggft.floop(token1);

        itemId = uint16(f[2]);
        nuggft.sell(token1, itemId, 50 ether);
        nuggft.claim(lib.sarr160(encItemIdClaim(token1, itemId)), lib.sarr160(token1));

        forge.vm.stopPrank();
    }

    function test__system__item__offerWar__frankSale() public clean {
        test__system__item__sell__frank();
        jumpStart();
        uint16 size = 20;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(i + 100));
            tmpTokens.push(uint160(token2 + i));
            uint96 msp = nuggft.msp();
            uint96 vfo = nuggft.vfo(tmpTokens[i], token1, itemId);
            forge.vm.deal(tmpUsers[i], vfo + msp);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: msp}(tmpTokens[i]);
            nuggft.offer{value: vfo}(tmpTokens[i], token1, itemId);
            forge.vm.stopPrank();
        }
    }

    function test__system__item__everyoneClaimsTheirOwn__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jumpSwap();

        for (uint16 i = 0; i < tmpTokens.length; i++) {
            forge.vm.prank(tmpUsers[i]);
            nuggft.claim(lib.sarr160(encItemIdClaim(token1, itemId)), lib.sarr160(tmpTokens[i]));
        }
    }

    function test__system__revert__0x74__item__oneClaimsAll__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jumpSwap();

        forge.vm.expectRevert(hex"7e863b48_74");
        forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
        nuggft.claim(lib.m160(encItemIdClaim(token1, itemId), uint16(tmpUsers.length)), tmpTokens);
    }

    function test__system__item__trustlessWinnerClaim__offerWar__frankSale() public clean {
        test__system__item__offerWar__frankSale();

        jumpSwap();

        forge.vm.prank(tmpUsers[tmpUsers.length - 2]);
        nuggft.claim(lib.sarr160(encItemIdClaim(token1, itemId)), lib.sarr160(tmpTokens[tmpUsers.length - 1]));
    }

    uint160[] tmpIds;

    // function test__system__item__offerWar__ffrankSale__hf() clean public {
    //     test__system__item__sell__frank();
    //     forge.vm.prank(users.frank);
    //     nuggft.sell(token1, .9 ether);

    //     // nuggft.mint{value: 200 ether}(509);

    //     uint16 size = 20;
    //     uint96 money = .69696969 ether;

    //     for (uint256 i = 0; i < size; i++) {
    //         tmpUsers.push(forge.vm.addr(100));
    //         tmpTokens.push(uint160(token2 + i));
    //         tmpIds.push(encItemIdClaim(token1, itemId));
    //         uint256 value = nuggft.msp();
    //         uint160 tkn = uint160(token2 + i);
    //         money = nuggft.vfo(tkn, token1, itemId);

    //         forge.vm.startPrank(tmpUsers[i]);
    //         {
    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + value);

    //             nuggft.mint{value: value}(tkn);

    //             money = nuggft.vfo(forge.vm.addr(100), token1);

    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + money);

    //             expect.offer().start(token1, tmpUsers[i], money);
    //             nuggft.offer{value: money}(tkn, token1, itemId);
    //             expect.offer().stop();

    //             money = nuggft.vfo(forge.vm.addr(100), token1);

    //             forge.vm.deal(tmpUsers[i], tmpUsers[i].balance + money);

    //             expect.offer().start(token1, tmpUsers[i], money);
    //             nuggft.offer{value: money}(token1);
    //             expect.offer().stop();
    //         }
    //         forge.vm.stopPrank();
    //         money += .42069696969 ether;
    //     }

    //     tmpUsers.push(forge.vm.addr(100));
    //     tmpIds.push(token1);

    //     tmpTokens.push(uint160(forge.vm.addr(100)));

    //     jumpSwap();

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
        nuggft.sell(token1, 90 ether);
        fragment__item__offerWar__ffrankSale__hf();
    }

    function test__system__item__initSaleThenLoanNugg() public clean {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.loan(lib.sarr160(token1));
        fragment__item__offerWar__ffrankSale__hf();
    }

    function test__system__item__initSaleThenBurnNugg() public clean {
        test__system__item__sell__frank();
        forge.vm.prank(users.frank);
        nuggft.burn(token1);
        fragment__item__offerWar__ffrankSale__hf();
    }

    function fragment__item__offerWar__ffrankSale__hf() public {
        jumpStart();

        uint16 size = 20;
        uint256 money = 1000 ether;

        for (uint256 i = 0; i < size; i++) {
            tmpUsers.push(forge.vm.addr(100));
            tmpTokens.push(uint160(token2 + i));
            tmpIds.push(encItemIdClaim(token1, itemId));
            uint256 value = nuggft.msp();
            uint160 tkn = uint160(token2 + i);

            forge.vm.deal(tmpUsers[i], value + money);
            forge.vm.startPrank(tmpUsers[i]);
            nuggft.mint{value: value}(tkn);
            money = nuggft.vfo(tkn, token1, itemId);
            nuggft.offer{value: money}(tkn, token1, itemId);

            forge.vm.stopPrank();
            money += 10 ether;
        }

        jumpSwap();

        forge.vm.prank(tmpUsers[size - 3]);
        nuggft.claim(tmpIds, tmpTokens);
    }

    function test__system__hotproof__pass() public {
        logHotproof();

        jumpStart();

        uint24 tokenId = nuggft.epoch();

        uint256 proofBeforeOffer = nuggft.proofOf(tokenId);

        expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, tokenId)}(tokenId);

        uint256 proofAfterOffer = nuggft.proofOf(tokenId);
        logHotproof();

        jumpUp(1);

        uint24 tokenId2 = nuggft.epoch();
        nuggft.check(users.frank, tokenId2);

        expect.offer().from(users.dee).exec{value: nuggft.vfo(users.dee, tokenId2)}(tokenId2);
        logHotproof();

        jumpSwap();

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
