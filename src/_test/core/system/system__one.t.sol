// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

abstract contract system__one is NuggftV1Test {
    using SafeCast for uint96;

    uint24 private TOKEN1;

    function test__logic__NuggftV1Proof__rotate() public {
        TOKEN1 = mintable(1);

        expect.mint().from(users.frank).exec{value: 1 ether}(TOKEN1);
        nuggft.floop(TOKEN1);

        forge.vm.startPrank(users.frank);
        nuggft.rotate(TOKEN1, array.b8(1, 2, 3, 4, 5, 6, 7), array.b8(9, 10, 11, 12, 13, 14, 15));
        nuggft.floop(TOKEN1);
        forge.vm.expectRevert(hex"7e863b48_73");
        nuggft.rotate(TOKEN1, array.b8(1, 2, 3, 4, 5, 6, 7), array.b8(9, 10, 11, 12, 13, 14, 16));

        forge.vm.expectRevert(hex"7e863b48_73");
        nuggft.rotate(TOKEN1, array.b8(0, 2, 3, 4, 5, 6, 7), array.b8(9, 10, 11, 12, 13, 14, 15));
        forge.vm.stopPrank();
    }

    function test__system__frankMintsATokenForFree() public {
        TOKEN1 = mintable(1);

        // expect.stake().start(0, 1, true);
        expect.balance().start(users.frank, 0, false);
        expect.balance().start(address(nuggft), 0, true);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint(TOKEN1);
        }
        forge.vm.stopPrank();

        // expect.stake().stop();
        expect.balance().stop();
    }

    function test__system__frankMintsATokenFuzz(uint96 value) public {
        TOKEN1 = mintable(1);

        // expect.stake().start(value, 1, true);

        forge.vm.deal(users.frank, value);

        expect.balance().start(users.frank, value, false);
        expect.balance().start(address(nuggft), value, true);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(TOKEN1);
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
    //         nuggft.mint{value: value}(TOKEN1);
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
        TOKEN1 = mintable(1);

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
            nuggft.mint{value: value}(TOKEN1);
        }
        forge.vm.stopPrank();

        emit log_uint(4);

        // expect.stake().stop();
        expect.balance().stop();
    }

    function test__system__frankMintsATokenFor100gwei() public {
        TOKEN1 = mintable(1);

        uint96 value = 1000 gwei;

        uint24 tokenId = TOKEN1;

        // expect.stake().start(value, 1, true);
        expect.balance().start(users.frank, value, false);
        expect.balance().start(address(nuggft), value, true);

        forge.vm.startPrank(users.frank);
        {
            expect.mint().start(tokenId, users.frank, value);
            nuggft.mint{value: value}(TOKEN1);
            expect.mint().stop();
        }
        forge.vm.stopPrank();

        // expect.stake().stop();
        expect.balance().stop();
    }
}
