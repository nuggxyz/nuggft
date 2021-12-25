// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggFTV1Migrator} from '../interfaces/INuggFTV1Migrator.sol';

import {IStakeExternal} from '../interfaces/INuggFT.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {StakeCore} from './StakeCore.sol';
import {StakePure} from './StakePure.sol';

import {Stake} from './StakeStorage.sol';

import {Trust} from '../trust/Trust.sol';

import {ProofCore} from '../proof/ProofCore.sol';

abstract contract StakeExternal is IStakeExternal, Trust {
    using SafeCastLib for uint256;
    using StakePure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                CORE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IStakeExternal
    function withdrawStake(uint160 tokenId) external {
        uint96 ethOwed = StakeCore.subStakedShare(tokenId);

        SafeTransferLib.safeTransferETH(msg.sender, ethOwed);
    }

    /// @inheritdoc IStakeExternal
    function migrateStake(uint160 tokenId) external {
        address migrator = Stake.spointer().trustedMigrator;

        require(migrator != address(0), 'T:4');

        // stores the proof before deleting the nugg
        uint256 proof = ProofCore.checkedProofOf(tokenId);

        uint96 ethOwed = StakeCore.subStakedShare(tokenId);

        INuggFTV1Migrator(migrator).nuggftMigrateFromV1{value: ethOwed}(tokenId, proof, msg.sender);

        emit MigrateV1Sent(migrator, tokenId, proof, msg.sender, ethOwed);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IStakeExternal
    function extractProtocolEth() external requiresTrust {

        uint256 cache = Stake.sload();

        uint96 eth = cache.getProtocolEth();

        SafeTransferLib.safeTransferETH(msg.sender, eth);

        Stake.sstore(cache.setProtocolEth(0));

        emit ProtocolEthExtracted(eth);
    }

    /// @inheritdoc IStakeExternal
    function setMigrator(address migrator) external requiresTrust{

        Stake.spointer().trustedMigrator = migrator;

        emit MigratorV1Updated(migrator);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IStakeExternal
    function minSharePrice() external view override returns (uint96 res) {
        res = StakeCore.minSharePrice();
    }

    /// @inheritdoc IStakeExternal
    function totalStakedShares() external view override returns (uint64 res) {
        res = StakeCore.activeStakedShares();
    }

    /// @inheritdoc IStakeExternal
    function totalStakedEth() external view override returns (uint96 res) {
        res = StakeCore.activeStakedEth();
    }

    /// @inheritdoc IStakeExternal
    function activeEthPerShare() external view override returns (uint96 res) {
        res = StakeCore.activeEthPerShare();
    }

    /// @inheritdoc IStakeExternal
    function totalProtocolEth() external view override returns (uint96 res) {
        res = StakeCore.activeProtocolEth();
    }

    /// @inheritdoc IStakeExternal
    function totalSupply() external view override returns (uint256 res) {
        res = StakeCore.activeStakedShares();
    }
}
