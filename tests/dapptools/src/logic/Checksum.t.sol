// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTest.sol';
import '../../../contracts/interfaces/IDotNugg.sol';
import '../../../contracts/libraries/Checksum.sol';
import '../../../contracts/libraries/Bytes.sol';

contract ChecksumTest is DSTest {
    function test_fletcher16() public {
        bytes
            memory sample1 = hex'050010001a003100000000990000eae1991105090500000705140a112211041102122012021f1f1313060a0600000705160a1809122212041101142014011f1f17';

        bytes memory want1 = hex'0613';

        uint16 res = Checksum.fletcher16(sample1);

        uint16 want = Bytes.toUint16(want1, 0);

        assertEq(res, want);
    }
}
