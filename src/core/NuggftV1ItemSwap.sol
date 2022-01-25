// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {INuggftV1ItemSwap} from '../interfaces/nuggftv1/INuggftV1ItemSwap.sol';
import {NuggftV1Stake} from './NuggftV1Stake.sol';
import {CastLib} from '../libraries/CastLib.sol';
import {TransferLib} from '../libraries/TransferLib.sol';

import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';
import '../_test/utils/forge.sol';

/// @notice mechanism for trading of nuggs between users (and items between nuggs)
/// @dev Explain to a developer any extra details
abstract contract NuggftV1ItemSwap is INuggftV1ItemSwap, NuggftV1Stake {
    mapping(uint16 => uint256) protocolItems;

    mapping(uint176 => mapping(uint160 => uint256)) itemOffers;
    mapping(uint176 => uint256) itemAgency;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  offer
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1ItemSwap
    function offerItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable override {
        require(isAgent(msg.sender, buyerTokenId), hex'2A');

        uint256 id = encItemId(sellerTokenId, itemId);

        uint256 agency__cache;

        uint256 active = epoch();
        uint256 last;

        assembly {
            let next := div(callvalue(), LOSS)

            let ptr := mload(0x40)

            mstore(ptr, id)
            mstore(add(ptr, 0x20), itemAgency.slot)

            let agency__slo := keccak256(ptr, 0x40)
            agency__cache := sload(agency__slo)

            mstore(0x40, add(ptr, 0x40))

            // make sure user is not the owner of swap
            // we do not know how much to give them when they call "claim" otherwise

            // ensure that the agency flag is "SWAP" (0x01)
            if iszero(eq(shr(254, agency__cache), 0x03)) {
                mstore8(0x0, Error__NotSwapping__0x24)
                revert(0x00, 0x01)
            }

            // calculate and store the offer[id]__slot
            // id already exists at ptr
            mstore(add(ptr, 0x20), itemOffers.slot)
            mstore(add(ptr, 0x20), keccak256(ptr, 0x40))

            let lastLead := shr(96, shl(96, agency__cache))

            let offer__cache := agency__cache

            if iszero(eq(buyerTokenId, lastLead)) {
                mstore(ptr, buyerTokenId)
                offer__cache := sload(keccak256(ptr, 0x40))
            }

            // check to see if user has offered by checking if cache != 0
            if iszero(iszero(offer__cache)) {
                // check to see if the epoch from offer__cache has expired
                // this accomplishes two important goals:
                // 1. forces user to claim previous swap before acting on this one
                // 2. prevents owner from offering on their own swap before someone else has
                if lt(shr(232, shl(2, offer__cache)), active) {
                    mstore8(0x0, Error__InvalidEpoch__0x0F)
                    revert(0x00, 0x01)
                }
            }

            // check to see if the epoch stored in agency__cache == 0
            switch iszero(shr(232, shl(2, agency__cache)))
            // if so, we know this swap has not yet been offered on
            // we update the epoch and we transfer the token to the contract
            case 1 {
                active := add(active, SALE_LEN)

                agency__cache := or(agency__cache, shl(230, active))

                // log4(0x00, 0x00, TRANSFER, lastLead, address(), id)
            }
            // otherwise we validate the epoch to ensure the swap is still active
            default {
                let agency__epoch := shr(232, shl(2, agency__cache))

                if lt(agency__epoch, active) {
                    mstore8(0x0, Error__ExpiredEpoch__0x2F)
                    revert(0x00, 0x01)
                }

                active := agency__epoch
            }

            last := shr(186, shl(26, agency__cache))
            next := add(shr(186, shl(26, offer__cache)), next)

            if gt(div(mul(last, 10200), 10000), next) {
                mstore8(0x0, Error__IncrementTooLow__0x72)
                revert(0x00, 0x01)
            }

            last := mul(sub(next, last), LOSS)

            // record agency so we know how much to repay previous leader
            mstore(ptr, shr(96, shl(96, agency__cache)))
            sstore(keccak256(ptr, 0x40), agency__cache)

            // update agency to reflect the new leader
            // agency[id] = {
            //     flag  = SWAP
            //     epoch = active or active +1
            //     eth   = new highest value / 10**8
            //     addr  = msg.sender
            // }
            agency__cache := or(shl(254, 0x01), or(shl(230, active), or(shl(160, next), buyerTokenId)))
            sstore(agency__slo, agency__cache)
        }

        addStakedEth__dirty(uint96(last));

        emit OfferItem(encItemId(sellerTokenId, itemId), bytes32(agency__cache));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  claim
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1ItemSwap
    function claimItem(
        uint160[] calldata buyerTokenIds,
        uint160[] calldata sellerTokenIds,
        uint16[] calldata itemIds
    ) external override {
        require(itemIds.length == sellerTokenIds.length && itemIds.length == buyerTokenIds.length, hex'23');

        uint96 acc;

        for (uint256 i = 0; i < itemIds.length; i++) {
            uint160 buyerTokenId = buyerTokenIds[i];

            require(isAgent(msg.sender, buyerTokenId), hex'29');

            uint176 sellerItemId = encItemId(sellerTokenIds[i], itemIds[i]);

            uint256 agency__cache = itemAgency[sellerItemId];

            // require(agency__cache != 0, hex'22');

            uint256 offerData;

            if (buyerTokenId == uint160(agency__cache)) {
                offerData = agency__cache;
            } else {
                offerData = itemOffers[sellerItemId][buyerTokenId];
            }

            delete itemOffers[sellerItemId][buyerTokenId];

            require(offerData != 0, hex'2E');

            // if "isLeader"
            if (uint160(offerData) == uint160(agency__cache)) {
                uint24 _epoch = uint24(agency__cache >> 230);
                // require "isOwner" or "isOver
                require(_epoch == 0 || epoch() > _epoch, hex'67');

                delete itemAgency[sellerItemId];

                assert(protocolItems[itemIds[i]] > 0);

                addItem(buyerTokenId, itemIds[i]);

                protocolItems[itemIds[i]]--;
            } else {
                // if (agency[buy])
                assembly {
                    // extract "eth" from offerData object and decompress
                    acc := add(acc, mul(and(shr(offerData, 160), sub(shl(70, 1), 1)), LOSS))
                }
            }

            emit ClaimItem(sellerItemId, buyerTokenId);
        }

        assembly {
            if iszero(acc) {
                return(0, 0)
            }
            if iszero(call(gas(), caller(), acc, 0, 0, 0, 0)) {
                mstore8(0x0, Error__SendEthFailureToCaller__0x92)
                revert(0x00, 0x01)
            }
        }
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  sell
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1ItemSwap
    function sellItem(
        uint160 tokenId,
        uint16 itemId,
        uint96 floor
    ) external override {
        require(isAgent(msg.sender, tokenId), hex'2A');

        // will revert if they do not have the item
        removeItem(tokenId, itemId);

        unchecked {
            protocolItems[itemId]++;
        }

        uint256 agency__cache = itemAgency[encItemId(tokenId, itemId)];

        // cannot sell two of the same item at same time
        require(agency__cache == 0, hex'2D');

        uint256 updatedAgency;

        assembly {
            // updatedAgency = [ flag: SWAP | epoch: 0 | eth: floor/10**8 | addr: tokenId ]
            updatedAgency := or(shl(254, 0x03), or(shl(230, 0), or(shl(160, div(floor, LOSS)), tokenId)))
        }

        itemAgency[encItemId(tokenId, itemId)] = updatedAgency;

        emit SellItem(encItemId(tokenId, itemId), bytes32(updatedAgency));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    view
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // / @inheritdoc INuggftV1ItemSwap
    function checkItemOffer(
        uint160 buyer,
        uint160 seller,
        uint16 itemId
    )
        external
        view
        override
        returns (
            bool canOffer,
            uint96 nextSwapAmount,
            uint96 senderCurrentOffer
        )
    {
        canOffer = true;

        uint176 sellerItemId = (uint176(itemId) << 160) | seller;

        uint256 agency__cache = itemAgency[sellerItemId];

        uint24 activeEpoch = epoch();

        uint256 offerData = agency__cache;

        if (buyer != uint160(agency__cache)) {
            offerData = itemOffers[sellerItemId][buyer];
        }

        if (uint24(agency__cache >> 230) == 0 && offerData == agency__cache) canOffer = false;

        senderCurrentOffer = uint96((offerData << 26) >> 186);

        nextSwapAmount = uint96((agency__cache << 26) >> 186);

        if (nextSwapAmount != 0) {
            nextSwapAmount = uint96(nextSwapAmount * 102 * LOSS) / 100;
        }
    }

    function encItemId(uint160 tokenId, uint16 itemId) internal pure returns (uint176) {
        return (uint176(itemId) << 160) | tokenId;
    }
}
