// SPDX-License-Identifier: MIT

import '../core/Epochable.sol';

pragma solidity 0.8.4;

contract Epochable_Test is Epochable {
    constructor(uint16 _interval) Epochable(_interval) {}
}
