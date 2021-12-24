// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract revertTest__stake is t, NuggFatherFix {
    uint32 epoch;

    function setUp() public {
        reset();
        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            [T:1] - addStakedShareFromMsgValue - "value of tx too low"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // mint
    // ────

    function test__revert__stake__T_1__success() public {
        nuggft_call(frank, mint(2099), 30 * 10**16);
    }

    function test__revert__stake__T_1__fail() public {
        nuggft_call(frank, mint((2099)), 30 * 10**18);

        nuggft_revertCall('T:1', dennis, mint(2909), 29 * 10**18);
    }

    function test__revert__stake__T_1__fail_fromZero() public {
        nuggft_call(frank, mint((2099)), 30 * 10**18);

        nuggft_revertCall('T:1', dennis, mint(2909));
    }

    // trustedMint
    // ────

    function test__revert__stake__T_1__successOnTrusted() public {
        nuggft_call(safe, trustedMint(99, address(frank)), 30 * 10**16);
    }

    function test__revert__stake__T_1__failOnTrusted() public {
        nuggft_call(safe, trustedMint(99, address(frank)), 30 * 10**18);

        nuggft_revertCall('T:1', safe, trustedMint(9, address(dennis)), 29 * 10**18);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         [T:2] - value of tx too low  @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             [T:3] - subStakedShare - "user not granded permission"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // withdrawStake
    // ─────────────

    function test__revert__stake__T_3__withdrawStake__fail() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_revertCall('T:3', mac, withdrawStake(tokenId));
    }

    function test__revert__stake__T_3__withdrawStake__failOnNoApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_revertCall('T:3', dee, withdrawStake(tokenId));
    }

    function test__revert__stake__T_3__withdrawStake__succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_call(dee, approve(address(nuggft), tokenId));

        nuggft_call(dee, withdrawStake(tokenId));
    }

    function test__revert__stake__T_3__withdrawStake__failOnIncorrectApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_call(dee, approve(address(mac), tokenId));

        nuggft_revertCall('T:3', dee, withdrawStake(tokenId));
    }

    function test__revert__stake__T_3__withdrawStake__failOnIncorrectOperatorApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_call(dee, setApprovalForAll(address(mac), true));

        nuggft_call(dee, approve(address(nuggft), tokenId));

        nuggft_revertCall('T:3', dennis, withdrawStake(tokenId));
    }

    function test__revert__stake__T_3__withdrawStake__succeedsOnCorrectOperatorApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_call(dee, setApprovalForAll(address(mac), true));

        nuggft_call(dee, approve(address(nuggft), tokenId));

        nuggft_call(mac, withdrawStake(tokenId));
    }

    // migrateStake
    // ─────────────

    function test__revert__stake__T_3__migrateStake__fail() public {
        uint160 tokenId = scenario_dee_has_a_token();

        scenario_migrator_set();

        nuggft_revertCall('T:3', dee, migrateStake(tokenId));
    }

    function test__revert__stake__T_3__migrateStake__succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        scenario_migrator_set();

        nuggft_call(dee, approve(address(nuggft), tokenId));

        nuggft_call(dee, migrateStake(tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                [T:4] - migrateStake - "migrator must be set"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // migrateStake
    // ────────────

    function test__revert__stake__T_4_fail() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_revertCall('T:4', dee, migrateStake(tokenId));
    }

    function test__revert__stake__T_4_succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_call(dee, approve(address(nuggft), tokenId));

        nuggft_call(safe, setMigrator(address(migrator)));

        nuggft_call(dee, migrateStake(tokenId));
    }

    function test__revert__stake__T_4_succeedsWithApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        nuggft_call(dee, approve(address(nuggft), tokenId));

        nuggft_call(safe, setMigrator(address(migrator)));

        nuggft_call(dee, migrateStake(tokenId));
    }

    /// values add on top of each other
}
