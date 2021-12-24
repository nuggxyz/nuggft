// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggFTV1Migrator} from '../interfaces/INuggFTV1Migrator.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Global} from '../global/GlobalStorage.sol';

import {Token} from '../token/TokenStorage.sol';
import {TokenCore} from '../token/TokenCore.sol';
import {TokenView} from '../token/TokenView.sol';

import {ProofCore} from '../proof/ProofCore.sol';

import {Stake} from './StakeStorage.sol';
import {StakePure} from './StakePure.sol';

// SYSTEM
/// @title A title that should describe the contract/interface
/// @author dub6ix
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library StakeCore {
    using StakePure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event StakeEth(uint96 stake, uint96 protocol);
    event UnStakeEth(uint96 stake, address to);
    event ProtocolEthExtracted(uint96 eth);
    event MigratorV1Updated(address migrator);
    event MigrateV1Sent(address v2, uint160 tokenId, uint256 proof, address owner, uint96 eth);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice returns the active "ethPerShare" held by the contract
    /// @dev this value not always equivilent to the "floor" price which can consist of perceived value.
    /// can be looked at as an "intrinsic floor"
    /// @dev this is the value that users will receive when their either burn or loan out nuggs
    /// @return res -> [current staked eth] / [current staked shares]
    function activeEthPerShare() internal view returns (uint96 res) {
        res = Stake.sload().getEthPerShare();
    }

    /// @notice returns the minimum eth that must be added to create a new share
    /// @dev premium here is used to push against dillution of supply through ensuring the price always increases
    /// @dev used by the front end
    /// @return res -> premium + protcolFee + ethPerShare
    function minSharePrice() internal view returns (uint96 res) {
        (res, , , ) = Stake.sload().minSharePriceBreakdown();
    }

    /// @notice returns the total number of staked shares held by the contract
    /// @dev this is equivilent to the amount of nuggs in existance
    function activeStakedShares() internal view returns (uint64 res) {
        res = Stake.sload().getStakedShares();
    }

    /// @notice returns the total amount of staked eth held by the contract
    /// @dev can be used as the market-cap or tvl of all nuggft v1
    /// @dev not equivilent to the balance of eth the contract holds, which also hs protocolEth and
    /// unclaimed eth from unsuccessful swaps
    function activeStakedEth() internal view returns (uint96 res) {
        res = Stake.sload().getStakedEth();
    }

    /// @notice returns the amount of eth extractable by protocol
    /// @dev this will be
    /// @return res -> (PROTOCOL_FEE_BPS * [all eth staked] / 10000) - [all previously extracted eth]
    function activeProtocolEth() internal view returns (uint96 res) {
        res = Stake.sload().getProtocolEth();
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            ADD STAKE & SHARES
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice handles the adding of shares - ensures enough eth is being added
    /// @dev this is the only way to add shares - the logic here ensures that "ethPerShare" can never decrease
    /// @param eth the amount of eth being put up for a new share - must be some portion of msg.value
    function addStakedShareAndEth(uint96 eth) internal {
        require(msg.value >= eth, 'T:0'); // "value of tx too low"

        uint256 cache = Stake.sload();

        (uint64 activeShares, uint96 activeEth, uint96 activeProtoEth) = cache.getStakedSharesAndEth();

        (uint96 totalPrice, , uint96 protocolFee, ) = cache.minSharePriceBreakdown();

        // logically unnessesary - to help front end
        require(eth >= totalPrice, 'T:1'); // "not enough eth to create share"

        uint96 overpay = eth - totalPrice;

        // the rest of the value gets added to stakedEth
        protocolFee += StakePure.calculateProtocolFeeOf(overpay);

        Stake.sstore(
            cache.setStakedShares(activeShares + 1).setStakedEth(activeEth + (eth - protocolFee)).setProtocolEth(
                activeProtoEth + protocolFee
            )
        );

        emit StakeEth(eth - protocolFee, protocolFee);
    }

    /// @notice handles isolated staking of eth
    /// @dev supply of eth goes up while supply of shares stays constant - increasing "minSharePrice"
    /// @param eth the amount of eth being staked - must be some portion of msg.value
    function addStakedEth(uint96 eth) internal {
        require(msg.value >= eth, 'T:2'); // "value of tx too low"

        uint256 cache = Stake.sload();

        uint96 protocolFee = StakePure.calculateProtocolFeeOf(eth);

        Stake.sstore(cache.setStakedEth(cache.getStakedEth() + (eth - protocolFee)).setProtocolEth(cache.getProtocolEth() + protocolFee));

        emit StakeEth(eth - protocolFee, protocolFee);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                BURN/MIGRATE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice removes a staked share from the contract,
    /// @dev this is the only way to remove a share
    /// @dev caculcates but does not handle dealing the eth - which is handled by the two helpers above
    /// @dev ensures the user is the owner of the nugg
    /// @param tokenId the id of the nugg being unstaked
    /// @return ethOwed -> the amount of eth owed to the unstaking user - equivilent to "ethPerShare"
    function subStakedShare(uint160 tokenId) internal returns (uint96 ethOwed) {
        address owner = TokenView.ownerOf(tokenId);

        require(TokenView.getApproved(tokenId) == address(this) && TokenView.isOperatorFor(msg.sender, owner), 'T:3');

        uint256 cache = Stake.sload();

        // hanles all logic not related to staking the nugg
        delete Token.ptr().owners[tokenId];
        delete Token.ptr().approvals[tokenId];

        delete Global.ptr().swap.map[tokenId];
        delete Global.ptr().loan.map[tokenId];
        delete Global.ptr().proof.map[tokenId];
        delete Global.ptr().file.resolvers[tokenId];

        TokenCore.emitTransferEvent(owner, address(0), tokenId);

        (uint64 activeShares, uint96 activeEth, ) = cache.getStakedSharesAndEth();

        ethOwed = cache.getEthPerShare();

        /// TODO - test migration
        assert(activeShares >= 1);
        assert(activeEth >= ethOwed);

        Stake.sstore(cache.setStakedShares(activeShares - 1).setStakedEth(activeEth - ethOwed));

        emit UnStakeEth(ethOwed, msg.sender);
    }
}
