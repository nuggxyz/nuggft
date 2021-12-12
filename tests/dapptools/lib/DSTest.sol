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

pragma solidity >=0.4.23;

// import '../../contracts/interfaces/IDotNugg.sol';

contract DSTest {
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

    bool public IS_TEST = true;
    bool public failed;

    address constant HEVM_ADDRESS = address(bytes20(uint160(uint256(keccak256('hevm cheat code')))));

    modifier mayRevert() {
        _;
    }
    modifier testopts(string memory) {
        _;
    }

    function fail() internal {
        failed = true;
    }

    modifier logs_gas() {
        uint256 startGas = gasleft();
        _;
        uint256 endGas = gasleft();
        emit log_named_uint('gas', startGas - endGas);
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

    // IDOTNUGG EQ ASSERTS

    // function assertEq(IDotNugg.Matrix memory m1, IDotNugg.Matrix memory m2) internal  {
    //     if (m1.init != m2.init
    //     || m1.width != m2.width
    //     || m1.currentUnsetX != m2.currentUnsetX
    //     || m1.currentUnsetY != m2.currentUnsetY
    //     || m1.startX != m2.startX
    //     || m1.data.length != m2.data.length
    //     || m1.data[0].length != m2.data[0].length) {
    //         emit log("Matrices are not equal");
    //         fail();
    //     }
    //     for (uint16 i = 0; i < m1.data.length; i++) {
    //         for (uint16 j = 0; j < m1.data[0].length; j++) {
    //             assertEq(m1.data[i][j], m2.data[i][j]);
    //         }
    //     }
    // }

    // function assertEq(IDotNugg.Pixel memory p1, IDotNugg.Pixel memory p2) internal  {
    //     assertEq(p1.rgba, p2.rgba);
    //     if (p1.zindex != p2.zindex
    //     || p1.exists != p2.exists) {
    //          emit log("Pixels are not equal");
    //         fail();
    //     }
    // }

    // function assertEq(IDotNugg.Rgba memory r1, IDotNugg.Rgba memory r2) internal  {
    //     if (r1.r != r2.r
    //     || r1.g != r2.g
    //     || r1.b != r2.b
    //     || r1.a != r2.a) {
    //         emit log("RGBAs are not equal");
    //         fail();
    //     }
    // }

    // function assertEq(IDotNugg.Rlud memory r1, IDotNugg.Rlud memory r2) internal  {
    //     if (r1.r != r2.r
    //     || r1.l != r2.l
    //     || r1.u != r2.u
    //     || r1.d != r2.d) {
    //         emit log("RLUDs are not equal");
    //         fail();
    //     }
    // }

    // function assertEq(IDotNugg.Coordinate memory c1, IDotNugg.Coordinate memory c2) internal  {
    //     if (c1.a != c2.a
    //     || c1.b != c2.b) {
    //         emit log("Coordinates are not equal");
    //         fail();
    //     }
    // }

    // function assertEq(IDotNugg.Anchor memory a1, IDotNugg.Anchor memory a2) internal  {
    //     assertEq(a1.coordinate, a2.coordinate);
    //     assertEq(a1.radii, a2.radii);
    // }

    // function assertEq(IDotNugg.Version memory v1, IDotNugg.Version memory v2) internal  {
    //     if (v1.width != v2.width
    //     || v1.calculatedReceivers.length != v2.calculatedReceivers.length
    //     || v1.staticReceivers.length != v2.staticReceivers.length
    //     || v1.data.length != v2.data.length) {
    //         emit log("Coordinates are not equal");
    //         fail();
    //     }
    //     assertEq(v1.data, v2.data);
    //     assertEq(v1.anchor, v2.anchor);
    //     assertEq(v1.expanders, v2.expanders);
    //     for (uint8 i = 0; i < v1.calculatedReceivers.length; i++) {
    //         assertEq(v1.calculatedReceivers[i], v2.calculatedReceivers[i]);
    //     }
    //     for (uint8 i = 0; i < v1.staticReceivers.length; i++) {
    //         assertEq(v1.staticReceivers[i], v2.staticReceivers[i]);
    //     }
    // }

    // // ┌─────────────────────────────────────────────────┐
    // // │                                                 │
    // // │                                                 │
    // // │                                                 │
    // // │         _____                                   │
    // // │        /  __ \                                  │
    // // │        | /  \/ __ _ _ ____   ____ _ ___         │
    // // │        | |    / _` | '_ \ \ / / _` / __|        │
    // // │        | \__/\ (_| | | | \ V / (_| \__ \        │
    // // │         \____/\__,_|_| |_|\_/ \__,_|___/        │
    // // │                                                 │
    // // │                                                 │
    // // │                                                 │
    // // │                                                 │
    // // └─────────────────────────────────────────────────┘

    //     function assertEq(IDotNugg.Canvas memory c1, IDotNugg.Canvas memory c2) internal  {
    //         if (c1.receivers.length != c2.receivers.length) {
    //             emit log("Canvases are not equal");
    //             fail();
    //         }
    //         assertEq(c1.matrix, c2.matrix);
    //         for (uint8 i = 0; i < c1.receivers.length; i++) {
    //             assertEq(c1.receivers[i], c2.receivers[i]);
    //         }
    //     }

    //     function assertEq(IDotNugg.Mix memory m1, IDotNugg.Mix memory m2) internal  {
    //         if (m1.feature != m2.feature) {
    //             emit log("Mixes are not equal");
    //             fail();
    //         }
    //         assertEq(m1.version, m2.version);
    //         assertEq(m1.matrix, m2.matrix);
    //     }

    //     function assertEq(IDotNugg.Item memory i1, IDotNugg.Item memory i2) internal  {
    //         if (i1.feature != i2.feature
    //         || i1.pallet.length != i2.pallet.length
    //         || i1.versions.length != i2.versions.length) {
    //             emit log("Items are not equal");
    //             fail();
    //         }
    //         for (uint8 i = 0; i < i1.pallet.length; i++) {
    //             assertEq(i1.pallet[i], i2.pallet[i]);
    //         }
    //         for (uint8 i = 0; i < i1.versions.length; i++) {
    //             assertEq(i1.versions[i], i2.versions[i]);
    //         }
    //     }

    //     function assertEq(IDotNugg.Collection memory c1, IDotNugg.Collection memory c2) internal  {
    //         if (c1.width != c2.width
    //         || c1.height != c2.height
    //         || c1.numFeatures != c2.numFeatures
    //         || c1.defaults.length != c2.defaults.length) {
    //             emit log("Collections are not equal");
    //             fail();
    //         }
    //         for (uint8 i = 0; i < c1.defaults.length; i++) {
    //             assertEq(c1.defaults[i], c2.defaults[i]);
    //         }
    //     }
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

    function assertEq(bytes memory a, bytes memory b) internal {
        if (a.length != b.length) {
            emit log('Error: a == b not satisfied [bytes]');
            fail();
        }
        for (uint8 i = 0; i < a.length; i++) {
            assertEq(a[i], b[i]);
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

    function assertGtDecimal(
        int256 a,
        int256 b,
        uint256 decimals
    ) internal {
        if (a <= b) {
            emit log('Error: a > b not satisfied [decimal int]');
            emit log_named_decimal_int('  Value a', a, decimals);
            emit log_named_decimal_int('  Value b', b, decimals);
            fail();
        }
    }

    function assertGtDecimal(
        int256 a,
        int256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a <= b) {
            emit log_named_string('Error', err);
            assertGtDecimal(a, b, decimals);
        }
    }

    function assertGtDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals
    ) internal {
        if (a <= b) {
            emit log('Error: a > b not satisfied [decimal uint]');
            emit log_named_decimal_uint('  Value a', a, decimals);
            emit log_named_decimal_uint('  Value b', b, decimals);
            fail();
        }
    }

    function assertGtDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a <= b) {
            emit log_named_string('Error', err);
            assertGtDecimal(a, b, decimals);
        }
    }

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

    function assertGeDecimal(
        int256 a,
        int256 b,
        uint256 decimals
    ) internal {
        if (a < b) {
            emit log('Error: a >= b not satisfied [decimal int]');
            emit log_named_decimal_int('  Value a', a, decimals);
            emit log_named_decimal_int('  Value b', b, decimals);
            fail();
        }
    }

    function assertGeDecimal(
        int256 a,
        int256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a < b) {
            emit log_named_string('Error', err);
            assertGeDecimal(a, b, decimals);
        }
    }

    function assertGeDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals
    ) internal {
        if (a < b) {
            emit log('Error: a >= b not satisfied [decimal uint]');
            emit log_named_decimal_uint('  Value a', a, decimals);
            emit log_named_decimal_uint('  Value b', b, decimals);
            fail();
        }
    }

    function assertGeDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a < b) {
            emit log_named_string('Error', err);
            assertGeDecimal(a, b, decimals);
        }
    }

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

    function assertLtDecimal(
        int256 a,
        int256 b,
        uint256 decimals
    ) internal {
        if (a >= b) {
            emit log('Error: a < b not satisfied [decimal int]');
            emit log_named_decimal_int('  Value a', a, decimals);
            emit log_named_decimal_int('  Value b', b, decimals);
            fail();
        }
    }

    function assertLtDecimal(
        int256 a,
        int256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a >= b) {
            emit log_named_string('Error', err);
            assertLtDecimal(a, b, decimals);
        }
    }

    function assertLtDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals
    ) internal {
        if (a >= b) {
            emit log('Error: a < b not satisfied [decimal uint]');
            emit log_named_decimal_uint('  Value a', a, decimals);
            emit log_named_decimal_uint('  Value b', b, decimals);
            fail();
        }
    }

    function assertLtDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a >= b) {
            emit log_named_string('Error', err);
            assertLtDecimal(a, b, decimals);
        }
    }

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

    function assertLeDecimal(
        int256 a,
        int256 b,
        uint256 decimals
    ) internal {
        if (a > b) {
            emit log('Error: a <= b not satisfied [decimal int]');
            emit log_named_decimal_int('  Value a', a, decimals);
            emit log_named_decimal_int('  Value b', b, decimals);
            fail();
        }
    }

    function assertLeDecimal(
        int256 a,
        int256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a > b) {
            emit log_named_string('Error', err);
            assertLeDecimal(a, b, decimals);
        }
    }

    function assertLeDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals
    ) internal {
        if (a > b) {
            emit log('Error: a <= b not satisfied [decimal uint]');
            emit log_named_decimal_uint('  Value a', a, decimals);
            emit log_named_decimal_uint('  Value b', b, decimals);
            fail();
        }
    }

    function assertLeDecimal(
        uint256 a,
        uint256 b,
        uint256 decimals,
        string memory err
    ) internal {
        if (a > b) {
            emit log_named_string('Error', err);
            assertGeDecimal(a, b, decimals);
        }
    }

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
