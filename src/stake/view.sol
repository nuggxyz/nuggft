import {Global} from '../global/storage.sol';

import {QuadMath} from '../libraries/QuadMath.sol';

import {StakePure} from './pure.sol';

import {Stake} from './storage.sol';

library StakeView {
    using StakePure for uint256;

    function getActiveEthPerShare() internal view returns (uint256 res) {
        res = Stake.ptr().data;
        res = res.getStakedEth() / res.getStakedShares();
    }

    function getActiveStakedShares() internal view returns (uint256 res) {
        res = Stake.ptr().data.getStakedShares();
    }

    function getActiveStakedEth() internal view returns (uint256 res) {
        res = Stake.ptr().data.getStakedEth();
    }
}
