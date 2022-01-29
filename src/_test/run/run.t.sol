// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

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
