// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {StakePure} from './pure.sol';

import {Stake} from './storage.sol';

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library StakeLogic {
    using StakePure for uint256;

    /// @param amount a parameter just like in doxygen (must be followed by parameter name)
    event StakeEth(uint256 amount);

    /// @param amount a parameter just like in doxygen (must be followed by parameter name)
    event UnStakeEth(uint256 amount);

    function addStakedSharesAndEth(uint256 shares, uint256 eth) internal {
        require(shares < ShiftLib.mask(64) && eth < ShiftLib.mask(192), 'SL:SS:0');

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

        emit StakeEth(amount);
    }

    // function removeStake(uint256 amount) internal {
    //     SafeTransferLib.safeTransferETH(msg.sender, floor);

    //     StakeLogic.subStakedEth(floor);

    //     StakeLogic.subStakedShares(1);
    // }

    function subStakedSharePayingSender() internal {
        uint256 read = Stake.ptr().data;

        (uint256 activeShare, uint256 activeEth) = read.getStakedSharesAndEth();

        uint256 eth = StakeView.getActiveEthPerShare();

        require(activeShares >= 1, 'SL:SS:0');
        require(activeEth >= eth, 'SL:SS:0');

        Stake.ptr().data = read.setStakedShares(activeShare - amount).setStakedEth(activeEth - eth);

        msg.sender.safeTransferETH(eth);
    }

    // function subStakedEth(uint256 amount) internal {
    //     uint256 read = Stake.ptr().data;

    //     uint256 activeEth = read.getStakedEth();

    //     require(activeEth >= amount, 'SL:SS:0');

    //     Stake.ptr().data = read.setStakedEth(activeEth - amount);

    //     emit UnStakeEth(amount);
    // }
}
