// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

import {StakePure} from './StakePure.sol';

import {Stake} from './StakeStorage.sol';

/// @title StakeView
/// @author dub6ix
/// @notice functions that combine access to Stake storage and logic for access by outside modules
library StakeView {
    using StakePure for uint256;

    function getActiveEthPerShare() internal view returns (uint256 res) {
        res = Stake.sload().getEthPerShare();
    }

    function getActiveStakedShares() internal view returns (uint256 res) {
        res = Stake.sload().getStakedShares();
    }

    function getActiveStakedEth() internal view returns (uint256 res) {
        res = Stake.sload().getStakedEth();
    }
}
