// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggFT} from '../interfaces/INuggFT.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Swap} from './SwapStorage.sol';
import {SwapPure} from '../swap/SwapPure.sol';

import {StakeCore} from '../stake/StakeCore.sol';

import {ProofCore} from '../proof/ProofCore.sol';

import {TokenCore} from '../token/TokenCore.sol';
import {TokenView} from '../token/TokenView.sol';

library SwapCore {
    using SafeCastLib for uint256;
    using SwapPure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            COMMON FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkClaimerIsWinnerOrLoser(Swap.Memory memory m) internal pure returns (bool winner) {
        require(m.offerData != 0, 'S:8');

        bool isOver = m.activeEpoch > m.swapData.epoch();
        bool isLeader = m.offerData.account() == m.swapData.account();
        bool isOwner = m.swapData.isOwner();

        return isOwner || (isLeader && isOver);
    }

    function commit(Swap.Storage storage s, Swap.Memory memory m) internal {
        assert(m.offerData == 0 && m.swapData != 0);

        assert(m.swapData.isOwner());

        (uint256 newSwapData, uint256 increment, uint256 dust) = SwapPure.updateSwapDataWithEpoch(
            m.swapData,
            m.activeEpoch + 1,
            m.sender,
            msg.value.safe96()
        );

        s.data = newSwapData;

        s.offers[m.swapData.account()] = m.swapData;

        StakeCore.addStakedEth((increment + dust).safe96());
    }

    function offer(Swap.Storage storage s, Swap.Memory memory m) internal {
        // make sure swap is still active
        require(m.activeEpoch <= m.swapData.epoch(), 'SL:OBP:3');

        if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

        (uint256 newSwapData, uint256 increment, uint256 dust) = SwapPure.updateSwapData(
            m.swapData,
            m.sender,
            m.offerData.eth() + msg.value.safe96()
        );

        s.data = newSwapData;

        StakeCore.addStakedEth((increment + dust).safe96());
    }
}
