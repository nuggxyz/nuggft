// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';

import {NuggftV1Epoch} from '../../core/NuggftV1Epoch.sol';

contract general__NuggftV1Epoch is NuggftV1Test, NuggftV1Epoch {
    using UserTarget for address;

    function setUp() public {
        reset();
        // fvm.roll(13952818);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toEpoch
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function safe__toEpoch(uint32 blocknum, uint256 gen) internal pure returns (uint32 res) {
        res = (uint32(blocknum - gen) / INTERVAL) + OFFSET;
    }

    function test__general__NuggftV1Epoch__toEpoch__symbolic(uint32 blocknum, uint256 gen) public {
        if (blocknum < gen) return;

        assertEq(
            toEpoch(blocknum, gen), //
            safe__toEpoch(blocknum, gen),
            'toEpoch: real != safe'
        );
    }

    function test__general__NuggftV1Epoch__toEpoch__gas() public view {
        toEpoch(uint32(block.number), genesis);
    }

    function test__general__NuggftV1Epoch__toEpoch__gas__safe() public view {
        safe__toEpoch(uint32(block.number), genesis);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toStartBlock
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function safe__toStartBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        res = uint256(uint256(_epoch - OFFSET) * INTERVAL) + gen;
    }

    function test__general__NuggftV1Epoch__toStartBlock__symbolic(uint32 _epoch, uint32 gen) public {
        uint24 epoch = uint24(_epoch);

        if (_epoch < OFFSET || _epoch > 5000000) return;
        if (gen < 1000000) return;

        if (gen == 0) return;
        if (epoch == 0) return;

        uint256 got = toStartBlock(epoch, gen);
        uint256 exp = safe__toStartBlock(epoch, gen);

        assertEq(got, exp, 'toStartBlock: real != safe');
    }

    function test__general__NuggftV1Epoch__toStartBlock__gas() public view {
        toStartBlock(OFFSET + 100, genesis);
    }

    function test__general__NuggftV1Epoch__toStartBlock__gas__safe() public view {
        safe__toStartBlock(OFFSET + 100, genesis);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toEndBlock
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function safe__toEndBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        res = safe__toStartBlock(_epoch + 1, gen) - 1;
    }

    function semisafe__toEndBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        res = toStartBlock(_epoch + 1, gen) - 1;
    }

    function test__general__NuggftV1Epoch__toEndBlock__symbolic(uint32 _epoch, uint32 gen) public {
        uint24 epoch = uint24(_epoch);

        if (_epoch < OFFSET || _epoch > 1000000) return;
        if (gen < 1000000) return;

        if (gen == 0) return;
        if (epoch == 0) return;

        uint256 got = toEndBlock(epoch, gen);
        uint256 exp = safe__toEndBlock(epoch, gen);

        assertEq(got, exp, 'toEndBlock: real != safe');
    }

    function test__general__NuggftV1Epoch__toEndBlock__gas() public view {
        toEndBlock(OFFSET + 100, genesis);
    }

    function test__general__NuggftV1Epoch__toEndBlock__gas__safe() public view {
        safe__toEndBlock(OFFSET + 100, genesis);
    }

    function test__general__NuggftV1Epoch__toEndBlock__gas__semisafe() public view {
        semisafe__toEndBlock(OFFSET + 100, genesis);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toEndBlock
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
}
