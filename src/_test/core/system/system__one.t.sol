// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';

contract system__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    function setUp() public {
        reset();

        // mint 500 - 2999

        // trusted mint 1-499

        //
    }

    function test__system__frankMintsATokenForFree() public {
        expectStakeChange(0, 1, dir.up);
        expectBalChange(users.frank, 0, dir.down);
        expectBalChange(address(nuggft), 0, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint(500);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__system__frankMintsATokenFuzz(uint96 value) public {
        expectStakeChange(value, 1, dir.up);

        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(address(nuggft), value, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(500);
        }
        forge.vm.stopPrank();

        check();
    }

    // function test__system__frankMintsATokenForMaxTwice__FAILS_HORRIBLY() public {
    //     uint96 value = type(uint96).max;

    //     emit log_uint(0);

    //     expectStakeChange(value, 1, dir.up);

    //     emit log_uint(1);

    //     forge.vm.deal(users.frank, value);

    //     expectBalChange(users.frank, value, dir.down);

    //     emit log_uint(2);

    //     expectBalChange(address(nuggft), value, dir.up);

    //     emit log_uint(3);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.mint{value: value}(500);
    //     }
    //     forge.vm.stopPrank();

    //     emit log_uint(4);

    //     check();

    //     emit log_uint(0);

    //     expectStakeChange(value, 1, dir.up);

    //     emit log_uint(1);

    //     forge.vm.deal(users.frank, value);

    //     expectBalChange(users.frank, value, dir.down);

    //     emit log_uint(2);

    //     expectBalChange(address(nuggft), value, dir.up);

    //     emit log_uint(3);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.mint{value: value}(501);
    //     }
    //     forge.vm.stopPrank();

    //     emit log_uint(4);

    //     check();
    // }

    function test__system__frankMintsATokenForMax() public {
        uint96 value = type(uint96).max;

        emit log_uint(0);

        expectStakeChange(value, 1, dir.up);

        emit log_uint(1);

        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);

        emit log_uint(2);

        expectBalChange(address(nuggft), value, dir.up);

        emit log_uint(3);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(500);
        }
        forge.vm.stopPrank();

        emit log_uint(4);

        check();
    }

    function test__system__frankMintsATokenFor100gwei() public {
        uint96 value = 100 gwei;

        uint160 tokenId = 500;

        expectStakeChange(value, 1, dir.up);
        expectBalChange(users.frank, value, dir.down);
        expectBalChange(address(nuggft), value, dir.up);

        forge.vm.startPrank(users.frank);
        {
            startExpectMint(tokenId, users.frank, value);
            nuggft.mint{value: value}(500);
            endExpectMint();
        }
        forge.vm.stopPrank();

        check();
    }
}
