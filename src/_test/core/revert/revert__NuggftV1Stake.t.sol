// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import '../../NuggftV1.test.sol';

contract revert__NuggftV1Stake is NuggftV1Test {
    uint32 epoch;

    function setUp() public {
        reset();
        forge.vm.roll(15000);

        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            [T:1] - addStakedShareFromMsgValue - "value of tx too low"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // mint
    // ────

    function test__revert__NuggftV1Stake__0x71__mint__success() public {
        uint160 tokenId = 2099;

        uint96 value = 30 ether;

        forge.vm.deal(users.frank, 30 ether);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Stake__0x71__mint__failWithValue() public {
        test__revert__NuggftV1Stake__0x71__mint__success();

        forge.vm.startPrank(users.dennis);
        {
            uint96 tmp = nuggft.eps();
            forge.vm.expectRevert(hex'71');
            nuggft.mint{value: tmp - 1}(2909);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Stake__0x71__mint__failWithZero() public {
        test__revert__NuggftV1Stake__0x71__mint__success();

        expect.mint().err(0x71).from(users.dennis).exec(2909);
    }

    // trustedMint
    // ────

    function test__revert__NuggftV1Stake__0x71__mint__successOnTrusted() public {
        forge.vm.startPrank(users.safe);
        {
            nuggft.trustedMint{value: 30 ether}(200, users.frank);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Stake__0x71__trustedMint__failOnTrustedNotEnoughValue() public {
        if (nuggft.shares() != 0) return;

        forge.vm.startPrank(users.safe);
        {
            uint160 tokenId = 499;

            uint96 value = 500 gwei;

            forge.vm.deal(users.safe, value);

            nuggft.trustedMint{value: value}(tokenId, users.frank);

            tokenId = 498;

            value = 450 gwei;

            forge.vm.deal(users.safe, value);

            forge.vm.expectRevert(hex'71');
            nuggft.trustedMint{value: value}(tokenId, users.dennis);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         [T:2] - value of tx too low  @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             [0x73] - subStakedShare - "user not granded permission"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // burn
    // ─────────────

    function test__revert__NuggftV1Stake__0x73__burn__failNotOwner() public {
        uint160 tokenId = scenario_dee_has_a_token();

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert(hex'73');
            nuggft.burn(tokenId);
        }
        forge.vm.stopPrank();
    }

    // function test__revert__NuggftV1Stake__0x73__burn__failNoApproval() public {
    //     uint160 tokenId = scenario_dee_has_a_token();

    //     forge.vm.startPrank(users.dee);
    //     {
    //         forge.vm.expectRevert(hex'73');
    //         nuggft.burn(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Stake__0x73__burn__succeedsWithApproval() public {
    //     uint160 tokenId = scenario_dee_has_a_token();

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.approve(_nuggft, tokenId);
    //         nuggft.burn(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Stake__0x73__burn__failOnIncorrectApproval() public {
    //     uint160 tokenId = scenario_dee_has_a_token();

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.approve(users.mac, tokenId);

    //         forge.vm.expectRevert(hex'73');
    //         nuggft.burn(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Stake__0x73__burn__failOnIncorrectOperatorApproval() public {
    //     uint160 tokenId = scenario_dee_has_a_token();

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.approve(_nuggft, tokenId);

    //         nuggft.setApprovalForAll(users.mac, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.expectRevert(hex'73');
    //         nuggft.burn(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Stake__0x73__burn__failsOnCorrectOperatorApproval() public {
    //     uint160 tokenId = scenario_dee_has_a_token();

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.approve(_nuggft, tokenId);

    //         nuggft.setApprovalForAll(users.mac, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.mac);
    //     {
    //         forge.vm.expectRevert(hex'73');
    //         nuggft.burn(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // migrate
    // ─────────────
    // function test__revert__NuggftV1Stake__0x73__migrate__failNoApproval() public {
    //     uint160 tokenId = scenario_dee_has_a_token();

    //     scenario_migrator_set();

    //     forge.vm.startPrank(users.dee);
    //     {
    //         forge.vm.expectRevert(hex'73');
    //         nuggft.migrate(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Stake__0x73__migrate__succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        scenario_migrator_set();

        forge.vm.startPrank(users.dee);
        {
            // nuggft.approve(_nuggft, tokenId);

            nuggft.migrate(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                [T:4] - migrate - "migrator must be set"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // migrate
    // ────────────

    function test__revert__NuggftV1Stake__0x74__migrate__fail() public {
        uint160 tokenId = scenario_dee_has_a_token();

        // _nuggft.shouldFail(hex'74', dee, migrate(tokenId));

        forge.vm.startPrank(users.dee);
        {
            // nuggft.approve(_nuggft, tokenId);

            forge.vm.expectRevert(hex'74');
            nuggft.migrate(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Stake__0x74__migrate__succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        forge.vm.startPrank(users.dee);
        {
            // nuggft.approve(_nuggft, tokenId);

            scenario_migrator_set();

            nuggft.migrate(tokenId);
        }
        forge.vm.stopPrank();
    }

    /// values add on top of each other
}
