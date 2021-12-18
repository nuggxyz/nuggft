// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {StakePure} from './StakePure.sol';
import {StakeView} from './StakeView.sol';

import {Stake} from './StakeStorage.sol';

/// @title A title that should describe the contract/interface
/// @author dub6ix
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library StakeCore {
    using StakePure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event StakeEth(uint256 amount);
    event UnStakeEth(uint256 amount);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 ADD
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function addStakedShareAndEth(uint96 eth) internal {
        uint256 cache = Stake.sload();

        (uint64 activeShares, uint96 activeEth, uint96 activeProtocolEth) = cache.getStakedSharesAndEth();

        uint96 protocol = (eth * 100) / 10000;

        eth -= protocol;

        require(eth >= cache.getEthPerShare(), 'SL:M:0');

        Stake.sstore(cache.setStakedShares(activeShares + 1).setStakedEth(activeEth + eth).setProtocolEth(activeProtocolEth + protocol));

        emit StakeEth(eth);
    }

    function addStakedShares(uint64 amount) internal {
        uint256 cache = Stake.sload();

        require(cache.getStakedEth() == 0, 'SC:0');

        Stake.sstore(cache.setStakedShares(cache.getStakedShares() + amount));
    }

    function addStakedEth(uint96 amount) internal {
        uint256 cache = Stake.sload();

        uint96 protocol = (amount * 100) / 10000;

        amount -= protocol;

        Stake.sstore(cache.setStakedEth(cache.getStakedEth() + amount).setProtocolEth(cache.getProtocolEth() + protocol));

        emit StakeEth(amount);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 SUB
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function subStakedSharePayingSender() internal {
        uint256 cache = Stake.sload();

        (uint64 activeShares, uint96 activeEth, ) = cache.getStakedSharesAndEth();

        uint96 eps = cache.getEthPerShare();

        require(activeShares >= 1, 'SL:SS:0');
        require(activeEth >= eps, 'SL:SS:1');

        Stake.sstore(cache.setStakedShares(activeShares - 1).setStakedEth(activeEth - eps));

        SafeTransferLib.safeTransferETH(msg.sender, eps);

        emit UnStakeEth(eps);
    }
}
