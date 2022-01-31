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
        expect.mint().from(users.frank).exec{value: 1 ether}(500);
        nuggft.floop(500);
        forge.vm.prank(users.frank);
        nuggft.rotate(500, array.b8(1, 2, 3, 4, 5, 6, 7), array.b8(9, 10, 11, 12, 13, 14, 15));
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
