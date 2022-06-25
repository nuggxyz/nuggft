// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "../../NuggftV1.test.sol";

contract sim__release is NuggftV1Test {
    function setUp() public {}

    function test__sim__release__A() public {
        resetManual(dub6ix, 1 ether);

        for (uint24 i = 0; i < 2; i++) {
            mintHelper(mintable(i), users.mac, nuggft.msp());
        }

        ds.emit_log_named_decimal_uint("msp    ", nuggft.msp(), 18);

        ds.emit_log_named_decimal_uint("eps    ", nuggft.eps(), 18);

        ds.emit_log_named_decimal_uint("proto  ", nuggft.proto(), 18);

        ds.emit_log_named_decimal_uint("staked ", nuggft.staked(), 18);

        // nuggft.minSharePriceBreakdown();

        uint256 a = 1010500000000000000;
        uint256 b = 101;

        uint256 c = a / b;

        ds.emit_log_uint(c);
    }
}
