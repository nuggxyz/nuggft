// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTest.sol';

import '../../../contracts/interfaces/IDotNugg.sol';
import '../../../contracts/logic/Matrix.sol';
import '../../../contracts/logic/Rgba.sol';

contract MatrixTest is DSTest {
    // ┌──────────────────────────────────────────────────┐
    // │                                 _                │
    // │                                | |               │
    // │       ___  __ _ _ __ ___  _ __ | | ___  ___      │
    // │      / __|/ _` | '_ ` _ \| '_ \| |/ _ \/ __|     │
    // │      \__ \ (_| | | | | | | |_) | |  __/\__ \     │
    // │      |___/\__,_|_| |_| |_| .__/|_|\___||___/     │
    // │                          | |                     │
    // │                          |_|                     │
    // │                                                  │
    // └──────────────────────────────────────────────────┘

    function sample_pallet_0() internal pure returns (IDotNugg.Pixel[] memory res) {
        res = new IDotNugg.Pixel[](2);
        res[0] = IDotNugg.Pixel({rgba: IDotNugg.Rgba({r: 1, g: 1, b: 1, a: 255}), zindex: 2, exists: true});
        res[1] = IDotNugg.Pixel({rgba: IDotNugg.Rgba({r: 255, g: 255, b: 255, a: 27}), zindex: 3, exists: true});
    }

    function sample_matrix_blank() internal pure returns (IDotNugg.Matrix memory res) {
        res = Matrix.create(33, 33);
    }

    function sample_matrix_filled() internal pure returns (IDotNugg.Matrix memory res) {
        IDotNugg.Pixel[] memory pallet = sample_pallet_0();

        res = Matrix.create(33, 33);

        res.data[0][0] = pallet[0];
        res.data[0][1] = pallet[0];
        res.data[0][2] = pallet[0];
        res.data[0][3] = pallet[0];
        res.data[0][4] = pallet[0];
        res.data[0][5] = pallet[1];
        res.data[0][6] = pallet[0];
        res.data[0][7] = pallet[0];
        res.data[0][8] = pallet[0];
        res.data[1][0] = pallet[0];
        res.data[1][1] = pallet[0];
        res.data[1][2] = pallet[1];
        res.data[1][3] = pallet[0];
        res.data[1][4] = pallet[0];
        res.data[1][5] = pallet[0];
        res.data[1][6] = pallet[0];
        res.data[1][7] = pallet[0];
        res.data[1][8] = pallet[1];

        res.width = 9;
        res.height = 2;
    }

    // ┌──────────────────────────────────────────────────┐
    // │                                                  │
    // │                                _                 │
    // │                               | |                │
    // │             ___ _ __ ___  __ _| |_ ___           │
    // │            / __| '__/ _ \/ _` | __/ _ \          │
    // │           | (__| | |  __/ (_| | ||  __/          │
    // │            \___|_|  \___|\__,_|\__\___|          │
    // │                                                  │
    // │                                                  │
    // └──────────────────────────────────────────────────┘

    struct CreateArgs {
        uint8 width;
        uint8 height;
    }

    function test_matrix_create() public {
        uint8 width = 33;
        uint8 height = 33;
        IDotNugg.Matrix memory matrix = Matrix.create(width, height);

        assertEq(width, matrix.data[0].length);
        assertEq(height, matrix.data.length);
    }

    // ┌──────────────────────────────────────────────────┐
    // │                                                  │
    // │                            _                     │
    // │                           | |                    │
    // │                   ___  ___| |_                   │
    // │                  / __|/ _ \ __|                  │
    // │                  \__ \  __/ |_                   │
    // │                  |___/\___|\__|                  │
    // │                                                  │
    // │                                                  │
    // └──────────────────────────────────────────────────┘

    struct SetArgs {
        IDotNugg.Matrix matrix;
        bytes data;
        IDotNugg.Pixel[] pallet;
        uint8 groupWidth;
    }

    function test_matrix_set() public {
        // arguments
        uint8 width = 33;
        uint8 height = 33;
        bytes memory data = hex'041004100410';
        uint8 groupWidth = 9;
        IDotNugg.Pixel[] memory pallet = new IDotNugg.Pixel[](2);
        pallet[0] = IDotNugg.Pixel({rgba: IDotNugg.Rgba({r: 1, g: 1, b: 1, a: 255}), zindex: 2, exists: true});
        pallet[1] = IDotNugg.Pixel({rgba: IDotNugg.Rgba({r: 255, g: 255, b: 255, a: 27}), zindex: 3, exists: true});

        IDotNugg.Matrix memory matrix = Matrix.create(width, height);

        Matrix.set(matrix, data, pallet, groupWidth);

        uint256 count = 0;
        for (; Matrix.next(matrix); count++) {
            emit log_named_uint('x', matrix.currentUnsetX);
            emit log_named_uint('y', matrix.currentUnsetY);
            emit log_named_string('hex:', Rgba.toAscii(Matrix.current(matrix).rgba));
            emit log_string('-----------');

            assertTrue(Matrix.current(matrix).exists);
            assertEq(matrix.currentUnsetX, count % groupWidth);
            assertEq(matrix.currentUnsetY, count / groupWidth);
        }

        assertEq(count, 18);
    }

    function test_matrix_set_1() public {
        // arguments
        uint8 width = 33;
        uint8 height = 33;
        bytes memory data = hex'041004100410';
        uint8 groupWidth = 9;
        IDotNugg.Pixel[] memory pallet = new IDotNugg.Pixel[](2);
        pallet[0] = IDotNugg.Pixel({rgba: IDotNugg.Rgba({r: 1, g: 1, b: 1, a: 255}), zindex: 2, exists: true});
        pallet[1] = IDotNugg.Pixel({rgba: IDotNugg.Rgba({r: 255, g: 255, b: 255, a: 27}), zindex: 3, exists: true});

        IDotNugg.Matrix memory want = Matrix.create(width, height);

        want.data[0][0] = pallet[0];
        want.data[0][1] = pallet[0];
        want.data[0][2] = pallet[0];
        want.data[0][3] = pallet[0];
        want.data[0][4] = pallet[0];
        want.data[0][5] = pallet[1];
        want.data[0][6] = pallet[0];
        want.data[0][7] = pallet[0];
        want.data[0][8] = pallet[0];
        want.data[1][0] = pallet[0];
        want.data[1][1] = pallet[0];
        want.data[1][2] = pallet[1];
        want.data[1][3] = pallet[0];
        want.data[1][4] = pallet[0];
        want.data[1][5] = pallet[0];
        want.data[1][6] = pallet[0];
        want.data[1][7] = pallet[0];
        want.data[1][8] = pallet[1];

        want.width = 9;
        want.height = 2;

        IDotNugg.Matrix memory got = Matrix.create(width, height);

        Matrix.set(got, data, pallet, groupWidth);

        assertEq(got, want);
    }

    // ┌──────────────────────────────────────────────────┐
    // │                                                  │
    // │                                 _                │
    // │                                | |               │
    // │              _ __ ___  ___  ___| |_              │
    // │             | '__/ _ \/ __|/ _ \ __|             │
    // │             | | |  __/\__ \  __/ |_              │
    // │             |_|  \___||___/\___|\__|             │
    // │                                                  │
    // │                                                  │
    // └──────────────────────────────────────────────────┘

    function test_matrix_reset() public {
        IDotNugg.Matrix memory want = sample_matrix_blank();

        IDotNugg.Matrix memory got = sample_matrix_filled();

        Matrix.reset(got);

        assertEq(got, want);
    }
}
