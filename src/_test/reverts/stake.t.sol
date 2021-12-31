// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';

contract revertTest__stake is NuggftV1Test {
    uint32 epoch;

    using UserTarget for address;

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
        _nuggft.shouldPass(frank, mint(2099), 30 * 10**16);
    }

    function test__revert__stake__T_1__fail() public {
        _nuggft.shouldPass(frank, mint((2099)), 30 * 10**18);

        _nuggft.shouldFail('T:1', dennis, mint(2909), 29 * 10**18);
    }

    function test__revert__stake__T_1__fail_fromZero() public {
        // console.logb(34);
        _nuggft.shouldPass(frank, mint((2099)), 30 * 10**18);

        _nuggft.shouldFail('T:1', dennis, mint(2909));
    }

    // trustedMint
    // ────

    function test__revert__stake__T_1__successOnTrusted() public {
        _nuggft.shouldPass(safe, trustedMint(99, address(frank)), 30 * 10**16);
    }

    function test__revert__stake__T_1__failOnTrusted() public {
        // console.log(address(safe).balance);

        _nuggft.shouldPass(safe, trustedMint(99, address(frank)), 15 * 10**18);

        // console.log(address(safe).balance);

        _nuggft.shouldFail('T:1', safe, trustedMint(9, address(dennis)), 14 * 10**18);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         [T:2] - value of tx too low  @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             [T:3] - subStakedShare - "user not granded permission"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // burn
    // ─────────────

    function test__revert__stake__T_3__burn__fail() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldFail('T:3', mac, burn(tokenId));
    }

    function test__revert__stake__T_3__burn__failOnNoApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldFail('T:3', dee, burn(tokenId));
    }

    function test__revert__stake__T_3__burn__succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldPass(dee, approve(address(nuggft), tokenId));

        _nuggft.shouldPass(dee, burn(tokenId));
    }

    function test__revert__stake__T_3__burn__failOnIncorrectApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldPass(dee, approve(address(mac), tokenId));

        _nuggft.shouldFail('T:3', dee, burn(tokenId));
    }

    function test__revert__stake__T_3__burn__failOnIncorrectOperatorApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldPass(dee, setApprovalForAll(address(mac), true));

        _nuggft.shouldPass(dee, approve(address(nuggft), tokenId));

        _nuggft.shouldFail('T:3', dennis, burn(tokenId));
    }

    function test__revert__stake__T_3__burn__failsOnCorrectOperatorApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldPass(dee, setApprovalForAll(address(mac), true));

        _nuggft.shouldPass(dee, approve(address(nuggft), tokenId));

        _nuggft.shouldFail('T:3', mac, burn(tokenId));
    }

    // migrate
    // ─────────────

    function test__revert__stake__T_3__migrate__fail() public {
        uint160 tokenId = scenario_dee_has_a_token();

        scenario_migrator_set();

        _nuggft.shouldFail('T:3', dee, migrate(tokenId));
    }

    function test__revert__stake__T_3__migrate__succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        scenario_migrator_set();

        _nuggft.shouldPass(dee, approve(address(nuggft), tokenId));

        _nuggft.shouldPass(dee, migrate(tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                [T:4] - migrate - "migrator must be set"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // migrate
    // ────────────

    function test__revert__stake__T_4_fail() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldFail('T:4', dee, migrate(tokenId));
    }

    function test__revert__stake__T_4_succeeds() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldPass(dee, approve(address(nuggft), tokenId));

        _nuggft.shouldPass(safe, setMigrator(address(migrator)));

        _nuggft.shouldPass(dee, migrate(tokenId));
    }

    function test__revert__stake__T_4_succeedsWithApproval() public {
        uint160 tokenId = scenario_dee_has_a_token();

        _nuggft.shouldPass(dee, approve(address(nuggft), tokenId));

        _nuggft.shouldPass(safe, setMigrator(address(migrator)));

        _nuggft.shouldPass(dee, migrate(tokenId));
    }

    /// values add on top of each other
}
