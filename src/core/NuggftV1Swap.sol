// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {INuggftV1Swap} from '../interfaces/nuggftv1/INuggftV1Swap.sol';
import {INuggftV1ItemSwap} from '../interfaces/nuggftv1/INuggftV1ItemSwap.sol';

import {NuggftV1Stake} from './NuggftV1Stake.sol';

/// @notice mechanism for trading of nuggs between users (and items between nuggs)
/// @dev Explain to a developer any extra details
abstract contract NuggftV1Swap is INuggftV1ItemSwap, INuggftV1Swap, NuggftV1Stake {
    mapping(uint160 => mapping(address => uint256)) public offers;
    mapping(uint16 => uint256) public protocolItems;

    mapping(uint176 => mapping(uint160 => uint256)) public itemOffers;
    mapping(uint176 => uint256) public itemAgency;

    /// @inheritdoc INuggftV1Swap
    function offer(uint160 tokenId) public payable override {
        uint256 agency__sptr;

        uint256 agency__cache;
        uint256 next;

        uint256 active = epoch();
        uint256 mptr;

        address sender;
        uint256 offersSlot;

        bool isItem;

        assembly {
            function iso(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }

            function panic(code) {
                mstore8(0, code)
                revert(0, 0x01)
            }

            isItem := gt(tokenId, 0xffffff)

            // NOTE: memory locations are referenced as offsets from the free memory pointer

            // store callvalue formatted in .1 gwei for caculation of total offer
            next := div(callvalue(), LOSS)

            if iszero(gt(next, 100)) {
                panic(Error__OfferLowerThanLOSS__0xF0)
            }

            mptr := mload(0x40)

            // ========= memory ==========
            //   0x00: tokenId
            //   0x20: agency.slot
            // ===========================
            mstore(add(mptr, 0x20), agency.slot)

            sender := caller()

            offersSlot := offers.slot

            if isItem {
                sender := shr(40, tokenId)

                tokenId := and(tokenId, 0xffffffffff)

                mstore(mptr, sender)

                let buyerTokenAgency := sload(keccak256(mptr, 0x40))

                // ensure the caller is the agent
                if iszero(eq(iso(buyerTokenAgency, 96, 96), caller())) {
                    panic(Error__NotItemAgent__0x2B)
                }

                let flag := shr(254, buyerTokenAgency)

                // ensure the caller is really the agent
                if and(eq(flag, 0x3), iszero(iszero(iso(buyerTokenAgency, 2, 232)))) {
                    panic(Error__NotItemAuthorizedAgent__0x2D)
                }

                mstore(add(mptr, 0x20), itemAgency.slot)

                offersSlot := itemOffers.slot
            }

            mstore(mptr, tokenId)

            agency__sptr := keccak256(mptr, 0x40)
            agency__cache := sload(agency__sptr)
        }

        // check to see if this nugg needs to be minted
        if (active == tokenId && agency__cache == 0) {
            // [Offer:Mint]

            proofs[tokenId] = initFromSeed(calculateSeed(uint24(active)));

            // no need to update free memory pointer because we no longer rely on it being empty
            addStakedShareFromMsgValue__dirty();

            assembly {
                // init agency__cache with SWAP flag and active epoch
                // other values handled at end of function
                agency__cache := xor(shl(254, 0x03), shl(230, active))

                // ========== event ==========
                // emit Transfer(address(0), NuggftV1, tokenId)
                // ===========================

                log4(0x00, 0x00, Event__Transfer, 0, address(), tokenId)

                // update agency to reflect the new leader

                // ==== agency[tokenId] =====
                // flag  = SWAP
                // epoch = active or active + 1
                // eth   = new highest offer
                // addr  = msg.sender
                // ===========================

                agency__cache := xor(add(agency__cache, shl(160, next)), caller())

                sstore(agency__sptr, agency__cache)

                // ========= memory ==========
                // 0x00: agency__cache
                // ===========================

                mstore(mptr, agency__cache)

                // ========== event ==========
                // emit Offer(tokenId, agency__cache)
                // ===========================

                log2(mptr, 0x20, Event__Offer, tokenId)

                return(0x0, 0x00)
            }
        }

        uint256 last;

        assembly {
            function iso(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }
            function panic(code) {
                mstore8(0, code)
                revert(0, 0x01)
            }

            // ensure that the agency flag is "SWAP" (0x03)
            if iszero(eq(shr(254, agency__cache), 0x03)) {
                panic(Error__NotSwapping__0x24)
            }

            // ========= memory ==========
            //   0x00: tokenId
            //   0x20: offers.slot
            // ===========================

            mstore(add(mptr, 0x20), offersSlot)

            // ========= memory ==========
            //     0x00: tokenId
            //     0x20: offers[tokenId].slot
            // ===========================

            mstore(add(mptr, 0x20), keccak256(mptr, 0x40))

            let agency__addr := iso(agency__cache, 96, 96)

            let agency__epoch := iso(agency__cache, 2, 232)

            // ========= memory ==========
            //   0x00: msg.sender
            //   0x20: offers[tokenId].slot
            // ===========================

            mstore(mptr, sender)
            let offer__sptr := keccak256(mptr, 0x40)

            // we assume offer__cache is same as agency__cache
            // this will only be the case for the leader
            let offer__cache := agency__cache

            // check to see if msg.sender is the leader
            if iszero(eq(sender, agency__addr)) {
                // if not, we update offer__cache
                offer__cache := sload(offer__sptr)
            }

            // check to see if user has offered by checking if cache != 0
            if iszero(iszero(offer__cache)) {
                // check to see if the epoch from offer__cache has expired
                // this accomplishes two important goals:
                // 1. forces user to claim previous swap before acting on this one
                // 2. prevents owner from offering on their own swap before someone else has
                if lt(iso(offer__cache, 2, 232), active) {
                    panic(Error__InvalidEpoch__0x0F)
                }
            }

            // check to see if the swap's epoch is 0
            switch iszero(agency__epoch)
            case 1 {
                // [Offer:Commit]

                // if so, we know this swap has not yet been offered on
                // update the epoch to begin auction
                agency__cache := xor(agency__cache, shl(230, add(active, SALE_LEN)))

                if iszero(isItem) {
                    // Event__Transfer the token to the contract for the remainder of sale
                    // the seller (agency__addr) approves this when they put the token up for sale

                    // ========== event ==========
                    // emit Transfer(seller, NuggftV1, tokenId)
                    // ===========================

                    log4(0x00, 0x00, Event__Transfer, agency__addr, address(), tokenId)
                }
            }
            default {
                // [Offer:Carry]

                // otherwise we validate the epoch to ensure the swap is still active
                if lt(agency__epoch, active) {
                    panic(Error__ExpiredEpoch__0x2F)
                }
            }

            // parse last offer value
            last := iso(agency__cache, 26, 186)

            // parse and caculate next offer value
            next := add(iso(offer__cache, 26, 186), next)

            // ensure next offer includes at least a 2% increment
            if gt(div(mul(last, 10200), 10000), next) {
                panic(Error__IncrementTooLow__0x72)
            }
            // convert next into the increment
            next := sub(next, last)

            // convert last into increment * LOSS for staking
            last := mul(next, LOSS)

            /////////////////////////////////////////////////////////////////////

            // ========= memory ==========
            //   0x00: prev leader
            //   0x20: offers[tokenId].slot
            // ===========================

            mstore(mptr, agency__addr)

            sstore(keccak256(mptr, 0x40), agency__cache)

            // clear previous leader from agency cache
            agency__cache := shl(160, shr(160, agency__cache))

            /////////////////////////////////////////////////////////////////////

            // update agency to reflect the new leader

            // ==== agency[tokenId] =====
            //   flag  = SWAP
            //   epoch = active or active + 1
            //   eth   = new highest offer
            //   addr  = msg.sender
            // ===========================

            agency__cache := xor(add(agency__cache, shl(160, next)), sender)

            sstore(agency__sptr, agency__cache)

            sstore(offer__sptr, agency__cache)

            /////////////////////////////////////////////////////////////////////

            // ========= memory ==========
            //   0x00: agency__cache
            // ===========================

            mstore(mptr, agency__cache)

            switch isItem
            case 1 {
                // ========== event ==========
                // emit OfferItem(sellerTokenId, itemId, agency__cache)
                // ===========================

                log3(mptr, 0x20, Event__OfferItem, and(sender, 0xffffff), and(shr(24, tokenId), 0xffff))
            }
            default {
                // ========== event ==========
                // emit Offer(tokenId, agency__cache)
                // ===========================

                log2(mptr, 0x20, Event__Offer, tokenId)
            }
        }

        // add the increment * LOSS to staked eth
        addStakedEth__dirty(uint96(last));
    }

    /// @inheritdoc INuggftV1Swap
    function claim(uint160[] calldata tokenIds, address[] calldata accounts) public override {
        uint256 active = epoch();

        assembly {
            function panic(code) {
                mstore8(0, code)
                revert(0, 0x01)
            }
            // NOTE: memory locations are referenced as offsets from the free memory pointer

            function iso(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }

            // extract length of tokenIds array from calldata
            let len := calldataload(sub(tokenIds.offset, 0x20))

            // ensure arrays the same length
            if iszero(eq(len, calldataload(sub(accounts.offset, 0x20)))) {
                panic(Error__InvalidArrayLengths__0x99)
            }

            let acc := 0

            /*========= memory ============
              0x00: tokenId                keccak = agency[tokenId].slot = "agency__sptr"
              0x20: agency.slot
              --------------------------
              0x40: tokenId                keccak = offers[tokenId].slot
              0x60: offers.slot
              --------------------------
              0x80: offerer                keccak = offers[tokenId][offerer].slot = "offer__sptr"
              0xA0: offers[tokenId].slot
              --------------------------
              0xC0: itemId|sellingTokenId  keccak = itemAgency[itemId|sellingTokenId].slot = "agency__sptr"
              0xE0: itemAgency.slot
              --------------------------
              0x40: itemId|sellingTokenId  keccak = itemOffers[itemId|sellingTokenId].slot
              0x60: itemOffers.slot
            ==============================*/

            let mptr := mload(0x40)

            // store common slot for agency in memory
            mstore(add(mptr, 0x20), agency.slot)

            // store common slot for offers in memory
            mstore(add(mptr, 0x60), offers.slot)

            // store common slot for agency in memory
            mstore(add(mptr, 0xE0), itemAgency.slot)

            // store common slot for offers in memory
            mstore(add(mptr, 0x120), itemOffers.slot)

            for {
                let i := 0
            } lt(i, len) {
                i := add(i, 1)
            } {
                // tokenIds[i]
                let tokenId := calldataload(add(tokenIds.offset, mul(i, 0x20)))

                // accounts[i]
                let offerer := calldataload(add(accounts.offset, mul(i, 0x20)))

                let trusted_eoa := offerer

                // let isItem := gt(tokenId, 0xffffff)

                let mptroffset := 0

                if gt(tokenId, 0xffffff) {
                    // calculate agency.slot storeage ptr
                    mstore(mptr, offerer)

                    let offerer__agency := sload(keccak256(mptr, 0x40))

                    trusted_eoa := iso(offerer__agency, 96, 96)

                    mptroffset := 0xC0
                }

                // calculate agency.slot storeage ptr
                mstore(add(mptr, mptroffset), tokenId)

                let agency__sptr := keccak256(add(mptr, mptroffset), 0x40)

                // load agency value from storage
                let agency__cache := sload(agency__sptr)

                // calculate offers.slot storage pointer
                mstore(add(add(mptr, mptroffset), 0x40), tokenId)
                let offer__sptr := keccak256(add(add(mptr, mptroffset), 0x40), 0x40)

                // calculate offers[tokenId].slot storage pointer
                mstore(add(mptr, 0x80), offerer)
                mstore(add(mptr, 0xa0), offer__sptr)
                offer__sptr := keccak256(add(mptr, 0x80), 0x40)

                // check if the offerer is the current agent
                switch eq(offerer, iso(agency__cache, 96, 96))
                case 1 {
                    let agency__epoch := iso(agency__cache, 2, 232)

                    // ensure that the agency flag is "SWAP" (0x03)
                    if iszero(eq(shr(254, agency__cache), 0x03)) {
                        panic(Error__NotSwapping__0x24)
                    }

                    // check to make sure the user is the seller or the swap is over
                    // we know a user is a seller if the epoch is still 0
                    // we know a swap is over if the active epoch is greater than the swaps epoch
                    if iszero(or(iszero(agency__epoch), gt(active, agency__epoch))) {
                        panic(Error__WinningClaimTooEarly__0x67)
                    }

                    switch gt(tokenId, 0xffffff)
                    case 1 {
                        sstore(agency__sptr, 0)

                        sstore(protocolItems.slot, sub(sload(protocolItems.slot), 1))

                        // store common slot for offers in memory
                        mstore(add(mptr, 0xa0), proofs.slot)

                        let proof__sptr := keccak256(add(mptr, 0x80), 0x40)

                        let proof := sload(proof__sptr)

                        for {
                            let j := 8
                        } lt(j, 17) {
                            j := add(j, 1)
                        } {
                            if eq(j, 16) {
                                panic(Error__ProofHasNoFreeSlot__0xF9)
                            }

                            if iszero(and(shr(mul(j, 16), proof), 0xffff)) {
                                let tmp := shr(24, tokenId)
                                proof := xor(proof, shl(mul(j, 16), tmp))
                                j := 17
                            }
                        }

                        sstore(proof__sptr, proof)

                        mstore(add(mptr, 0xa0), proof)

                        log4(add(mptr, 0xa0), 0x20, Event__TransferItem, 0x00, offerer, shl(240, shr(24, tokenId)))
                    }
                    default {
                        // update agency to reflect the new owner
                        /*==== agency[tokenId] =====
                            flag  = OWN
                            epoch = 0
                            eth   = 0
                            addr  = offerer
                        ===========================*/
                        sstore(agency__sptr, or(offerer, shl(254, 0x01)))

                        // transfer token to the new owner
                        log4(0x00, 0x00, Event__Transfer, address(), offerer, tokenId)
                    }
                }
                default {
                    if iszero(eq(caller(), trusted_eoa)) {
                        panic(Error__Untrusted__0x88)
                    }

                    let offer__cache := sload(offer__sptr)

                    // ensure this user has an offer to claim
                    if iszero(offer__cache) {
                        panic(Error__NoOffer__0x2E)
                    }

                    // accumulate and send value at once at end
                    // to save on gas for most common use case
                    acc := add(acc, iso(offer__cache, 26, 186))
                }

                // delete offer before we potentially send value
                sstore(offer__sptr, 0)

                switch gt(tokenId, 0xffffff)
                case 1 {
                    log4(0x00, 0x00, Event__ClaimItem, and(tokenId, 0xffffff), shl(240, shr(24, tokenId)), offerer)
                }
                default {
                    log3(0x00, 0x00, Event__Claim, tokenId, offerer)
                }
            }

            // skip sending value if amount to send is 0
            if iszero(acc) {
                return(0, 0)
            }

            acc := mul(acc, LOSS)

            // send accumulated value * LOSS to msg.sender
            if iszero(call(gas(), caller(), acc, 0, 0, 0, 0)) {
                panic(Error__SendEthFailureToCaller__0x92)
            }
        }
    }

    /// @inheritdoc INuggftV1Swap
    function sell(uint160 tokenId, uint96 floor) public override {
        require(floor >= eps(), hex'2B');

        assembly {
            function panic(code) {
                mstore8(0, code)
                revert(0, 0x01)
            }

            function iso(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }

            let mptr := mload(0x40)

            mstore(add(mptr, 0x20), agency.slot)

            let sender := caller()

            let isItem := gt(tokenId, 0xffffff)

            if isItem {
                sender := and(tokenId, 0xffffff)

                tokenId := and(tokenId, 0xffffffffff)

                mstore(mptr, sender)

                let buyerTokenAgency := sload(keccak256(mptr, 0x40))

                // ensure the caller is the agent
                if iszero(eq(iso(buyerTokenAgency, 96, 96), caller())) {
                    panic(Error__NotItemAgent__0x2B)
                }

                let flag := shr(254, buyerTokenAgency)

                // ensure the caller is really the agent
                if and(eq(flag, 0x3), iszero(iszero(iso(buyerTokenAgency, 2, 232)))) {
                    panic(Error__NotItemAuthorizedAgent__0x2D)
                }

                mstore(add(mptr, 0x20), itemAgency.slot)
            }

            mstore(mptr, tokenId)

            let agency__sptr := keccak256(mptr, 0x40)

            let agency__cache := sload(agency__sptr)

            // update agency to reflect the new sale

            switch isItem
            case 1 {
                if iszero(iszero(agency__cache)) {
                    panic(Error__ItemAgencyAlreadySet__0x09)
                }

                mstore(mptr, sender)

                // store common slot for offers in memory
                mstore(add(mptr, 0x20), proofs.slot)

                let proof__sptr := keccak256(mptr, 0x40)

                let proof := sload(proof__sptr)

                // if iszero(proof) {
                //     mstore8(0x00, 0x33)
                // }

                let id := shr(24, tokenId)

                // start at 1 to jump over the base
                let j := 1

                for {

                } lt(j, 16) {
                    j := add(j, 1)
                } {
                    if eq(and(shr(mul(j, 16), proof), 0xffff), id) {
                        proof := and(proof, not(shl(mul(j, 16), 0xffff)))
                        break
                    }
                }

                if eq(j, 16) {
                    panic(Error__ProofDoesNotHaveItem__0x34)
                }

                sstore(protocolItems.slot, add(sload(protocolItems.slot), 1))

                sstore(proof__sptr, proof)

                mstore(mptr, proof)

                log4(mptr, 0x20, Event__TransferItem, tokenId, 0x00, shl(240, shr(24, tokenId)))

                // ==== agency[tokenId] =====
                //   flag  = SWAP(0x03)
                //   epoch = 0
                //   eth   = seller decided floor / .1 gwei
                //   addr  = seller
                // ==========================

                agency__cache := xor(xor(shl(254, 0x03), shl(160, div(floor, LOSS))), sender)

                sstore(agency__sptr, agency__cache)

                // log2 with 'Sell(uint160,bytes32)' topic
                mstore(mptr, agency__cache)

                log3(mptr, 0x20, Event__SellItem, and(tokenId, 0xffffff), shl(240, shr(24, tokenId)))
            }
            default {
                // ensure the caller is the agent
                if iszero(eq(shr(96, shl(96, agency__cache)), caller())) {
                    panic(Error__NotAgent__0x2A)
                }

                // ensure the agent is the owner
                if iszero(eq(shr(254, agency__cache), 0x1)) {
                    panic(Error__NotOwner__0xE9)
                }

                // ==== agency[tokenId] =====
                //   flag  = SWAP(0x03)
                //   epoch = 0
                //   eth   = seller decided floor / .1 gwei
                //   addr  = seller
                // ==========================

                agency__cache := add(agency__cache, xor(shl(254, 0x02), shl(160, div(floor, LOSS))))

                sstore(agency__sptr, agency__cache)

                // log2 with 'Sell(uint160,bytes32)' topic
                mstore(mptr, agency__cache)

                log2(mptr, 0x20, Event__Sell, tokenId)
            }
        }
    }

    /// @inheritdoc INuggftV1Swap
    function vfo(address sender, uint160 tokenId) public view override returns (uint96 res) {
        (bool canOffer, uint96 nextSwapAmount, uint96 senderCurrentOffer) = check(sender, tokenId);

        if (canOffer) {
            return nextSwapAmount - senderCurrentOffer;
        }
    }

    // @inheritdoc INuggftV1Swap
    function check(address sender, uint160 tokenId)
        public
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
                nextSwapAmount = msp();
            } else {
                // swap does not exist
                return (false, 0, 0);
            }
        } else {
            if ((swapData >> 230) & 0xffffff == 0 && offerData == swapData) canOffer = false;

            senderCurrentOffer = uint96(((offerData << 26) >> 186) * LOSS);

            nextSwapAmount = uint96(((swapData << 26) >> 186) * LOSS);
        }

        if (nextSwapAmount != 0) {
            nextSwapAmount = uint96((((nextSwapAmount / LOSS) * 10200) / 10000) * LOSS);
        } else {
            nextSwapAmount = 100 gwei;
        }
    }

    /// @inheritdoc INuggftV1ItemSwap
    function offer(
        uint160 buyingTokenId,
        uint160 sellingTokenId,
        uint16 itemId
    ) external payable override {
        offer((buyingTokenId << 40) | (uint160(itemId) << 24) | sellingTokenId);
    }

    /// @inheritdoc INuggftV1ItemSwap
    function claim(uint160[] calldata sellingTokenItemIds, uint160[] calldata buyerTokenIds) public {
        address[] calldata tmp;
        assembly {
            tmp.offset := buyerTokenIds.offset
        }
        claim(sellingTokenItemIds, tmp);
    }

    /// @inheritdoc INuggftV1ItemSwap
    function sell(
        uint160 sellingTokenId,
        uint16 itemId,
        uint96 floor
    ) external override {
        sell((uint160(itemId) << 24) | sellingTokenId, floor);
    }

    /// @inheritdoc INuggftV1ItemSwap
    function vfo(
        uint160 buyer,
        uint160 seller,
        uint16 itemId
    ) public view override returns (uint96 res) {
        (bool canOffer, uint96 nextSwapAmount, uint96 senderCurrentOffer) = check(buyer, seller, itemId);

        if (canOffer) {
            return nextSwapAmount - senderCurrentOffer;
        }
    }

    /// @inheritdoc INuggftV1ItemSwap
    function check(
        uint160 buyer,
        uint160 seller,
        uint16 itemId
    )
        public
        view
        override
        returns (
            bool canOffer,
            uint96 nextSwapAmount,
            uint96 senderCurrentOffer
        )
    {
        canOffer = true;

        uint176 sellerItemId = (uint176(itemId) << 24) | seller;

        uint256 agency__cache = itemAgency[sellerItemId];

        uint256 offerData = agency__cache;

        if (buyer != uint160(agency__cache)) {
            offerData = itemOffers[sellerItemId][buyer];
        }

        if (uint24(agency__cache >> 230) == 0 && offerData == agency__cache) canOffer = false;

        senderCurrentOffer = uint96((offerData << 26) >> 186);

        nextSwapAmount = uint96((agency__cache << 26) >> 186);

        if (nextSwapAmount != 0) {
            nextSwapAmount = uint96(nextSwapAmount * 102 * LOSS) / 100;
        } else {
            nextSwapAmount = 100 gwei;
        }
    }
}
