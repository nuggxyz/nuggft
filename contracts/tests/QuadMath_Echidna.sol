// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '../src/libraries/QuadMath.sol';

contract QuadMath_Echidna {
    function checkMulDivRounding(
        uint256 x,
        uint256 y,
        uint256 d
    ) public pure {
        require(d > 0);

        uint256 ceiled = QuadMath.mulDivRoundingUp(x, y, d);
        uint256 floored = QuadMath.mulDiv(x, y, d);

        if (mulmod(x, y, d) > 0) {
            assert(ceiled - floored == 1);
        } else {
            assert(ceiled == floored);
        }
    }

    function checkMulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) public pure {
        require(d > 0);
        uint256 z = QuadMath.mulDiv(x, y, d);
        if (x == 0 || y == 0) {
            assert(z == 0);
            return;
        }

        // recompute x and y via mulDiv of the result of floor(x*y/d), should always be less than original inputs by < d
        uint256 x2 = QuadMath.mulDiv(z, d, y);
        uint256 y2 = QuadMath.mulDiv(z, d, x);
        assert(x2 <= x);
        assert(y2 <= y);

        assert(x - x2 < d);
        assert(y - y2 < d);
    }

    function checkMulDivRoundingUp(
        uint256 x,
        uint256 y,
        uint256 d
    ) public pure {
        require(d > 0);
        uint256 z = QuadMath.mulDivRoundingUp(x, y, d);
        if (x == 0 || y == 0) {
            assert(z == 0);
            return;
        }

        // recompute x and y via mulDiv of the result of floor(x*y/d), should always be less than original inputs by < d
        uint256 x2 = QuadMath.mulDiv(z, d, y);
        uint256 y2 = QuadMath.mulDiv(z, d, x);
        assert(x2 >= x);
        assert(y2 >= y);

        assert(x2 - x < d);
        assert(y2 - y < d);
    }
}
