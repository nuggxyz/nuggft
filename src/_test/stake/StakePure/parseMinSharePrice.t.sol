// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakePure} from '../../../stake/StakePure.sol';

contract StakePureTest__minSharePriceBreakdown is t {
    function test__StakePure__minSharePriceBreakdown__a(
        uint80 stakedEth,
        uint16 stakedShares,
        uint80 input
    ) public {
        if (input < 10**12) return;
        if (stakedEth < 10**12) return;
        if (stakedShares == 0) return;

        if (stakedEth / stakedShares > input) return;

        uint256 cache = StakePure.setStakedEth(0, stakedEth);

        cache = StakePure.setStakedShares(cache, stakedShares);

        // (uint96 ethPerShare, uint96 protocolFee, uint96 premium) = StakePure.minSharePriceBreakdown(cache, input);

        // assertEq(ethPerShare, stakedEth / stakedShares);
    }
}
