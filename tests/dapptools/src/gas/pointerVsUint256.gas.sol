// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

import '../../lib/DSTestExtended.sol';

contract pointerVsUint256 is DSTestExtended {
    struct Pointer {
        uint256 value;
    }

    function test_struct() public {
        Pointer memory p = Pointer(43);
        // p.value = 43;

        add10(p);

        assertEq(p.value, 53);
    }

    function test_uint256() public {
        uint256 p = 43;

        p = add10(p);

        assertEq(p, 53);
    }

    function add10(uint256 val) internal pure returns (uint256 res) {
        res = val + 10;
    }

    function add10(Pointer memory ref) internal pure {
        ref.value += 10;
    }
}
