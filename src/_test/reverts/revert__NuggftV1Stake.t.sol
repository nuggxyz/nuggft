// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';

contract revert__NuggftV1Stake is NuggftV1Test {
    uint32 epoch;

    using UserTarget for address;

    function setUp() public {
        reset();
        fvm.roll(15000);

        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            [T:1] - addStakedShareFromMsgValue - "value of tx too low"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // mint
    // ────

    function test__revert__NuggftV1Stake__T_1__mint__success() public {
        uint160 tokenId = 2099;

        uint96 value = 30 ether;

        forge.vm.deal(users.frank, 30 ether);

        fvm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(tokenId);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_1__mint__failWithValue() public {
        test__revert__NuggftV1Stake__T_1__mint__success();

        fvm.startPrank(users.dennis);
        {
            fvm.expectRevert('T:1');

            nuggft.mint{value: 29 ether}(2909);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_1__mint__failWithZero() public {
        test__revert__NuggftV1Stake__T_1__mint__success();

        fvm.startPrank(users.dennis);
        {
            fvm.expectRevert('T:1');
            nuggft.mint{value: 0}(2909);
        }
        fvm.stopPrank();
    }

    // trustedMint
    // ────

    function test__revert__NuggftV1Stake__T_1__mint__successOnTrusted() public {
        fvm.startPrank(users.safe);
        {
            nuggft.trustedMint{value: 30 ether}(200, users.frank);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_1__trustedMint__failOnTrustedNotEnoughValue() public {
        require(nuggft.shares() == 0, 'OOPS');

        forge.vm.startPrank(users.safe);
        {
            uint160 tokenId = 499;

            uint96 value = 500 gwei;

            forge.vm.deal(users.safe, value);

            nuggft.trustedMint{value: value}(tokenId, users.frank);

            tokenId = 498;

            value = 450 gwei;

            forge.vm.deal(users.safe, value);

            forge.vm.expectRevert('T:1');
            nuggft.trustedMint{value: value}(tokenId, users.dennis);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         [T:2] - value of tx too low  @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             [T:3] - subStakedShare - "user not granded permission"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // burn
    // ─────────────

    function test__revert__NuggftV1Stake__T_3__burn__failNotOwner() public {
        uint160 tokenId = scenario_dee_has_a_token();

        fvm.startPrank(users.mac);
        {
            forge.vm.expectRevert('T:3');
            nuggft.burn(tokenId);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_3__burn__failNoApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        fvm.startPrank(users.dee);
        {
            forge.vm.expectRevert('T:3');
            nuggft.burn(tokenId);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_3__burn__succeedsWithApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        fvm.startPrank(users.dee);
        {
            nuggft.approve(_nuggft, tokenId);
            nuggft.burn(tokenId);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_3__burn__failOnIncorrectApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        fvm.startPrank(users.dee);
        {
            nuggft.approve(users.mac, tokenId);

            forge.vm.expectRevert('T:3');
            nuggft.burn(tokenId);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_3__burn__failOnIncorrectOperatorApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        fvm.startPrank(users.dee);
        {
            nuggft.approve(_nuggft, tokenId);

            nuggft.setApprovalForAll(users.mac, true);
        }
        fvm.stopPrank();

        fvm.startPrank(users.dennis);
        {
            forge.vm.expectRevert('T:3');
            nuggft.burn(tokenId);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_3__burn__failsOnCorrectOperatorApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        fvm.startPrank(users.dee);
        {
            nuggft.approve(_nuggft, tokenId);

            nuggft.setApprovalForAll(users.mac, true);
        }
        fvm.stopPrank();

        fvm.startPrank(users.mac);
        {
            forge.vm.expectRevert('T:3');
            nuggft.burn(tokenId);
        }
        fvm.stopPrank();
    }

    // migrate
    // ─────────────
    function test__revert__NuggftV1Stake__T_3__migrate__failNoApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        scenario_migrator_set();

        fvm.startPrank(users.dee);
        {
            forge.vm.expectRevert('T:3');
            nuggft.migrate(tokenId);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_3__migrate__succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        scenario_migrator_set();

        fvm.startPrank(users.dee);
        {
            nuggft.approve(_nuggft, tokenId);

            nuggft.migrate(tokenId);
        }
        fvm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                [T:4] - migrate - "migrator must be set"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // migrate
    // ────────────

    function test__revert__NuggftV1Stake__T_4__migrate__fail() public {
        uint160 tokenId = scenario_dee_has_a_token();

        // _nuggft.shouldFail('T:4', dee, migrate(tokenId));

        fvm.startPrank(users.dee);
        {
            // nuggft.approve(_nuggft, tokenId);

            forge.vm.expectRevert('T:4');
            nuggft.migrate(tokenId);
        }
        fvm.stopPrank();
    }

    function test__revert__NuggftV1Stake__T_4__migrate__succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        fvm.startPrank(users.dee);
        {
            nuggft.approve(_nuggft, tokenId);

            scenario_migrator_set();

            nuggft.migrate(tokenId);
        }
        fvm.stopPrank();
    }

    /// values add on top of each other
}
