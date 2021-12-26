// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggftV1Proof} from './NuggftV1Proof.sol';

import {INuggftV1Migrator} from '../interfaces/nuggftv1/INuggftV1Migrator.sol';
import {INuggftV1Stake} from '../interfaces/nuggftv1/INuggftV1Stake.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {NuggftV1StakeType} from '../types/NuggftV1StakeType.sol';

abstract contract NuggftV1Stake is INuggftV1Stake, NuggftV1Proof {
    using SafeCastLib for uint256;
    using NuggftV1StakeType for uint256;

    address public migrator;

    uint256 internal stake;

    uint96 constant PROTOCOL_FEE_BPS = 1000;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc INuggftV1Stake
    function extractProtocolEth() external requiresTrust {
        uint256 cache = stake;

        emit ProtocolEthExtracted(cache.proto());

        SafeTransferLib.safeTransferETH(msg.sender, cache.proto());

        stake = cache.proto(0);
    }

    /// @inheritdoc INuggftV1Stake
    function setMigrator(address _migrator) external requiresTrust {
        migrator = _migrator;

        emit MigratorV1Updated(_migrator);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc INuggftV1Stake
    function ethPerShare() public view override returns (uint96 res) {
        res = calculateEthPerShare(stake);
    }

    /// @inheritdoc INuggftV1Stake
    function minSharePrice() public view override returns (uint96 res) {
        (res, , , ) = minSharePriceBreakdown(stake);
    }

    /// @inheritdoc INuggftV1Stake
    function stakedShares() public view override returns (uint64 res) {
        res = stake.shares();
    }

    /// @inheritdoc INuggftV1Stake
    function stakedEth() public view override returns (uint96 res) {
        res = stake.staked();
    }

    /// @inheritdoc INuggftV1Stake
    function protocolEth() public view override returns (uint96 res) {
        res = stake.proto();
    }

    /// @inheritdoc INuggftV1Stake
    function totalSupply() public view override returns (uint256 res) {
        res = stakedShares();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            ADD STAKE & SHARES
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @notice handles the adding of shares - ensures enough eth is being added
    /// @dev this is the only way to add shares - the logic here ensures that "ethPerShare" can never decrease
    function addStakedShareFromMsgValue() internal {
        uint96 value = msg.value.safe96();

        uint256 cache = stake;

        (uint96 totalPrice, , uint96 protocolFee, ) = minSharePriceBreakdown(cache);

        // logically unnessesary - to help front end
        require(value >= totalPrice, 'T:1'); // "not enough eth to create share"

        uint96 overpay = value - totalPrice;

        // the rest of the value gets added to stakedEth
        protocolFee += calculateProtocolFeeOf(overpay);

        cache = cache.addShares(1);
        cache = cache.addStaked(value - protocolFee);
        cache = cache.addProto(protocolFee);

        stake = cache;

        emit StakeEth(value - protocolFee, protocolFee);
    }

    /// @notice handles isolated staking of eth
    /// @dev supply of eth goes up while supply of shares stays constant - increasing "minSharePrice"
    /// @param eth the amount of eth being staked - must be some portion of msg.value
    function addStakedEth(uint96 eth) internal {
        require(msg.value >= eth, 'T:2'); // "value of tx too low"

        uint256 cache = stake;

        uint96 protocolFee = calculateProtocolFeeOf(eth);

        stake = cache.staked(cache.staked() + eth - protocolFee).proto(cache.proto() + protocolFee);

        emit StakeEth(eth - protocolFee, protocolFee);
    }

    function calculateProtocolFeeOf(uint96 any) internal pure returns (uint96 res) {
        res = (any * PROTOCOL_FEE_BPS) / 10000;
    }

    // @test manual
    function minSharePriceBreakdown(uint256 cache)
        internal
        pure
        returns (
            uint96 total,
            uint96 eps,
            uint96 protocolFee,
            uint96 premium
        )
    {
        eps = calculateEthPerShare(cache);

        protocolFee = calculateProtocolFeeOf(eps);

        premium = ((eps * cache.shares()) / 10000);

        total = eps + protocolFee + premium;
    }

    // @test manual
    function calculateEthPerShare(uint256 cache) internal pure returns (uint96 res) {
        res = cache.shares() == 0 ? 0 : cache.staked() / cache.shares();
    }
}
