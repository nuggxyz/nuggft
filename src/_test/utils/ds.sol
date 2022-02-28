// SPDX-License-Identifier: GPL-3.0-or-later

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.8.12;

import './vm.sol';
import './stdlib.sol';
import './global.sol';
import './cast.sol';
import './injector.sol';

library ds {
    bytes32 constant DS_TEST_SET_ON_FAIL = 0x0000000000000000000000000000000000000000000000000000000000000101;

    bytes32 constant SLOT_0 = 0x0000000000000000000000000000000000000000000000000000000000000000;
    Injector constant inject = Injector(address(uint160(12345)));

    bytes4 constant INJECT_LOG = 0xb60e72cc; //'log(string,uint256)'

    function getDsTest() private returns (address a) {
        a = global.getAddressSafe('DsTest');
    }

    function setDsTest(address addr) internal {
        global.set('DsTest', addr);
        forge.vm.etch(address(inject), address(new Injector()).code);
    }

    function fail() internal {
        forge.vm.store(getDsTest(), SLOT_0, DS_TEST_SET_ON_FAIL);
        // revert();
    }

    function fail(bytes32 err) internal {
        emit log_named_string('Error', string(abi.encodePacked(err)));
        fail();
    }

    function assertFalse(bool data) internal {
        assertTrue(!data);
    }

    function assertBalance(
        address user,
        int192 expectedBalance,
        string memory str
    ) internal {
        assertBalance(user, cast.u256(expectedBalance), str);
    }

    function assertBalance(
        address user,
        uint256 expectedBalance,
        string memory str
    ) internal {
        if (expectedBalance < 0) {
            emit log('Error: assertBalance - expectedBalance < 0');
            emit log(str);
            emit log_named_address('user: ', user);
            emit log_named_uint('  Expected', expectedBalance);
            fail();
        }
        if (user.balance != uint256(int256(expectedBalance))) {
            emit log('Error: assertBalance - user.balance != expectedBalance');
            emit log(str);

            emit log_named_address('user: ', user);
            emit log_named_uint('  Expected', expectedBalance);
            emit log_named_uint('    Actual', user.balance);
            fail();
        }
    }

    function assertBytesEq(bytes memory a, bytes memory b) internal {
        if (keccak256(a) != keccak256(b)) {
            emit log('Error: a == b not satisfied [bytes]');
            emit log_named_bytes('  Expected', b);
            emit log_named_bytes('    Actual', a);
            fail();
        }
    }

    event log(string);
    event logs(bytes);

    event log_address(address);
    event log_bytes32(bytes32);
    event log_int(int256);
    event log_uint(uint256);
    event log_bytes(bytes);
    event log_string(string);

    event log_named_address(string key, address val);
    event log_named_bytes32(string key, bytes32 val);
    event log_named_decimal_int(string key, int256 val, uint256 decimals);
    event log_named_decimal_uint(string key, uint256 val, uint256 decimals);
    event log_named_int(string key, int256 val);
    event log_named_uint(string key, uint256 val);
    event log_named_bytes(string key, bytes val);
    event log_named_string(string key, string val);

    function emit_log(string memory v) internal {
        emit log(v);
    }

    function emit_logs(bytes memory v) internal {
        emit logs(v);
    }

    function emit_log_address(address v) internal {
        emit log_address(v);
    }

    function emit_log_bytes32(bytes32 v) internal {
        emit log_bytes32(v);
    }

    function emit_log_int(int256 v) internal {
        emit log_int(v);
    }

    function emit_log_uint(uint256 v) internal {
        emit log_uint(v);
    }

    function emit_log_bytes(bytes memory v) internal {
        emit log_bytes(v);
    }

    function emit_log_string(string memory v) internal {
        emit log_string(v);
    }

    function emit_log_named_address(string memory key, address val) internal {
        emit log_named_address(key, val);
    }

    function emit_log_named_bytes32(string memory key, bytes32 val) internal {
        emit log_named_bytes32(key, val);
    }

    function emit_log_named_decimal_int(
        string memory key,
        int256 val,
        uint256 decimals
    ) internal {
        emit log_named_decimal_int(key, val, decimals);
    }

    function emit_log_named_decimal_uint(
        string memory key,
        uint256 val,
        uint256 decimals
    ) internal {
        emit log_named_decimal_uint(key, val, decimals);
    }

    function emit_log_named_int(string memory key, int256 val) internal {
        emit log_named_int(key, val);
    }

    function emit_log_named_uint(string memory key, uint256 val) internal {
        emit log_named_uint(key, val);
    }

    function emit_log_named_bytes(string memory key, bytes memory val) internal {
        emit log_named_bytes(key, val);
    }

    function emit_log_named_string(string memory key, string memory val) internal {
        emit log_named_string(key, val);
    }

    function assertTrue(bool condition) internal {
        if (!condition) {
            emit log('Error: Assertion Failed');
            fail();
        }
    }

    function assertTrue(bool condition, string memory err) internal {
        if (!condition) {
            emit log_named_string('Error', err);
            assertTrue(condition);
        }
    }

    function assertEq(address a, address b) internal {
        if (a != b) {
            emit log('Error: a == b not satisfied [address]');
            emit log_named_address('  Expected', b);
            emit log_named_address('    Actual', a);
            fail();
        }
    }

    function assertEq(
        address a,
        address b,
        string memory err
    ) internal {
        if (a != b) {
            emit log_named_string('Error', err);
            assertEq(a, b);
        }
    }

    function assertEq(bytes32 a, bytes32 b) internal {
        if (a != b) {
            emit log('Error: a == b not satisfied [bytes32]');
            emit log_named_bytes32('  Expected', b);
            emit log_named_bytes32('    Actual', a);
            fail();
        }
    }

    function assertEq(
        bytes32 a,
        bytes32 b,
        string memory err
    ) internal {
        if (a != b) {
            emit log_named_string('Error', err);
            assertEq(a, b);
        }
    }

    function assertEq32(bytes32 a, bytes32 b) internal {
        assertEq(a, b);
    }

    function assertEq32(
        bytes32 a,
        bytes32 b,
        string memory err
    ) internal {
        assertEq(a, b, err);
    }

    function assertEq(int256 a, int256 b) internal {
        if (a != b) {
            emit log('Error: a == b not satisfied [int]');
            emit log_named_int('  Expected', b);
            emit log_named_int('    Actual', a);
            fail();
        }
    }

    function assertEq(
        int256 a,
        int256 b,
        string memory err
    ) internal {
        if (a != b) {
            emit log_named_string('Error', err);
            assertEq(a, b);
        }
    }

    function assertEq(uint256 a, uint256 b) internal {
        if (a != b) {
            emit log('Error: a == b not satisfied [uint]');
            emit log_named_uint('  Expected', b);
            emit log_named_uint('    Actual', a);
            fail();
        }
    }

    function assertEq(
        uint256 a,
        uint256 b,
        string memory err
    ) internal {
        if (a != b) {
            emit log_named_string('Error', err);
            assertEq(a, b);
        }
    }

    function assertEqDecimal(
        int256 a,
        int256 b,
        uint256 decimals
    ) internal {
        if (a != b) {
            emit log('Error: a == b not satisfied [decimal int]');
            emit log_named_decimal_int('  Expected', b, decimals);
            emit log_named_decimal_int('    Actual', a, decimals);
            fail();
        }
    }

    function assertEqDecimal(
        int256 a,
        int256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a != b) {
            emit log_named_string('Error', err);
            assertEqDecimal(a, b, decimals);
        }
    }

    function assertEqDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals
    ) internal {
        if (a != b) {
            emit log('Error: a == b not satisfied [decimal uint]');
            emit log_named_decimal_uint('  Expected', b, decimals);
            emit log_named_decimal_uint('    Actual', a, decimals);
            fail();
        }
    }

    function assertEqDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a != b) {
            emit log_named_string('Error', err);
            assertEqDecimal(a, b, decimals);
        }
    }

    function assertGt(uint256 a, uint256 b) internal {
        if (a <= b) {
            emit log('Error: a > b not satisfied [uint]');
            emit log_named_uint('  Value a', a);
            emit log_named_uint('  Value b', b);
            fail();
        }
    }

    function assertGt(
        uint256 a,
        uint256 b,
        string memory err
    ) internal {
        if (a <= b) {
            emit log_named_string('Error', err);
            assertGt(a, b);
        }
    }

    function assertGt(int256 a, int256 b) internal {
        if (a <= b) {
            emit log('Error: a > b not satisfied [int]');
            emit log_named_int('  Value a', a);
            emit log_named_int('  Value b', b);
            fail();
        }
    }

    function assertGt(
        int256 a,
        int256 b,
        string memory err
    ) internal {
        if (a <= b) {
            emit log_named_string('Error', err);
            assertGt(a, b);
        }
    }

    // function assertGtDecimal(
    //     int256 a,
    //     int256 b,
    //     uint256 decimals
    // ) internal {
    //     if (a <= b) {
    //         emit log('Error: a > b not satisfied [decimal int]');
    //         emit log_named_decimal_int('  Value a', a, decimals);
    //         emit log_named_decimal_int('  Value b', b, decimals);
    //         fail();
    //     }
    // }

    // function assertGtDecimal(
    //     int256 a,
    //     int256 b,
    //     uint256 decimals,
    //     string memory err
    // ) internal {
    //     if (a <= b) {
    //         emit log_named_string('Error', err);
    //         assertGtDecimal(a, b, decimals);
    //     }
    // }

    // function assertGtDecimal(
    //     uint256 a,
    //     uint256 b,
    //     uint256 decimals
    // ) internal {
    //     if (a <= b) {
    //         emit log('Error: a > b not satisfied [decimal uint]');
    //         emit log_named_decimal_uint('  Value a', a, decimals);
    //         emit log_named_decimal_uint('  Value b', b, decimals);
    //         fail();
    //     }
    // }

    // function assertGtDecimal(
    //     uint256 a,
    //     uint256 b,
    //     uint256 decimals,
    //     string memory err
    // ) internal {
    //     if (a <= b) {
    //         emit log_named_string('Error', err);
    //         assertGtDecimal(a, b, decimals);
    //     }
    // }

    function assertGe(uint256 a, uint256 b) internal {
        if (a < b) {
            emit log('Error: a >= b not satisfied [uint]');
            emit log_named_uint('  Value a', a);
            emit log_named_uint('  Value b', b);
            fail();
        }
    }

    function assertGe(
        uint256 a,
        uint256 b,
        string memory err
    ) internal {
        if (a < b) {
            emit log_named_string('Error', err);
            assertGe(a, b);
        }
    }

    function assertGe(int256 a, int256 b) internal {
        if (a < b) {
            emit log('Error: a >= b not satisfied [int]');
            emit log_named_int('  Value a', a);
            emit log_named_int('  Value b', b);
            fail();
        }
    }

    function assertGe(
        int256 a,
        int256 b,
        string memory err
    ) internal {
        if (a < b) {
            emit log_named_string('Error', err);
            assertGe(a, b);
        }
    }

    // function assertGeDecimal(
    //     int256 a,
    //     int256 b,
    //     uint256 decimals
    // ) internal {
    //     if (a < b) {
    //         emit log('Error: a >= b not satisfied [decimal int]');
    //         emit log_named_decimal_int('  Value a', a, decimals);
    //         emit log_named_decimal_int('  Value b', b, decimals);
    //         fail();
    //     }
    // }

    // function assertGeDecimal(
    //     int256 a,
    //     int256 b,
    //     uint256 decimals,
    //     string memory err
    // ) internal {
    //     if (a < b) {
    //         emit log_named_string('Error', err);
    //         assertGeDecimal(a, b, decimals);
    //     }
    // }

    // function assertGeDecimal(
    //     uint256 a,
    //     uint256 b,
    //     uint256 decimals
    // ) internal {
    //     if (a < b) {
    //         emit log('Error: a >= b not satisfied [decimal uint]');
    //         emit log_named_decimal_uint('  Value a', a, decimals);
    //         emit log_named_decimal_uint('  Value b', b, decimals);
    //         fail();
    //     }
    // }

    // function assertGeDecimal(
    //     uint256 a,
    //     uint256 b,
    //     uint256 decimals,
    //     string memory err
    // ) internal {
    //     if (a < b) {
    //         emit log_named_string('Error', err);
    //         assertGeDecimal(a, b, decimals);
    //     }
    // }

    function assertLt(uint256 a, uint256 b) internal {
        if (a >= b) {
            emit log('Error: a < b not satisfied [uint]');
            emit log_named_uint('  Value a', a);
            emit log_named_uint('  Value b', b);
            fail();
        }
    }

    function assertLt(
        uint256 a,
        uint256 b,
        string memory err
    ) internal {
        if (a >= b) {
            emit log_named_string('Error', err);
            assertLt(a, b);
        }
    }

    function assertLt(int256 a, int256 b) internal {
        if (a >= b) {
            emit log('Error: a < b not satisfied [int]');
            emit log_named_int('  Value a', a);
            emit log_named_int('  Value b', b);
            fail();
        }
    }

    function assertLt(
        int256 a,
        int256 b,
        string memory err
    ) internal {
        if (a >= b) {
            emit log_named_string('Error', err);
            assertLt(a, b);
        }
    }

    // function assertLtDecimal(
    //     int256 a,
    //     int256 b,
    //     uint256 decimals
    // ) internal {
    //     if (a >= b) {
    //         emit log('Error: a < b not satisfied [decimal int]');
    //         emit log_named_decimal_int('  Value a', a, decimals);
    //         emit log_named_decimal_int('  Value b', b, decimals);
    //         fail();
    //     }
    // }

    // function assertLtDecimal(
    //     int256 a,
    //     int256 b,
    //     uint256 decimals,
    //     string memory err
    // ) internal {
    //     if (a >= b) {
    //         emit log_named_string('Error', err);
    //         assertLtDecimal(a, b, decimals);
    //     }
    // }

    // function assertLtDecimal(
    //     uint256 a,
    //     uint256 b,
    //     uint256 decimals
    // ) internal {
    //     if (a >= b) {
    //         emit log('Error: a < b not satisfied [decimal uint]');
    //         emit log_named_decimal_uint('  Value a', a, decimals);
    //         emit log_named_decimal_uint('  Value b', b, decimals);
    //         fail();
    //     }
    // }

    // function assertLtDecimal(
    //     uint256 a,
    //     uint256 b,
    //     uint256 decimals,
    //     string memory err
    // ) internal {
    //     if (a >= b) {
    //         emit log_named_string('Error', err);
    //         assertLtDecimal(a, b, decimals);
    //     }
    // }

    function assertLe(uint256 a, uint256 b) internal {
        if (a > b) {
            emit log('Error: a <= b not satisfied [uint]');
            emit log_named_uint('  Value a', a);
            emit log_named_uint('  Value b', b);
            fail();
        }
    }

    function assertLe(
        uint256 a,
        uint256 b,
        string memory err
    ) internal {
        if (a > b) {
            emit log_named_string('Error', err);
            assertLe(a, b);
        }
    }

    function assertLe(int256 a, int256 b) internal {
        if (a > b) {
            emit log('Error: a <= b not satisfied [int]');
            emit log_named_int('  Value a', a);
            emit log_named_int('  Value b', b);
            fail();
        }
    }

    function assertLe(
        int256 a,
        int256 b,
        string memory err
    ) internal {
        if (a > b) {
            emit log_named_string('Error', err);
            assertLe(a, b);
        }
    }

    // function assertLeDecimal(
    //     int256 a,
    //     int256 b,
    //     uint256 decimals
    // ) internal {
    //     if (a > b) {
    //         emit log('Error: a <= b not satisfied [decimal int]');
    //         emit log_named_decimal_int('  Value a', a, decimals);
    //         emit log_named_decimal_int('  Value b', b, decimals);
    //         fail();
    //     }
    // }

    // function assertLeDecimal(
    //     int256 a,
    //     int256 b,
    //     uint256 decimals,
    //     string memory err
    // ) internal {
    //     if (a > b) {
    //         emit log_named_string('Error', err);
    //         assertLeDecimal(a, b, decimals);
    //     }
    // }

    // function assertLeDecimal(
    //     uint256 a,
    //     uint256 b,
    //     uint256 decimals
    // ) internal {
    //     if (a > b) {
    //         emit log('Error: a <= b not satisfied [decimal uint]');
    //         emit log_named_decimal_uint('  Value a', a, decimals);
    //         emit log_named_decimal_uint('  Value b', b, decimals);
    //         fail();
    //     }
    // }

    // function assertLeDecimal(
    //     uint256 a,
    //     uint256 b,
    //     uint256 decimals,
    //     string memory err
    // ) internal {
    //     if (a > b) {
    //         emit log_named_string('Error', err);
    //         assertGeDecimal(a, b, decimals);
    //     }
    // }

    function assertEq(string memory a, string memory b) internal {
        if (keccak256(abi.encodePacked(a)) != keccak256(abi.encodePacked(b))) {
            emit log('Error: a == b not satisfied [string]');
            emit log_named_string('  Value a', a);
            emit log_named_string('  Value b', b);
            fail();
        }
    }

    function assertEq(
        string memory a,
        string memory b,
        string memory err
    ) internal {
        if (keccak256(abi.encodePacked(a)) != keccak256(abi.encodePacked(b))) {
            emit log_named_string('Error', err);
            assertEq(a, b);
        }
    }

    function checkEq0(bytes memory a, bytes memory b) internal pure returns (bool ok) {
        ok = true;
        if (a.length == b.length) {
            for (uint256 i = 0; i < a.length; i++) {
                if (a[i] != b[i]) {
                    ok = false;
                }
            }
        } else {
            ok = false;
        }
    }

    function assertEq0(bytes memory a, bytes memory b) internal {
        if (!checkEq0(a, b)) {
            emit log('Error: a == b not satisfied [bytes]');
            emit log_named_bytes('  Expected', a);
            emit log_named_bytes('    Actual', b);
            fail();
        }
    }

    function assertEq0(
        bytes memory a,
        bytes memory b,
        string memory err
    ) internal {
        if (!checkEq0(a, b)) {
            emit log_named_string('Error', err);
            assertEq0(a, b);
        }
    }
}
