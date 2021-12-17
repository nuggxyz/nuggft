// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {StakePure} from './StakePure.sol';
import {StakeView} from './StakeView.sol';

import {Stake} from './StakeStorage.sol';

/// @title A title that should describe the contract/interface
/// @author The name of the author
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

    function addStakedSharesAndEth(uint256 shares, uint256 eth) internal {
        require(shares < ShiftLib.mask(64) && eth < ShiftLib.mask(192), 'SL:SS:0');

        require(eth >= StakeView.getActiveEthPerShare(), 'SL:M:0');

        uint256 read = Stake.ptr().data;

        (uint256 activeShare, uint256 activeEth) = read.getStakedSharesAndEth();

        Stake.ptr().data = read.setStakedShares(activeShare + shares).setStakedEth(activeEth + eth);

        emit StakeEth(eth);
    }

    function addStakedShares(uint256 amount) internal {
        require(amount < ShiftLib.mask(64), 'SL:SS:0');

        uint256 read = Stake.ptr().data;

        Stake.ptr().data = read.setStakedShares(read.getStakedShares() + amount);
    }

    function addStakedEth(uint256 amount) internal {
        require(amount < ShiftLib.mask(192), 'SL:SS:0');

        uint256 read = Stake.ptr().data;

        Stake.ptr().data = read.setStakedEth(read.getStakedEth() + amount);

        assert(Stake.ptr().data.getStakedEth() > 0);

        emit StakeEth(amount);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 SUB
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function subStakedSharePayingSender() internal {
        uint256 read = Stake.ptr().data;

        (uint256 activeShares, uint256 activeEth) = read.getStakedSharesAndEth();

        uint256 eth = StakeView.getActiveEthPerShare();

        require(activeShares >= 1, 'SL:SS:0');
        require(activeEth >= eth, 'SL:SS:1');

        Stake.ptr().data = read.setStakedShares(activeShares - 1).setStakedEth(activeEth - eth);

        SafeTransferLib.safeTransferETH(msg.sender, eth);

        emit UnStakeEth(eth);
    }
}
