// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

abstract contract logic__NuggftV1Epoch is NuggftV1Test {
    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toEpoch
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function safe__toEpoch(uint256 blocknum, uint256 gen) internal pure returns (uint256 res) {
        res = uint256((blocknum - gen) / uint256(INTERVAL)) + uint256(OFFSET);
    }

    // function test__logic__NuggftV1Epoch__toEpoch__symbolic2() public {
    //     uint256 blocknum = 636953749;
    //     uint256 gen = 14360430;
    //     assertEq(
    //         nuggft.external__toEpoch(blocknum, gen), //
    //         safe__toEpoch(blocknum, gen),
    //         "toEpoch: real != safe"
    //     );
    // }

    function test__logic__NuggftV1Epoch__toEpoch__symbolic(uint32 blocknum, uint32 gen) public {
        if (blocknum < gen || gen < 14360430 || blocknum > 14360430 * 25) return;

        assertEq(
            nuggft.external__toEpoch(blocknum, uint32(gen)), //
            safe__toEpoch(blocknum, gen),
            "toEpoch: real != safe"
        );
    }

    // 16777216
    // 14360430
    function test__logic__NuggftV1Epoch__toEpoch__gas() public view {
        nuggft.external__toEpoch(uint32(block.number), uint32(nuggft.genesis()));
    }

    function test__logic__NuggftV1Epoch__toEpoch__gas__safe() public view {
        safe__toEpoch(uint32(block.number), nuggft.genesis());
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toStartBlock
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function safe__toStartBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        res = uint256(uint256(_epoch - OFFSET) * INTERVAL) + gen;
    }

    function test__logic__NuggftV1Epoch__toStartBlock__symbolic(uint32 _epoch, uint32 gen) public {
        uint24 epoch = uint24(_epoch);

        if (_epoch < OFFSET || _epoch > 5000000) return;
        if (gen < 1000000) return;

        if (gen == 0) return;
        if (epoch == 0) return;

        uint256 got = nuggft.external__toStartBlock(epoch, gen);
        uint256 exp = safe__toStartBlock(epoch, gen);

        assertEq(got, exp, "toStartBlock: real != safe");
    }

    function test__logic__NuggftV1Epoch__toStartBlock__gas() public view {
        nuggft.external__toStartBlock(uint24(OFFSET) + 100, uint32(nuggft.genesis()));
    }

    function test__logic__NuggftV1Epoch__toStartBlock__gas__safe() public view {
        safe__toStartBlock(uint24(OFFSET + 100), uint32(nuggft.genesis()));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toEndBlock
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function safe__toEndBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        res = safe__toStartBlock(_epoch + 1, gen) - 1;
    }

    function semisafe__toEndBlock(uint24 _epoch, uint256 gen) internal view returns (uint256 res) {
        res = nuggft.external__toStartBlock(_epoch + 1, uint32(gen)) - 1;
    }

    function test__logic__NuggftV1Epoch__toEndBlock__symbolic(uint32 _epoch, uint32 gen) public {
        uint24 epoch = uint24(_epoch);

        if (_epoch < OFFSET || _epoch > 1000000) return;
        if (gen < 1000000) return;

        if (gen == 0) return;
        if (epoch == 0) return;

        uint256 got = nuggft.external__toEndBlock(epoch, gen);
        uint256 exp = safe__toEndBlock(epoch, gen);

        assertEq(got, exp, "toEndBlock: real != safe");
    }

    function test__logic__NuggftV1Epoch__toEndBlock__gas() public view {
        nuggft.external__toEndBlock(uint24(OFFSET) + 100, uint32(nuggft.genesis()));
    }

    function test__logic__NuggftV1Epoch__toEndBlock__gas__safe() public view {
        safe__toEndBlock(uint24(OFFSET) + 100, uint32(nuggft.genesis()));
    }

    function test__logic__NuggftV1Epoch__toEndBlock__gas__semisafe() public view {
        semisafe__toEndBlock(uint24(OFFSET) + 100, uint32(nuggft.genesis()));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toEndBlock
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
}
