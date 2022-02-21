// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import '../utils/forge.sol';

contract runner {
    mapping(uint160 => uint256) tokens;

    function run() external {
        forge.vm.load(address(this), 0x00);
        forge.vm.record();

        tokens[2245] = 0x00001;

        forge.vm.accesses(address(this));
    }
}
