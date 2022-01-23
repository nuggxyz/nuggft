// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggftV1ItemSwap} from './NuggftV1ItemSwap.sol';
import {INuggftV1Swap} from '../interfaces/nuggftv1/INuggftV1Swap.sol';
import {NuggftV1Stake} from './NuggftV1Stake.sol';
import {CastLib} from '../libraries/CastLib.sol';
import {TransferLib} from '../libraries/TransferLib.sol';

import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';
import '../_test/utils/forge.sol';

/// @notice mechanism for trading of nuggs between users (and items between nuggs)
/// @dev Explain to a developer any extra details
abstract contract NuggftV1Swap is INuggftV1Swap, NuggftV1ItemSwap {
    using NuggftV1AgentType for uint256;

    mapping(uint160 => mapping(address => uint256)) offers;

    /// @inheritdoc INuggftV1Swap
    function offer(uint160 tokenId) external payable override {
        uint256 agency__sptr;

        uint256 agency__cache;
        uint256 next;

        uint256 active = epoch();
        uint256 mptr;

        assembly {
            next := div(callvalue(), LOSS)

            mptr := mload(0x40)

            mstore(mptr, tokenId)
            mstore(add(mptr, 0x20), agency.slot)

            agency__sptr := keccak256(mptr, 0x40)
            agency__cache := sload(agency__sptr)

            mstore(0x40, add(mptr, 0x40))
        }

        // check to see if this nugg needs to be minted
        if (active == tokenId && agency__cache == 0) {
            setProofFromEpoch(tokenId);

            addStakedShareFromMsgValue__dirty();

            assembly {
                // init agency__cache with SWAP flag and active epoch
                // other values handled at end of function
                agency__cache := xor(shl(254, 0x03), shl(230, active))

                log4(0x00, 0x00, TRANSFER, 0, address(), tokenId)
            }
        } else {
            uint256 last;

            assembly {
                // ensure that the agency flag is "SWAP" (0x03)
                if iszero(eq(shr(254, agency__cache), 0x03)) {
                    mstore8(0x0, 0x24) // ERR:0x24
                    revert(0x00, 0x01)
                }

                // calculate and store the offer[tokenId]__slot
                // tokenId already exists at mptr
                mstore(add(mptr, 0x20), offers.slot)
                mstore(add(mptr, 0x20), keccak256(mptr, 0x40))

                let agency__addr := shr(96, shl(96, agency__cache))

                let agency__epoch := shr(232, shl(2, agency__cache))

                // we assume offer__cache is same as agency__cache
                // this will only be the case for the leader
                let offer__cache := agency__cache

                // check to see if msg.sender is the leader
                if iszero(eq(caller(), agency__addr)) {
                    // if not, we update offer__cache
                    mstore(mptr, caller())
                    offer__cache := sload(keccak256(mptr, 0x40))
                }

                // check to see if user has offered by checking if cache != 0
                if iszero(iszero(offer__cache)) {
                    // check to see if the epoch from offer__cache has expired
                    // this accomplishes two important goals:
                    // 1. forces user to claim previous swap before acting on this one
                    // 2. prevents owner from offering on their own swap before someone else has
                    if lt(shr(232, shl(2, offer__cache)), active) {
                        mstore8(0x0, 0x0F) // ERR:0x0F
                        revert(0x00, 0x01)
                    }
                }

                // check to see if the swap's epoch is 0
                switch iszero(agency__epoch)
                case 1 {
                    // if so, we know this swap has not yet been offered on
                    // update the epoch to begin auction
                    agency__cache := xor(agency__cache, shl(230, add(active, SALE_LEN)))

                    // transfer the token to the contract for the remainder of sale
                    // the seller (agency__addr) approves this when they put the token up for sale
                    log4(0x00, 0x00, TRANSFER, agency__addr, address(), tokenId)
                }
                default {
                    // otherwise we validate the epoch to ensure the swap is still active
                    if lt(agency__epoch, active) {
                        mstore8(0x0, 0x2F) // ERR:0x2F
                        revert(0x00, 0x01)
                    }
                }

                // parse last offer value
                last := shr(186, shl(26, agency__cache))

                // parse and caculate next offer value
                next := add(shr(186, shl(26, offer__cache)), next)

                // ensure next offer includes at least a 2% increment
                if gt(div(mul(last, 10200), 10000), next) {
                    mstore8(0x0, 0x72)
                    revert(0x00, 0x01)
                }

                // convert next into the increment
                // saving local variables
                next := sub(next, last)

                // convert last into increment * LOSS for staking
                // saving local variables
                last := mul(next, LOSS)

                // record agency so we know how much to repay previous leader
                mstore(mptr, shr(96, shl(96, agency__cache)))
                sstore(keccak256(mptr, 0x40), agency__cache)

                // clear previous leader from agency cache
                agency__cache := shl(160, shr(160, agency__cache))
            }

            // add the increment * LOSS to staked eth
            addStakedEth__dirty(uint96(last));
        }

        assembly {
            // update agency to reflect the new leader
            // =======================
            // agency[tokenId] = {
            //     flag  = SWAP
            //     epoch = active or active + 1
            //     eth   = new highest offer
            //     addr  = msg.sender
            // }
            // =======================
            agency__cache := xor(add(agency__cache, shl(160, next)), caller())

            sstore(agency__sptr, agency__cache)

            mstore(mptr, agency__cache)

            log2(mptr, 0x20, OFFER, tokenId)
        }
    }

    /// @inheritdoc INuggftV1Swap
    function claim(uint160[] calldata tokenIds, address[] calldata accounts) external override {
        uint256 active = epoch();

        assembly {
            // extract length of tokenIds array from calldata
            let len := calldataload(sub(tokenIds.offset, 0x20))

            // ensure arrays the same length
            if iszero(eq(len, calldataload(sub(accounts.offset, 0x20)))) {
                mstore8(0x0, 0x99)
                // calldatacopy(0x00, tokenIds.offset, 0x32)
                revert(0x00, 0x01)
            }

            // value to keep track of value to send to caller
            let acc := 0

            // memory layout as offset from mptr:
            // ==========================
            // 0x00: tokenId                keccak = agency[tokenId].slot = "agency__sptr"
            // 0x20: agency.slot
            // --------------------------
            // 0x40: tokenId                keccak = offers[tokenId].slot
            // 0x60: offers.slot
            // --------------------------
            // 0x80: offerer                keccak = offers[tokenId][offerer].slot = "offer__sptr"
            // 0xA0: offers[tokenId].slot
            // ==========================

            let mptr := mload(0x40)

            // store common slot for agency in memory
            mstore(add(mptr, 0x20), agency.slot)

            // store common slot for offers in memory
            mstore(add(mptr, 0x60), offers.slot)

            for {
                let i := 0
                // init the pointers at the first element in the calldata array
                let tokenPtr := tokenIds.offset
                let accntPtr := accounts.offset
            } lt(i, len) {
                i := add(i, 1)
                // increment the pointers to the next element in the calldata array
                tokenPtr := add(tokenPtr, 0x20)
                accntPtr := add(accntPtr, 0x20)
            } {
                // tokenIds[i]
                let tokenId := calldataload(tokenPtr)

                // calculate agency.slot storeage ptr
                mstore(mptr, tokenId)
                let agency__sptr := keccak256(mptr, 0x40)

                // load agency value from storage
                let agency__cache := sload(agency__sptr)

                // accounts[i]
                let offerer := calldataload(accntPtr)

                // calculate offers.slot storage pointer
                mstore(add(mptr, 0x40), tokenId)
                let offer__sptr := keccak256(add(mptr, 0x40), 0x40)

                // calculate offers[tokenId].slot storage pointer
                mstore(add(mptr, 0x80), offerer)
                mstore(add(mptr, 0xa0), offer__sptr)
                offer__sptr := keccak256(add(mptr, 0x80), 0x40)

                // check if the offerer is the current agent
                switch eq(offerer, shr(96, shl(96, agency__cache)))
                case 1 {
                    let agency__epoch := shr(232, shl(2, agency__cache))

                    // ensure that the agency flag is "SWAP" (0x03)
                    if iszero(eq(shr(254, agency__cache), 0x03)) {
                        mstore8(0x0, 0x24) // ERR:0x24
                        revert(0x00, 0x01)
                    }

                    // check to make sure the user is the seller or the swap is over
                    // we know a user is a seller if the epoch is still 0
                    // we know a swap is over if the active epoch is greater than the swaps epoch
                    if iszero(or(iszero(agency__epoch), gt(active, agency__epoch))) {
                        mstore8(0x0, 0x67)
                        revert(0x00, 0x01)
                    }

                    // delete offer
                    sstore(offer__sptr, 0)

                    // update agency to reflect the new owner
                    // ==========================
                    // agency[tokenId] = {
                    //     flag  = OWN
                    //     epoch = 0
                    //     eth   = 0
                    //     addr  = offerer
                    // }
                    // ==========================
                    sstore(agency__sptr, or(offerer, shl(254, 0x01)))

                    log4(0x00, 0x00, TRANSFER, address(), offerer, tokenId)
                }
                default {
                    let offer__cache := sload(offer__sptr)

                    // ensure this user has an offer to claim
                    if iszero(offer__cache) {
                        mstore8(0x0, 0x2E)
                        revert(0x00, 0x01)
                    }

                    // delete offer before we potentially send value
                    sstore(offer__sptr, 0)

                    // if the user who placed the offer is also msg.sender
                    switch eq(caller(), offerer)
                    case 1 {
                        // accumulate and send value at once at end
                        // to save on gas for most common use case
                        acc := add(acc, shr(186, shl(26, offer__cache)))
                    }
                    default {
                        // ensure swap is no longer active
                        // the offer can only be trustlessly finalized if a swap is over as the state is final
                        if gt(active, shr(232, shl(2, offer__cache))) {
                            mstore8(0x0, 0x68)
                            revert(0x00, 0x01)
                        }

                        // parse offer value from cache
                        let amt := shr(186, shl(26, offer__cache))

                        // send offer value * LOSS to offerer
                        if iszero(call(gas(), offerer, mul(amt, LOSS), 0, 0, 0, 0)) {
                            mstore8(0x0, 0x91)
                            revert(0x00, 0x01)
                        }
                    }
                }

                log3(0x00, 0x00, CLAIM, tokenId, offerer)
            }

            // skip sending value if amount to send is 0
            if iszero(acc) {
                return(0, 0)
            }

            // send accumulated value * LOSS to msg.sender
            if iszero(call(gas(), caller(), mul(acc, LOSS), 0, 0, 0, 0)) {
                mstore8(0x0, 0x92)
                revert(0x00, 0x01)
            }
        }
    }

    /// @inheritdoc INuggftV1Swap
    function sell(uint160 tokenId, uint96 floor) external override {
        // ensure the user
        // require(isOwner(msg.sender, tokenId), hex'2A');

        require(floor >= eps(), hex'2B');

        assembly {
            let mptr := mload(0x40)

            mstore(mptr, tokenId)
            mstore(add(mptr, 0x20), agency.slot)

            let agency__sptr := keccak256(mptr, 0x40)

            let agency__cache := sload(agency__sptr)

            // ensure the caller is the agent
            if iszero(eq(shr(96, shl(96, agency__cache)), caller())) {
                mstore8(0x0, 0x2A)
                revert(0x00, 0x01)
            }

            // ensure the agent is the owner
            if iszero(eq(shr(254, agency__cache), 0x1)) {
                mstore8(0x0, 0x2C)
                revert(0x00, 0x01)
            }

            // update agency to reflect the new sale
            // ==========================
            // agency[tokenId] = {
            //     flag  = SWAP(0x03)
            //     epoch = 0
            //     eth   = seller decided floor / .1 gwei
            //     addr  = seller
            // }
            // =========================
            agency__cache := add(agency__cache, xor(shl(254, 0x02), shl(160, div(floor, LOSS))))

            sstore(agency__sptr, agency__cache)

            mstore(mptr, agency__cache)

            log2(mptr, 0x20, SELL, tokenId)
        }
    }

    // @inheritdoc INuggftV1Swap
    function check(address sender, uint160 tokenId)
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

        uint256 swapData = agency[tokenId];
        uint24 activeEpoch = epoch();

        uint256 offerData;

        if (uint160(sender) == uint160(swapData)) {
            offerData = swapData;
        } else {
            offerData = offers[tokenId][sender];
        }

        if (swapData == 0) {
            if (activeEpoch == tokenId) {
                // swap is minting
                nextSwapAmount = NuggftV1AgentType.compressEthRoundUp(msp());
            } else {
                // swap does not exist
                return (false, 0, 0);
            }
        } else {
            if (swapData.epoch() == 0 && offerData == swapData) canOffer = false;

            senderCurrentOffer = uint96(((offerData << 26) >> 186) * LOSS);

            nextSwapAmount = uint96(((swapData << 26) >> 186) * LOSS);
        }

        if (nextSwapAmount != 0) {
            nextSwapAmount = uint96((((nextSwapAmount / LOSS) * 10200) / 10000) * LOSS);
        }
    }
}
