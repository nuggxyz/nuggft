// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

import '../../lib/DSTestExtended.sol';

contract requireTest is DSTestExtended {
    // winner
    function test_normal_pass() public {
        require(900 < 1000, 'MESSAGE');
    }

    function test_ass_pass() public {
        // require(900 < 1000, 'MESSAGE');
        assembly {
            if iszero(lt(900, 1000)) {
                revert(0x00, 0x00)
            }
        }
    }
}
