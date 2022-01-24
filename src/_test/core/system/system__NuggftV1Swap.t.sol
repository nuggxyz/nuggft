// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';

contract system__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    function setUp() public {
        reset();
    }
}
