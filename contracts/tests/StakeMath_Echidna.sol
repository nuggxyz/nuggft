// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '../src/libraries/StakeMath.sol';
import '../src/libraries/QuadMath.sol';
import './QuadMath_Echidna.sol';

contract StakeMath_Echidna {
    // using StakeMath for StakeMath.State;
    using QuadMath for uint256;

    // function checkToRewardFromEps(
    //     uint256 a,
    //     uint256 b,
    //     uint8 c,
    //     uint256 d,
    //     uint256 e
    // ) external pure {
    //     uint256 shares = a;
    //     uint256 epsX128 = b;
    //     uint8 sharesPercent = c;
    //     uint256 earnings = d;
    //     uint256 amount = e;

    //     StakeMath.State memory state = StakeMath.State({shares: shares, epsX128: epsX128});
    //     StakeMath.Position memory pos = StakeMath.Position({shares: shares.percent(c % 100), earnings: earnings});

    //     uint256 z = state.convertSharesToEarnings(pos, amount);
    //     if (x == 0 || y == 0) {
    //         assert(z == 0);
    //         return;
    //     }
    //     uint256 d = QuadMath._BINARY128;
    //     // recompute x and y via mulDiv of the result of floor(x*y/d), should always be less than original inputs by < d
    //     uint256 x2 = QuadMath.mulDiv(z, d, y);
    //     uint256 y2 = QuadMath.mulDiv(z, d, x);
    //     assert(x2 >= x);
    //     assert(y2 >= y);
    //     assert(x2 - x < d);
    //     assert(y2 - y < d);
    // }

    // function checkToEpsFromSupply(uint256 x, uint256 d) external pure {
    //     require(d > 0);
    //     uint256 z = StakeMath.toEpsX128FromShares(x, d);
    //     if (x == 0) {
    //         assert(z == 0);
    //         return;
    //     }
    //     uint256 y = QuadMath._BINARY128;
    //     // recompute x and y via mulDiv of the result of floor(x*y/d), should always be less than original inputs by < d
    //     uint256 x2 = QuadMath.mulDiv(z, d, y);
    //     uint256 y2 = QuadMath.mulDiv(z, d, x);
    //     assert(x2 <= x);
    //     assert(y2 <= y);
    //     assert(x - x2 < d);
    //     assert(y - y2 < d);
    // }
}
