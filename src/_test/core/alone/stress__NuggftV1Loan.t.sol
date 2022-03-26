// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

import {ShiftLib} from "../../helpers/ShiftLib.sol";
import {NuggftV1Loan} from "../../../core/NuggftV1Loan.sol";

contract stress__NuggftV1Loan is NuggftV1Test {
    uint160 internal constant LOAN_TOKENID = 1499;

    uint160 multiplier = 10;

    function setUp() public {
        reset();

        expect.mint().from(users.frank).exec{value: 1 ether}(LOAN_TOKENID);

        expect.loan().from(users.frank).exec(lib.sarr160(LOAN_TOKENID));
    }

    function test__stress__NuggftV1Loan__rebalance2() public globalDs {
        forge.vm.deal(users.frank, 1000000000 ether);
        forge.vm.startPrank(users.frank);

        for (uint256 i = 0; i < 10 * multiplier; i++) {
            uint96 frankStartBal = uint96(users.frank.balance);

            (, , , , , uint24 b_insolventEpoch) = nuggft.debt(LOAN_TOKENID);

            uint160 tokenId = nuggft.epoch();

            uint96 value = nuggft.vfo(users.frank, tokenId);
            nuggft.offer{value: value}(tokenId);

            (, , , uint96 __fee, uint96 __earn, ) = nuggft.debt(LOAN_TOKENID);

            uint96 valueforRebal = nuggft.vfr(lib.sarr160(LOAN_TOKENID))[0];
            nuggft.rebalance{value: valueforRebal}(lib.sarr160(LOAN_TOKENID));

            (, , , , , uint24 a_insolventEpoch) = nuggft.debt(LOAN_TOKENID);

            {
                require(b_insolventEpoch == a_insolventEpoch || b_insolventEpoch == a_insolventEpoch - 1, "A");
                // console.log(frankStartBal, users.frank.balance);
                console.log(nuggft.eps(), nuggft.msp());

                // require(frankStartBal - value - valueforRebal == users.frank.balance, 'B');
                require(frankStartBal - value + __earn - __fee == users.frank.balance, "D");
            }

            hopUp(1);
        }

        forge.vm.stopPrank();
    }

    function test__stress__NuggftV1Loan__rebalance__multi() public globalDs {
        console.log(nuggft.eps(), nuggft.msp());
        forge.vm.deal(users.frank, 1000000000 ether);

        uint160[] memory tokenIds = new uint160[](950);
        forge.vm.startPrank(users.frank);

        for (uint160 i = 500; i < 1450; i++) {
            tokenIds[i - 500] = i;

            nuggft.mint{value: nuggft.msp()}(i);

            nuggft.loan(lib.sarr160(i));
        }

        // uint96 frankStartBal = uint96(users.frank.balance);

        // (, , , , uint24 b_insolventEpoch) = nuggft.loanInfo(LOAN_TOKENID);

        uint160 tokenId = nuggft.epoch();

        uint96 value = nuggft.vfo(users.frank, tokenId);
        // forge.vm.startPrank(users.frank);
        nuggft.offer{value: value}(tokenId);

        // uint96 valueforRebal = nuggft.valueForRebalance(LOAN_TOKENID);
        // forge.vm.startPrank(users.frank);
        nuggft.rebalance{value: users.frank.balance}(tokenIds);
    }

    function test__stress__NuggftV1Loan__rebalance__multi__manyAccounts() public globalDs {
        console.log(nuggft.eps(), nuggft.msp());
        // forge.vm.deal(users.frank, 1000000000 ether);

        uint160[] memory tokenIds = new uint160[](950);

        jump(OFFSET + 1);

        for (uint160 i = 500; i < 1450; i++) {
            address a = forge.vm.addr(i * 2699);

            tokenIds[i - 500] = i;

            forge.vm.deal(a, nuggft.msp());

            expect.mint().from(a).exec{value: a.balance}(i);

            expect.loan().from(a).exec(lib.sarr160(i));
        }

        emit log_named_uint("balance", address(nuggft).balance);

        jump(OFFSET + LIQUIDATION_PERIOD + 2);

        // uint96 frankStartBal = uint96(users.frank.balance);

        // (, , , , uint24 b_insolventEpoch) = nuggft.loanInfo(LOAN_TOKENID);

        // uint160 tokenId = nuggft.epoch();
        // (, uint96 nextSwapAmount, uint96 senderCurrentOffer) = nuggft.check(users.frank, tokenId);

        // uint96 value = nextSwapAmount - senderCurrentOffer;
        // // forge.vm.startPrank(users.frank);
        // nuggft.offer{value: value}(tokenId);

        // uint96 valueforRebal = nuggft.valueForRebalance(LOAN_TOKENID);

        uint96[] memory vals = nuggft.vfr(tokenIds);

        uint96 tv = 0;

        for (uint256 i = 0; i < vals.length; i++) {
            tv += vals[i];
        }
        // forge.vm.deal(users.frank, tv);
        // forge.vm.prank(users.frank);
        // nuggft.rebalance{value: tv}(tokenIds);

        expect.rebalance().from(users.frank).exec{value: tv}(tokenIds);
    }

    function test__stress__NuggftV1Loan__rebalance__small() public {
        console.log(nuggft.eps(), nuggft.msp());

        jump(OFFSET + 1);

        address a = address(uint160(0x11111));
        address b = address(uint160(0x22222));

        uint160 tokenId = 500;
        uint160 tokenId2 = 501;

        expect.mint().from(a).exec{value: nuggft.msp()}(tokenId);
        expect.mint().from(b).exec{value: nuggft.msp()}(tokenId2);

        expect.loan().from(a).exec(lib.sarr160(tokenId));
        expect.loan().from(b).exec(lib.sarr160(tokenId2));

        emit log_named_uint("balance", address(nuggft).balance);

        jump(OFFSET + LIQUIDATION_PERIOD + 2);

        uint160[] memory tokenIds = array.b160(tokenId, tokenId2);

        uint96[] memory vals = nuggft.vfr(tokenIds);

        uint96 tv = vals[0] + vals[1];

        // for (uint256 i = 0; i < vals.length; i++) {
        //     tv += vals[i];
        // }
        // forge.vm.deal(users.frank, tv);
        // forge.vm.prank(users.frank);
        // nuggft.rebalance{value: tv}(tokenIds);

        expect.rebalance().from(users.frank).exec{value: tv}(tokenIds);

        nuggft.agency(tokenId);
        nuggft.agency(tokenId2);
    }
}
//   990090000000000000
//  1009891800000000000
//  1009891800000000000
