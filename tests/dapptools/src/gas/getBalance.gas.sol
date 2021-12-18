// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.9;

import '../../lib/DSTestExtended.sol';

contract NuggETHLogicTest is DSTestExtended {
    uint256 internal _supply = 1;

    function test_readAndSetState() public {
        uint256 tmp = _supply;

        tmp += 20;

        _supply = tmp;
    }

    function test_readBalanceAssembly() public view {
        uint256 tmp;
        assembly {
            tmp := selfbalance()
        }
        tmp += 20;
    }

    function test_readBalance() public view {
        uint256 tmp = address(this).balance;
        tmp += 20;
    }
}
