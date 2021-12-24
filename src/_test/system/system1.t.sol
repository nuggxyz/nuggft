// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';
import {SafeCast} from '../fixtures/NuggFather.fix.sol';

contract systemTest__one is NuggFatherFix {
    using SafeCast for uint96;

    function setUp() public {
        reset();
    }

    function test__system1() public {
        address[] memory users = environmentForge2();
        emit log_named_uint('users length', users.length);

        emit log_named_uint('nuggft.activeEthPerShare()', nuggft.activeEthPerShare());
        emit log_named_uint('nuggft.totalProtocolEth()', nuggft.totalProtocolEth());
        emit log_named_uint('nuggft.totalStakedEth()', nuggft.totalStakedEth());
        emit log_named_uint('nuggft.totalStakedShares()', nuggft.totalStakedShares());
        emit log_named_uint('nuggft.minSharePrice()', nuggft.minSharePrice());

        // assert(false);
    }
}
// 918280174020444
/// simulated epoch

/// full migration

/// everyone loans

/// everyone burns

/// everyone liquidates

///

// Success: test__system1()

//   users length: 2000
//   nuggft.activeEthPerShare(): 0.016383373055966815
//   nuggft.totalProtocolEth():  7.392450086659235424
//   nuggft.totalStakedEth():   98.300238335800890640
//   nuggft.totalStakedShares(): 6000

// Success: test__system1()

//   users length: 2000
//   nuggft.activeEthPerShare():  .029822095207758643
//   nuggft.totalProtocolEth(): 10.420998798111959771
//   nuggft.totalStakedEth(): 178.932571246551862590
//   nuggft.totalStakedShares(): 6000
