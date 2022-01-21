// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../../NuggftV1.test.sol';

import {NuggftV1StakeType} from '../../../types/NuggftV1StakeType.sol';
import {NuggftV1Loan} from '../../../core/NuggftV1Loan.sol';
import {NuggftV1Token} from '../../../core/NuggftV1Token.sol';

contract logic__NuggftV1Stake is NuggftV1Test {
    using NuggftV1StakeType for uint256;

    function unsafe__addStaked(
        uint256 cache,
        uint96 protocolFee,
        uint96 value
    ) public pure returns (uint256) {
        assembly {
            cache := or(and(cache, not(shl(96, sub(shl(96, 1), 1)))), shl(96, add(shr(96, cache), sub(value, protocolFee))))
        }

        return cache;
    }

    function test__logic__NuggftV1Stake__symbolic__addStaked(uint256 cache,uint96 value) public {
        uint96 protocolFee;
        assembly {
            protocolFee := div(mul(value, 1000), 10000)
        }
        uint256 unsafe = unsafe__addStaked(cache, protocolFee, value);
        uint256 safe = cache.addStaked(value - protocolFee);

        assertEq(unsafe, safe, 'A');
    }
}
