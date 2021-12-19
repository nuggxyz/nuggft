// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggFTV1Migrator} from '../interfaces/INuggFTV1Migrator.sol';

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {TokenCore} from '../token/TokenCore.sol';
import {TokenView} from '../token/TokenView.sol';
import {ProofView} from '../proof/ProofView.sol';

import {StakePure} from './StakePure.sol';
import {StakeView} from './StakeView.sol';
import {Stake} from './StakeStorage.sol';
import {Trust} from '../trust/TrustStorage.sol';

// SYSTEM
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
    event MigratorV1Updated(address migrator);
    event MigrateV1Sent(address v2, uint160 tokenId, uint256 proof, address owner, uint96 eth);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function trustedExtractProtocolEth(Trust.Storage storage trust) internal {
        require(trust._isTrusted, 'T:0');

        uint256 cache = Stake.sload();

        uint96 eth = cache.getProtocolEth();

        SafeTransferLib.safeTransferETH(msg.sender, eth);

        Stake.sstore(cache.setProtocolEth(0));

        emit ProtocolEthExtracted(eth);
    }

    function trustedSetMigrator(Trust.Storage storage trust, address migrator) internal {
        require(trust._isTrusted, 'T:1');

        Stake.spointer().trustedMigrator = migrator;

        emit MigratorV1Updated(migrator);
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
                                BURN/MIGRATE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function migrateStakedShare(uint160 tokenId) internal {
        address migrator = Stake.spointer().trustedMigrator;

        require(migrator != address(0));

        uint256 proof = ProofView.checkedProofOf(tokenId);

        uint96 ethOwed = subStakedShare(tokenId);

        INuggFTV1Migrator(migrator).nuggftMigrateFromV1{value: ethOwed}(tokenId, proof, msg.sender);

        emit MigrateV1Sent(migrator, tokenId, proof, msg.sender, ethOwed);
    }

    function burnStakedShare(uint160 tokenId) internal {
        uint96 ethOwed = subStakedShare(tokenId);

        SafeTransferLib.safeTransferETH(msg.sender, ethOwed);
    }

    function subStakedShare(uint160 tokenId) private returns (uint96 ethOwed) {
        require(TokenView.ownerOf(tokenId) == msg.sender, 'SC:9');

        uint256 cache = Stake.sload();

        TokenCore.onBurn(tokenId);

        (uint64 activeShares, uint96 activeEth, ) = cache.getStakedSharesAndEth();

        ethOwed = cache.getEthPerShare();

        require(activeShares >= 1, 'SC:10');
        require(activeEth >= ethOwed, 'SC:11');

        Stake.sstore(cache.setStakedShares(activeShares - 1).setStakedEth(activeEth - ethOwed));

        emit UnStakeEth(ethOwed);
    }
}
