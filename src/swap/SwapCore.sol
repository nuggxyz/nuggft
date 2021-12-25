// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggFT} from '../interfaces/INuggFT.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Swap} from './SwapStorage.sol';
import {SwapPure} from '../swap/SwapPure.sol';

import {StakeCore} from '../stake/StakeCore.sol';

library SwapCore {
    using SafeCastLib for uint256;
    using SwapPure for uint256;
    using SwapPure for uint96;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            COMMON FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function checkClaimerIsWinnerOrLoser(Swap.Memory memory m) internal pure returns (bool winner) {
        require(m.offerData != 0, 'S:E');

        bool isOver = m.activeEpoch > m.swapData.epoch();
        bool isLeader = m.offerData.account() == m.swapData.account();
        bool isOwner = m.swapData.isOwner() && m.offerData.isOwner();

        return isLeader && (isOwner || isOver);
    }

    function commit(Swap.Storage storage s, Swap.Memory memory m) internal {
        assert(m.offerData == 0 && m.swapData != 0);

        assert(m.swapData.isOwner());

        (uint256 newSwapData, uint96 increment, uint96 dust) = updateSwapDataWithEpoch(
            m.swapData,
            m.activeEpoch + 1,
            m.sender,
            msg.value.safe96()
        );

        s.data = newSwapData;

        s.offers[m.swapData.account()] = m.swapData.epoch(m.activeEpoch + 1).isOwner(false);

        StakeCore.addStakedEth(increment + dust);
    }

    function offer(Swap.Storage storage s, Swap.Memory memory m) internal {
        // make sure swap is still active
        require(m.activeEpoch <= m.swapData.epoch(), 'S:F');

        if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

        (uint256 newSwapData, uint96 increment, uint96 dust) = updateSwapData(m.swapData, m.sender, m.offerData.eth() + msg.value.safe96());

        s.data = newSwapData;

        StakeCore.addStakedEth(increment + dust);
    }

    // @test  manual
    function updateSwapData(
        uint256 prevSwapData,
        address account,
        uint96 newUserOfferEth
    )
        internal
        pure
        returns (
            uint256 res,
            uint96 increment,
            uint96 dust
        )
    {
        return updateSwapDataWithEpoch(prevSwapData, prevSwapData.epoch(), account, newUserOfferEth);
    }

    // @test  unit
    function updateSwapDataWithEpoch(
        uint256 prevSwapData,
        uint32 epoch,
        address account,
        uint96 newUserOfferEth
    )
        internal
        pure
        returns (
            uint256 res,
            uint96 increment,
            uint96 dust
        )
    {
        uint96 baseEth = prevSwapData.eth();

        require(baseEth.addIncrement() <= newUserOfferEth, 'S:G');

        (res, dust) = SwapPure.buildSwapData(epoch, account, newUserOfferEth, false);

        increment = newUserOfferEth - baseEth;
    }
}
