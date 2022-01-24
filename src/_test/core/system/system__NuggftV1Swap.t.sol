// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';

contract system__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    function setUp() public {
        reset__system();
    }

    function test__system__frankBidsOnAToken() public {
        jump(1234);
        uint96 value = 1 gwei;
        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value}(1234);
            jump(1236);
            nuggft.claim(lib.sarr160(1234), lib.sarrAddress(users.frank));
        }

        forge.vm.stopPrank();
    }
}
