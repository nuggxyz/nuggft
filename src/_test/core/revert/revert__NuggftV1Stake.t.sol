// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";

abstract contract revert__NuggftV1Stake is NuggftV1Test {
    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            [T:1] - addStakedShareFromMsgValue - "value of tx too low"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    uint24 private TOKEN1;
    uint24 private TOKEN2;

    // mint
    // ────

    function test__revert__NuggftV1Stake__0x71__mint__success() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        uint24 tokenId = TOKEN1;

        uint96 value = 30 ether;

        forge.vm.deal(users.frank, 30 ether);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Stake__0x71__mint__failWithValue() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        test__revert__NuggftV1Stake__0x71__mint__success();

        expect.mint().err(0x71).from(users.dennis).exec{value: nuggft.eps() - 1}(TOKEN2);
    }

    function test__revert__NuggftV1Stake__0x71__mint__failWithZero() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        test__revert__NuggftV1Stake__0x71__mint__success();

        expect.mint().err(0x71).from(users.dennis).exec(TOKEN2);
    }

    // trustedMint
    // ────

    function test__revert__NuggftV1Stake__0x71__mint__successOnTrusted() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        forge.vm.deal(users.safe, 200 ether);
        forge.vm.startPrank(users.safe);
        {
            nuggft.trustedMint{value: 30 ether}(trustMintable(200), users.frank);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Stake__0x71__trustedMint__failOnTrustedNotEnoughValue() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        if (nuggft.shares() != 0) return;

        forge.vm.startPrank(users.safe);
        {
            uint24 tokenId = trustMintable(6);

            uint96 value = 500 gwei;

            forge.vm.deal(users.safe, value);

            nuggft.trustedMint{value: value}(tokenId, users.frank);

            tokenId = trustMintable(7);

            value = 450 gwei;

            forge.vm.deal(users.safe, value);

            nuggft.msp();

            forge.vm.expectRevert(hex"7e863b48_71");
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

    function test__revert__NuggftV1Stake__0x77__burn__failNotOwner() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        uint24 tokenId = scenario_dee_has_a_token();

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert(hex"7e863b48_77");
            nuggft.burn(tokenId);
        }
        forge.vm.stopPrank();
    }

    // function test__revert__NuggftV1Stake__0x73__burn__failNoApproval() public {
    //         TOKEN1 = mintable(2099);
    // TOKEN2 = mintable(2098);
    //     //     uint24 tokenId = scenario_dee_has_a_token();

    //     //     forge.vm.startPrank(users.dee);
    //     //     {
    //     //         forge.vm.expectRevert(hex'7e863b48_73');
    //     //         nuggft.burn(tokenId);
    //     //     }
    //     //     forge.vm.stopPrank();
    //     // }

    //     // function test__revert__NuggftV1Stake__0x73__burn__succeedsWithApproval() public {
    //         TOKEN1 = mintable(2099);
    // TOKEN2 = mintable(2098);
    //     //     uint24 tokenId = scenario_dee_has_a_token();

    //     //     forge.vm.startPrank(users.dee);
    //     //     {
    //     //         nuggft.approve(_nuggft, tokenId);
    //     //         nuggft.burn(tokenId);
    //     //     }
    //     //     forge.vm.stopPrank();
    //     // }

    //     // function test__revert__NuggftV1Stake__0x73__burn__failOnIncorrectApproval() public {
    //         TOKEN1 = mintable(2099);
    // TOKEN2 = mintable(2098);
    //     //     uint24 tokenId = scenario_dee_has_a_token();

    //     //     forge.vm.startPrank(users.dee);
    //     //     {
    //     //         nuggft.approve(users.mac, tokenId);

    //     //         forge.vm.expectRevert(hex'7e863b48_73');
    //     //         nuggft.burn(tokenId);
    //     //     }
    //     //     forge.vm.stopPrank();
    //     // }

    //     // function test__revert__NuggftV1Stake__0x73__burn__failOnIncorrectOperatorApproval() public {
    //         TOKEN1 = mintable(2099);
    // TOKEN2 = mintable(2098);
    //     uint24 tokenId = scenario_dee_has_a_token();

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.approve(_nuggft, tokenId);

    //         nuggft.setApprovalForAll(users.mac, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_73');
    //         nuggft.burn(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Stake__0x73__burn__failsOnCorrectOperatorApproval() public {
    //         TOKEN1 = mintable(2099);
    // TOKEN2 = mintable(2098);
    //     //     uint24 tokenId = scenario_dee_has_a_token();

    //     //     forge.vm.startPrank(users.dee);
    //     //     {
    //     //         nuggft.approve(_nuggft, tokenId);

    //     //         nuggft.setApprovalForAll(users.mac, true);
    //     //     }
    //     //     forge.vm.stopPrank();

    //     //     forge.vm.startPrank(users.mac);
    //     //     {
    //     //         forge.vm.expectRevert(hex'7e863b48_73');
    //     //         nuggft.burn(tokenId);
    //     //     }
    //     //     forge.vm.stopPrank();
    //     // }

    //     // migrate
    //     // ─────────────
    //     // function test__revert__NuggftV1Stake__0x73__migrate__failNoApproval() public {
    //         TOKEN1 = mintable(2099);
    // TOKEN2 = mintable(2098);
    //     uint24 tokenId = scenario_dee_has_a_token();

    //     scenario_migrator_set();

    //     forge.vm.startPrank(users.dee);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_73');
    //         nuggft.migrate(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Stake__0x73__migrate__succeeds() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        uint24 tokenId = scenario_dee_has_a_token();

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

    function test__revert__NuggftV1Stake__0x81__migrate__fail() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        uint24 tokenId = scenario_dee_has_a_token();

        // _nuggft.shouldFail(hex'81', dee, migrate(tokenId));

        forge.vm.startPrank(users.dee);
        {
            // nuggft.approve(_nuggft, tokenId);

            forge.vm.expectRevert(hex"7e863b48_81");
            nuggft.migrate(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Stake__0x81__migrate__succeeds() public {
        TOKEN1 = mintable(2099);
        TOKEN2 = mintable(2098);
        uint24 tokenId = scenario_dee_has_a_token();
        scenario_migrator_set();

        forge.vm.startPrank(users.dee);
        {
            // nuggft.approve(_nuggft, tokenId);

            nuggft.migrate(tokenId);
        }
        forge.vm.stopPrank();
    }

    /// values add on top of each other
}
