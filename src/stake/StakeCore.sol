// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {TokenCore} from '../token/TokenCore.sol';

import {StakePure} from './StakePure.sol';
import {StakeView} from './StakeView.sol';
import {Stake} from './StakeStorage.sol';

/// @title A title that should describe the contract/interface
/// @author dub6ix
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library StakeCore {
    using StakePure for uint256;

    uint96 constant PROTOCOL_FEE_BPS = 100;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event StakeEth(uint96 amount);
    event UnStakeEth(uint96 amount);
    event ProtocolEthExtracted(uint96 amount);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function trustedExtractProtocolEth() internal {
        uint256 cache = Stake.sload();

        uint96 eth = cache.getProtocolEth();

        SafeTransferLib.safeTransferETH(msg.sender, eth);

        Stake.sstore(cache.setProtocolEth(0));

        emit ProtocolEthExtracted(eth);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 ADD
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function addStakedShareAndEth(uint96 eth) internal {
        uint256 cache = Stake.sload();

        (uint64 activeShares, uint96 activeEth, uint96 activeProtocolEth) = cache.getStakedSharesAndEth();

        uint96 protocol = (eth * PROTOCOL_FEE_BPS) / 10000;

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

        uint96 protocol = (amount * PROTOCOL_FEE_BPS) / 10000;

        amount -= protocol;

        Stake.sstore(cache.setStakedEth(cache.getStakedEth() + amount).setProtocolEth(cache.getProtocolEth() + protocol));

        emit StakeEth(amount);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 SUB
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function subStakedSharePayingSender(uint160 tokenId) internal {
        uint256 cache = Stake.sload();

        TokenCore.onBurn(tokenId);

        (uint64 activeShares, uint96 activeEth, ) = cache.getStakedSharesAndEth();

        uint96 preEps = cache.getEthPerShare();

        require(activeShares >= 1, 'SL:SS:0');
        require(activeEth >= preEps, 'SL:SS:1');

        Stake.sstore(cache.setStakedShares(activeShares - 1).setStakedEth(activeEth - preEps));

        SafeTransferLib.safeTransferETH(msg.sender, preEps);

        emit UnStakeEth(preEps);
    }
}
