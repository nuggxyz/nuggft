// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';

contract system__NuggftV1Swap_test is NuggftV1Test {
    using SafeCast for uint96;

    function setUp() public {
        reset();

        // mint 500 - 2999

        // trusted mint 1-499

        //
    }

    function test__logic__NuggftV1Proof__rotate() public {
        uint8[] memory lens = new uint8[](7);
        lens[1] = 0x01;
        lens[2] = 0x02;
        lens[3] = 0x03;
        lens[4] = 0x04;
        lens[5] = 0x05;
        lens[6] = 0x06;
        lens[0] = 0x07;

        uint8[] memory lens2 = new uint8[](7);
        lens2[1] = 0x09;
        lens2[2] = 0x0a;
        lens2[3] = 0x0b;
        lens2[4] = 0x0c;
        lens2[5] = 0x0d;
        lens2[6] = 0x0e;
        lens2[0] = 0x0f;

        expect.mint().from(users.frank).exec{value: 1 ether}(500);
        nuggft.floop(500);
        forge.vm.prank(users.frank);
        nuggft.rotate(500, lens, lens2);
        nuggft.floop(500);
    }

    function test__system__frankMintsATokenForFree() public {
        // expect.stake().start(0, 1, true);
        expect.balance().start(users.frank, 0, false);
        expect.balance().start(address(nuggft), 0, true);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint(500);
        }
        forge.vm.stopPrank();

        // expect.stake().stop();
        expect.balance().stop();
    }

    function test__system__frankMintsATokenFuzz(uint96 value) public {
        // expect.stake().start(value, 1, true);

        forge.vm.deal(users.frank, value);

        expect.balance().start(users.frank, value, false);
        expect.balance().start(address(nuggft), value, true);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(500);
        }
        forge.vm.stopPrank();

        // expect.stake().stop();
        expect.balance().stop();
    }

    // function test__system__frankMintsATokenForMaxTwice__FAILS_HORRIBLY() public {
    //     uint96 value = type(uint96).max;

    //     emit log_uint(0);

    //     expect.stake().start(value, 1, true);

    //     emit log_uint(1);

    //     forge.vm.deal(users.frank, value);

    //     expect.balance().start(users.frank, value, false);

    //     emit log_uint(2);

    //     expect.balance().start(address(nuggft), value, true);

    //     emit log_uint(3);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.mint{value: value}(500);
    //     }
    //     forge.vm.stopPrank();

    //     emit log_uint(4);

    //     expect.stopExpectStak
    // expect.balance().stop();e();

    //     emit log_uint(0);

    //     expect.stake().start(value, 1, true);

    //     emit log_uint(1);

    //     forge.vm.deal(users.frank, value);

    //     expect.balance().start(users.frank, value, false);

    //     emit log_uint(2);

    //     expect.balance().start(address(nuggft), value, true);

    //     emit log_uint(3);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.mint{value: value}(501);
    //     }
    //     forge.vm.stopPrank();

    //     emit log_uint(4);

    //     expect.stopExpectStak
    // expect.balance().stop();e();

    // }

    function test__system__frankMintsATokenForMax() public {
        uint96 value = type(uint96).max;

        emit log_uint(0);

        // expect.stake().start(value, 1, true);

        emit log_uint(1);

        forge.vm.deal(users.frank, value);

        expect.balance().start(users.frank, value, false);

        emit log_uint(2);

        expect.balance().start(address(nuggft), value, true);

        emit log_uint(3);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(500);
        }
        forge.vm.stopPrank();

        emit log_uint(4);

        // expect.stake().stop();
        expect.balance().stop();
    }

    function test__system__frankMintsATokenFor100gwei() public {
        uint96 value = 1000 gwei;

        uint160 tokenId = 500;

        // expect.stake().start(value, 1, true);
        expect.balance().start(users.frank, value, false);
        expect.balance().start(address(nuggft), value, true);

        forge.vm.startPrank(users.frank);
        {
            expect.mint().start(tokenId, users.frank, value);
            nuggft.mint{value: value}(500);
            expect.mint().stop();
        }
        forge.vm.stopPrank();

        // expect.stake().stop();
        expect.balance().stop();
    }
}
