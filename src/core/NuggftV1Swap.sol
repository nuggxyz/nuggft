// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {INuggftV1Swap} from '../interfaces/nuggftv1/INuggftV1Swap.sol';
import {INuggftV1ItemSwap} from '../interfaces/nuggftv1/INuggftV1ItemSwap.sol';

import {NuggftV1Stake} from './NuggftV1Stake.sol';

// import '../_test/utils/forge.sol';

/// @notice mechanism for trading of nuggs between users (and items between nuggs)
/// @dev Explain to a developer any extra details
abstract contract NuggftV1Swap is INuggftV1ItemSwap, INuggftV1Swap, NuggftV1Stake {
    mapping(uint160 => mapping(address => uint256)) public offers;
    // mapping(uint16 => uint256) public protocolItems;

    mapping(uint176 => mapping(uint160 => uint256)) public itemOffers;
    mapping(uint176 => uint256) public itemAgency;

    // uint256 hotproof = 1;

    constructor() {
        for (uint8 i = 0; i < HOT_PROOF_AMOUNT; i++) hotproof[i] = 0x10000;
    }

    /// @inheritdoc INuggftV1Swap
    function offer(uint160 tokenId) public payable override {
        // gas.run memory a = gas.start('A: begin');

        uint256 agency__sptr;
        uint256 agency__cache;

        uint256 next;
        uint256 active = epoch();

        address sender;
        uint256 offersSlot;

        bool isItem;
        uint256 last;
        // gas.stop(a);
        // a = gas.start('B: begin');

        assembly {
            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore8(31, code)
                revert(27, 0x5)
            }

            // store callvalue formatted in .1 gwei for caculation of total offer
            next := div(callvalue(), LOSS)

            if iszero(gt(next, 100)) {
                panic(Error__0x68__OfferLowerThanLOSS)
            }

            mstore(0x20, agency.slot)

            isItem := gt(tokenId, 0xffffff)

            switch isItem
            case 1 {
                sender := shr(40, tokenId)

                tokenId := and(tokenId, 0xffffffffff)

                mstore(0x00, sender)

                let buyerTokenAgency := sload(keccak256(0x00, 0x40))

                // ensure the caller is the agent
                if iszero(eq(juke(buyerTokenAgency, 96, 96), caller())) {
                    panic(Error__0xA2__NotItemAgent)
                }

                let flag := shr(254, buyerTokenAgency)

                // ensure the caller is really the agent
                if and(eq(flag, 0x3), iszero(iszero(juke(buyerTokenAgency, 2, 232)))) {
                    panic(Error__0xA3__NotItemAuthorizedAgent)
                }

                mstore(0x20, itemAgency.slot)

                offersSlot := itemOffers.slot
            }
            default {
                sender := caller()

                offersSlot := offers.slot
            }

            mstore(0x00, tokenId)

            agency__sptr := keccak256(0x00, 0x40)
            agency__cache := sload(agency__sptr)
        }
        // gas.stop(a);

        // check to see if this nugg needs to be minted
        if (active == tokenId && agency__cache == 0) {
            // [Offer:Mint]
            // a = gas.start('1: initFromSeed');

            uint256 proof = initFromSeed(calculateSeed(uint24(active)));
            // gas.stop(a);

            // a = gas.start('2: sstore(proof)');
            // ds.inject.logBytes32(bytes32(hotproof[uint8(tokenId % 32)]));
            uint256 hotproof__cache = hotproof[uint8(tokenId % 32)];

            // if hot slot 1 is open, save there
            if ((hotproof__cache & 0xffff) == 0) {
                hotproof[uint8(tokenId % HOT_PROOF_AMOUNT)] = proof;
            } else {
                proofs[tokenId] = proof;
            }
            // ds.inject.logBytes32(bytes32(hotproof[uint8(tokenId % 32)]));

            // otherwise this
            // gas.stop(a);

            // a = gas.start('3: addStakedShareFromMsgValue');
            addStakedShareFromMsgValue();
            // gas.stop(a);

            // a = gas.start('4: assembly');

            // prettier-ignore
            assembly {

                // save the updated agency
                agency__cache := xor(xor(xor( // =============================
                          /* addr     0       [ */ caller(), /* ] 160 */
                    shl(  /* eth   */ 160, /* [ */ next      /* ] 230 */ )),
                    shl(  /* epoch */ 230, /* [ */ active    /* ] 254 */ )),
                    shl(  /* flag  */ 254, /* [ */ 0x03      /* ] 255 */ )
                ) // ==========================================================

                // log the updated agency
                mstore(0x00, agency__cache) // =================================
                mstore(0x20, proof) // =================================

                log2( // -------------------------------------------------------
                    /* param #1:agency  */ 0x00, /* [ agency[tokenId] ]    0x20,
                       param #1:proof      0x20,    [ proof[tokenId]  ] */ 0x40,
                    /* topic #1:sig     */ Event__OfferMint,
                    /* topic #2:tokenId */ tokenId
                ) // ===========================================================

                log4( // =======================================================
                    /* param #0:n/a  */ 0x00, /* [ n/a ] */  0x00,
                    /* topic #1:sig  */ Event__Transfer,
                    /* topic #2:from */ 0,
                    /* topic #3:to   */ address(),
                    /* topic #4:id   */ tokenId
                ) // ===========================================================

                sstore(agency__sptr, agency__cache)

                // return(0x0, 0x00)
            }
            // gas.stop(a);

            return;
        }

        // prettier-ignore
        assembly {
            function juke(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }

            function mask(val, shift, size) -> b {
                b := and(shr(shift, val), sub(shl(size, 1),1))
            }

            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore8(31, code)
                revert(27, 0x5)
            }

            // ensure that the agency flag is "SWAP" (0x03)
            if iszero(eq(shr(254, agency__cache), 0x03)) {
                panic(Error__0xA0__NotSwapping)
            }

            /////////////////////////////////////////////////////////////////////

            mstore(0x20, offersSlot)

            mstore(0x20, keccak256( // =================================
                0x00, /* [ tokenId                 ]    0x20
                0x20     [ offers[X].slot          ] */ 0x40
            ))// =======================================================

            mstore(0x00, sender)

            let offer__sptr := keccak256( // ===========================
                0x00, /* [ msg.sender              ]    0x20
                0x20     [ offers[X].slot          ] */ 0x40
            )// ========================================================

            /////////////////////////////////////////////////////////////////////

            let agency__addr  := mask(agency__cache, 0, 160)

            let agency__epoch := mask(agency__cache, 230, 24)

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
                if lt(juke(offer__cache, 2, 232), active) {
                    panic(Error__0x99__InvalidEpoch)
                }
            }

            /////////////////////////////////////////////////////////////////////

            // check to see if the swap's epoch is 0, make required updates

            switch iszero(agency__epoch)

            case 1 { // [Offer:Commit]

                // if so, we know this swap has not yet been offered on

                // update the epoch to begin auction
                agency__cache := xor( // =====================================
                    /* start */  agency__cache,
                    // -------------------------------------------------------
                        /* addr     0       [                             ] 160 */
                        /* eth      160,    [                             ] 230 */
                   shl( /* epoch */ 230, /* [ */ add(active, SALE_LEN) /* ] 254 */ )
                        /* flag     254,    [                             ] 255 */
                ) // ==========================================================

                if iszero(isItem) {
                    // Event__Transfer the token to the contract for the remainder of sale
                    // the seller (agency__addr) approves this when they put the token up for sale

                    log4( // =======================================================
                        /* param #0:n/a  */ 0x00, /* [       n/a      ] */ 0x00,
                        /* topic #1:sig  */ Event__Transfer,
                        /* topic #2:from */ agency__addr,
                        /* topic #3:to   */ address(),
                        /* topic #4:id   */ tokenId
                    ) // ===========================================================
                }
            }


            default { // [Offer:Carry]

                // otherwise we validate the epoch to ensure the swap is still active
                // baisically, "is the auction's epoch in the past?"
                // - if yes, we revert

                if lt(agency__epoch, active) {
                    panic(Error__0xA4__ExpiredEpoch)
                }
            }

            /////////////////////////////////////////////////////////////////////

            // parse last offer value
            last := juke(agency__cache, 26, 186)

            // parse and caculate next offer value
            next := add(juke(offer__cache, 26, 186), next)

            // ensure next offer includes at least a 2% increment
            if gt(div(mul(last, 10200), 10000), next) {
                panic(Error__0x72__IncrementTooLow)
            }
            // convert next into the increment
            next := sub(next, last)

            // convert last into increment * LOSS for staking
            last := mul(next, LOSS)

            /////////////////////////////////////////////////////////////////////

            // we update the previous user's "offer" so we
            //  1. know how much to repay them
            //  2. know how much they have already bid

            mstore(0x00, agency__addr)

            // calculate the previous leaders offer storage pointer and set it to agency__cache
            sstore( keccak256( //-------------------------------------------------
                0x00, /* [ address(prev leader)                  ]    0x20
                0x20     [ offers[X].slot                        ] */ 0x40
            ), agency__cache) // ---------------------------------------------

            // after we save the prevous state, we clear the previous leader from agency cache
            agency__cache := shl(160, shr(160, agency__cache))

            /////////////////////////////////////////////////////////////////////

            agency__cache := add(xor(// ========================================
                /* start  */ agency__cache,
                // -------------------------------------------------------------
                    /* addr     0       [ */ sender /* ] 160 */ ),
               shl( /* eth   */ 160, /* [ */ next   /* ] 230 */ )
                    /* epoch    230     [              ] 254 */
                    /* addr     254     [              ] 255 */
            ) // ===============================================================

            sstore(agency__sptr, agency__cache)

            sstore(offer__sptr, agency__cache)

            mstore(0x00, agency__cache)

            switch isItem
            case 1 {
                log3( // =======================================================
                    /* param #1:agency   */ 0x00, /* [ itemAgency[tokenId][itemId] ] */  0x20,
                    /* topic #1:sig      */ Event__OfferItem,
                    /* topic #2:sellerId */ and(sender, 0xffffff),
                    /* topic #3:buyerId  */ and(shr(24, tokenId), 0xffff)
                ) // ===========================================================
            }
            default {
                log2( // =======================================================
                    /* param #1:agency  */ 0x00, /* [ agency[tokenId] ] */ 0x20,
                    /* topic #1:sig     */ Event__Offer,
                    /* topic #2:tokenId */ tokenId
                ) // ===========================================================
            }
        }

        // add the increment * LOSS to staked eth
        addStakedEth(uint96(last));
    }

    /// @inheritdoc INuggftV1Swap
    function claim(uint160[] calldata tokenIds, address[] calldata accounts) public override {
        uint256 active = epoch();

        // prettier-ignore
        assembly {
            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore8(31, code)
                revert(27, 0x5)
            }

            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            // extract length of tokenIds array from calldata
            let len := calldataload(sub(tokenIds.offset, 0x20))

            // ensure arrays the same length
            if iszero(eq(len, calldataload(sub(accounts.offset, 0x20)))) {
                panic(Error__0x76__InvalidArrayLengths)
            }

            let acc := 0

            /*========= memory ============
              0x00: tokenId
              0x20: agency.slot
              [keccak]: agency[tokenId].slot = "agency__sptr"
              --------------------------
              0x40: tokenId
              0x60: offers.slot
              [keccak]: offers[tokenId].slot = "offer__sptr"
              --------------------------
              0x80: offerer
              0xA0: offers[tokenId].slot
              [keccak]: itemOffers[tokenId][offerer].slot = "offer__sptr"
              --------------------------
              0xC0: itemId || sellingTokenId
              0xE0: itemAgency.slot
              [keccak]: itemAgency[itemId || sellingTokenId].slot = "agency__sptr"
              --------------------------
              0x100: itemId|sellingTokenId
              0x120: itemOffers.slot
              [keccak]: itemOffers[itemId||sellingTokenId].slot
            ==============================*/

            // store common slot for agency in memory
            mstore(0x20, agency.slot)

            // store common slot for offers in memory
            mstore(0x60, offers.slot)

            // store common slot for agency in memory
            mstore(0xE0, itemAgency.slot)

            // store common slot for offers in memory
            mstore(0x120, itemOffers.slot)

            // store common slot for proof in memory
            mstore(0x160, proofs.slot)

            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                // tokenIds[i]
                let tokenId := calldataload(add(tokenIds.offset, shl(5, i)))

                // accounts[i]
                let offerer := calldataload(add(accounts.offset, shl(5, i)))

                //
                let trusted := offerer

                let isItem := gt(tokenId, 0xffffff)

                let mptroffset := 0

                if isItem {

                    // if this claim is for an item aucton we need to check the nugg that is
                    // + claiming and set their owner as the "trusted"

                    mstore(0x00, offerer)

                    let offerer__agency := sload(keccak256(0x00, 0x40))

                    trusted := juke(offerer__agency, 96, 96)

                    mptroffset := 0xC0
                }

                // calculate agency.slot storeage ptr
                mstore(mptroffset, tokenId)

                let agency__sptr := keccak256(mptroffset, 0x40)

                // load agency value from storage
                let agency__cache := sload(agency__sptr)

                // calculate offers.slot storage pointer
                mstore(add(mptroffset, 0x40), tokenId)
                let offer__sptr := keccak256(add(mptroffset, 0x40), 0x40)

                // calculate offers[tokenId].slot storage pointer
                mstore(0x80, offerer)
                mstore(0xa0, offer__sptr)
                offer__sptr := keccak256(0x80, 0x40)

                mstore(0xA0, proofs.slot)

                // check if the offerer is the current agent ()
                switch eq(offerer, juke(agency__cache, 96, 96))
                case 1 {
                    let agency__epoch := juke(agency__cache, 2, 232)

                    // ensure that the agency flag is "SWAP" (0x03)
                    // importantly, this only needs to be done for "winning" claims,
                    // + otherwise
                    if iszero(eq(shr(254, agency__cache), 0x03)) {
                        panic(Error__0xA0__NotSwapping)
                    }

                    // check to make sure the user is the seller or the swap is over
                    // we know a user is a seller if the epoch is still 0
                    // we know a swap is over if the active epoch is greater than the swaps epoch
                    if iszero(or(iszero(agency__epoch), gt(active, agency__epoch))) {
                        panic(Error__0x67__WinningClaimTooEarly)
                    }

                    switch isItem
                    case 1 {
                        sstore(agency__sptr, 0)

                        // sstore(protocolItems.slot, sub(sload(protocolItems.slot), 1))

                        let proof__sptr := keccak256(0x80, 0x40)

                        let proof := sload(proof__sptr)

                        // prettier-ignore
                        for { let j := 8 } lt(j, 17) { j := add(j, 1) } {
                            if eq(j, 16) { panic(Error__0x79__ProofHasNoFreeSlot) }

                            if iszero(and(shr(mul(j, 16), proof), 0xffff)) {
                                let tmp := shr(24, tokenId)
                                proof := xor(proof, shl(mul(j, 16), tmp))
                                break
                            }
                        }

                        sstore(proof__sptr, proof)

                        mstore(0xA0, proof)

                        log4(0xA0, 0x20, Event__TransferItem, 0x00, offerer, shl(240, shr(24, tokenId)))
                    }
                    default {

                        let proof__sptr := keccak256(0x80, 0x40)

                        if iszero(sload(proof__sptr)) {
                            mstore(0xA0, hotproof.slot)
                            mstore(0x80, mod(tokenId, HOT_PROOF_AMOUNT))
                            let hotproof__sptr := keccak256(0x80, 0x40)
                            sstore(proof__sptr, sload(hotproof__sptr))
                            sstore(hotproof__sptr, 0x10000)
                        }

                        // if either exists for this token, set the proof

                        // save the updated agency
                        sstore(agency__sptr, xor( // =============================
                                /* addr     0       [ */ offerer, /*  ] 160 */
                                /* eth      160,    [    next         ] 230 */
                                /* epoch    230,    [    active       ] 254 */
                           shl( /* flag  */ 254, /* [ */ 0x01      /* ] 255 */ ))
                        ) // ==========================================================

                        // "transfer" token to the new owner
                        log4( // =======================================================
                            /* param #0:n/a  */ 0x00, /* [ n/a ] */  0x00,
                            /* topic #1:sig  */ Event__Transfer,
                            /* topic #2:from */ address(),
                            /* topic #3:to   */ offerer,
                            /* topic #4:id   */ tokenId
                        ) // ===========================================================
                    }
                }
                default {
                    if iszero(eq(caller(), trusted)) {
                        panic(Error__0x74__Untrusted)
                    }

                    let offer__cache := sload(offer__sptr)

                    // ensure this user has an offer to claim
                    if iszero(offer__cache) {
                        panic(Error__0xA5__NoOffer)
                    }

                    // accumulate and send value at once at end
                    // to save on gas for most common use case
                    acc := add(acc, juke(offer__cache, 26, 186))
                }

                // delete offer before we potentially send value
                sstore(offer__sptr, 0)

                switch isItem
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
                // if someone really ends up here, just donate the eth
                sstore(stake.slot, add(sload(stake.slot), shl(96, acc)))
            }
        }
    }

    function claim2(uint160[] calldata offerIds) public {
        uint256 active = epoch();

        // prettier-ignore
        assembly {
            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore8(31, code)
                revert(27, 0x5)
            }

            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            // extract length of tokenIds array from calldata
            let len := calldataload(sub(offerIds.offset, 0x20))

            let acc := 0

            /*========= memory ============
              0x00: tokenId
              0x20: agency.slot
              [keccak]: agency[tokenId].slot = "agency__sptr"
              --------------------------
              0x40: tokenId
              0x60: offers.slot
              [keccak]: offers[tokenId].slot = "offer__sptr"
              --------------------------
              0x80: offerer
              0xA0: offers[tokenId].slot
              [keccak]: itemOffers[tokenId][offerer].slot = "offer__sptr"
              --------------------------
              0xC0: itemId || sellingTokenId
              0xE0: itemAgency.slot
              [keccak]: itemAgency[itemId || sellingTokenId].slot = "agency__sptr"
              --------------------------
              0x100: itemId|sellingTokenId
              0x120: itemOffers.slot
              [keccak]: itemOffers[itemId||sellingTokenId].slot
            ==============================*/

            // store common slot for agency in memory
            mstore(0x20, agency.slot)

            // store common slot for offers in memory
            mstore(0x60, offers.slot)

            // store common slot for agency in memory
            mstore(0xE0, itemAgency.slot)

            // store common slot for offers in memory
            mstore(0x120, itemOffers.slot)

            // store common slot for proof in memory
            mstore(0x160, proofs.slot)

            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                // tokenIds[i]
                let offerId := calldataload(add(offerIds.offset, shl(5, i)))

                // accounts[i]
                let offerer := caller()

                let trusted := offerer

                let isItem := gt(offerId, 0xffffff)

                let mptroffset := 0

                if isItem {

                    offerer := shr(40, offerId)

                    if iszero(offerer) {
                        panic(Error__0x78__TokenDoesNotExist)
                    }

                    // if this claim is for an item aucton we need to check the nugg that is
                    // + claiming and set their owner as the "trusted"

                    mstore(0x00, offerer)

                    let offerer__agency := sload(keccak256(0x00, 0x40))

                    trusted := eq(juke(offerer__agency, 96, 96), caller())

                    mptroffset := 0xC0
                }

                // calculate agency.slot storeage ptr
                mstore(mptroffset, offerId)

                let agency__sptr := keccak256(mptroffset, 0x40)

                // load agency value from storage
                let agency__cache := sload(agency__sptr)

                // calculate offers.slot storage pointer
                mstore(add(mptroffset, 0x40), offerId)
                let offer__sptr := keccak256(add(mptroffset, 0x40), 0x40)

                let agency__epoch := juke(agency__cache, 2, 232)

                let agent := juke(agency__cache, 96, 96)

                mstore(0xa0, offer__sptr)

                // check if the offerer is the current agent ()
                if  and(eq(shr(254, agency__cache), 0x03), or(and(iszero(agency__epoch), iszero(eq(offerer, agent))), gt(active, agency__epoch))) {

                    mstore(0x80, agent)

                    sstore(keccak256(0x80, 0x40), 0)

                    mstore(0xA0, proofs.slot)

                    switch isItem
                    case 1 {
                        sstore(agency__sptr, 0)

                        let proof__sptr := keccak256(0x80, 0x40)

                        let proof := sload(proof__sptr)

                        // prettier-ignore
                        for { let j := 8 } lt(j, 17) { j := add(j, 1) } {
                            if eq(j, 16) { panic(Error__0x79__ProofHasNoFreeSlot) }

                            if iszero(and(shr(mul(j, 16), proof), 0xffff)) {
                                let tmp := shr(24, offerId)
                                proof := xor(proof, shl(mul(j, 16), tmp))
                                break
                            }
                        }

                        sstore(proof__sptr, proof)

                        mstore(0xA0, proof)

                        log4(0xA0, 0x20, Event__TransferItem, 0x00, agent, shl(240, shr(24, offerId)))

                        log4(0x00, 0x00, Event__ClaimItem, and(offerId, 0xffffff), shl(240, shr(24, offerId)), agent)
                    }
                    default {

                        let proof__sptr := keccak256(0x80, 0x40)

                        if iszero(sload(proof__sptr)) {
                            mstore(0xA0, hotproof.slot)
                            mstore(0x80, mod(offerId, HOT_PROOF_AMOUNT))
                            let hotproof__sptr := keccak256(0x80, 0x40)
                            sstore(proof__sptr, sload(hotproof__sptr))
                            sstore(hotproof__sptr, 0x10000)
                        }

                        // if either exists for this token, set the proof

                        // save the updated agency
                        sstore(agency__sptr, xor( // =============================
                                /* addr     0       [ */ agent, /*  ] 160 */
                                /* eth      160,    [    next         ] 230 */
                                /* epoch    230,    [    active       ] 254 */
                           shl( /* flag  */ 254, /* [ */ 0x01      /* ] 255 */ ))
                        ) // ==========================================================

                        // "transfer" token to the new owner
                        log4( // =======================================================
                            /* param #0:n/a  */ 0x00, /* [ n/a ] */  0x00,
                            /* topic #1:sig  */ Event__Transfer,
                            /* topic #2:from */ address(),
                            /* topic #3:to   */ agent,
                            /* topic #4:id   */ offerId
                        ) // ===========================================================

                        log3(0x00, 0x00, Event__Claim, offerId, offerer)
                    }

                }

                // calculate offers[offerId].slot storage pointer
                mstore(0x80, offerer)

                offer__sptr := keccak256(0x80, 0x40)

                let offer__cache := sload(offer__sptr)

                // ensure this user has an offer to claim
                if iszero(offer__cache) {
                    continue
                }

                if and(isItem, iszero(trusted)) {
                    panic(Error__0x74__Untrusted)
                }

                if eq(juke(offer__cache, 96, 96), agent) {
                    panic(Error__0x67__WinningClaimTooEarly)
                }

                // delete offer before we potentially send value
                sstore(offer__sptr, 0)

                // accumulate and send value at once at end
                // to save on gas for most common use case
                acc := add(acc, juke(offer__cache, 26, 186))

                switch isItem
                case 1 {
                    log4(0x00, 0x00, Event__ClaimItem, and(offerId, 0xffffff), shl(240, shr(24, offerId)), offerer)
                }
                default {
                    log3(0x00, 0x00, Event__Claim, offerId, offerer)
                }
            }

            // skip sending value if amount to send is 0
            if iszero(acc) {
                return(0, 0)
            }

            acc := mul(acc, LOSS)

            // send accumulated value * LOSS to msg.sender
            if iszero(call(gas(), caller(), acc, 0, 0, 0, 0)) {
                // if someone really ends up here, just donate the eth
                sstore(stake.slot, add(sload(stake.slot), shl(96, acc)))
            }
        }
    }

    // function claim2(uint160[] calldata tokenIds) public {
    //     uint256 active = epoch();

    //     assembly {
    //         function panic(code) {
    //             mstore(0x00, Revert__Sig)
    //             mstore8(31, code)
    //             revert(27, 0x5)
    //         }

    //         function juke(x, L, R) -> b {
    //             b := shr(R, shl(L, x))
    //         }

    //         // extract length of tokenIds array from calldata
    //         let len := calldataload(sub(tokenIds.offset, 0x20))

    //         // // ensure arrays the same length
    //         // if iszero(eq(len, calldataload(sub(accounts.offset, 0x20)))) {
    //         //     panic(Error__0x76__InvalidArrayLengths)
    //         // }

    //         let acc := 0

    //         /*========= memory ============
    //           0x00: tokenId
    //           0x20: agency.slot
    //           [keccak]: agency[tokenId].slot = "agency__sptr"
    //           --------------------------
    //           0x40: tokenId
    //           0x60: offers.slot
    //           [keccak]: offers[tokenId].slot = "offer__sptr"
    //           --------------------------
    //           0x80: offerer
    //           0xA0: offers[tokenId].slot
    //           [keccak]: itemOffers[tokenId][offerer].slot = "offer__sptr"
    //           --------------------------
    //           0xC0: itemId || sellingTokenId
    //           0xE0: itemAgency.slot
    //           [keccak]: itemAgency[itemId || sellingTokenId].slot = "agency__sptr"
    //           --------------------------
    //           0x100: itemId|sellingTokenId
    //           0x120: itemOffers.slot
    //           [keccak]: itemOffers[itemId||sellingTokenId].slot
    //         ==============================*/

    //         // store common slot for agency in memory
    //         mstore(0x20, agency.slot)

    //         // store common slot for offers in memory
    //         mstore(0x60, offers.slot)

    //         // store common slot for agency in memory
    //         mstore(0xE0, itemAgency.slot)

    //         // store common slot for offers in memory
    //         mstore(0x120, itemOffers.slot)

    //         // store common slot for proof in memory
    //         mstore(0x160, proofs.slot)

    //         for {
    //             let i := 0
    //         } lt(i, len) {
    //             i := add(i, 1)
    //         } {
    //             // tokenIds[i]
    //             let tokenId := calldataload(add(tokenIds.offset, shl(5, i)))

    //             let isItem := gt(tokenId, 0xffffff)

    //             let mptroffset := 0

    //             let sender := caller()

    //             let trust := 0

    //             if isItem {
    //                 sender := shr(40, tokenId)

    //                 mstore(0x00, sender)

    //                 let offerer__agency := sload(keccak256(0x00, 0x40))

    //                 trust := eq(caller(), juke(offerer__agency, 96, 96))

    //                 tokenId := and(tokenId, 0xffffffffff)

    //                 mptroffset := 0xC0
    //             }

    //             // calculate agency.slot storeage ptr
    //             mstore(mptroffset, tokenId)

    //             let agency__sptr := keccak256(mptroffset, 0x40)

    //             // load agency value from storage
    //             let agency__cache := sload(agency__sptr)

    //             // if it is marked as a swap -
    //             // -- and the user is the agent
    //             // -- and the swap is over or not started
    //             // then complete the trade

    //             if eq(shr(254, agency__cache), 0x03) {
    //                 let agency__epoch := juke(agency__cache, 2, 232)
    //                 let agency__addr := juke(agency__cache, 96, 96)

    //                 // calculate offers.slot storage pointer
    //                 mstore(add(mptroffset, 0x40), tokenId)
    //                 let offer__sptr := keccak256(add(mptroffset, 0x40), 0x40)

    //                 // calculate offers[tokenId].slot storage pointer
    //                 mstore(0x80, sender)
    //                 mstore(0xa0, offer__sptr)
    //                 offer__sptr := keccak256(0x80, 0x40)

    //                 if or(iszero(agency__epoch), gt(active, agency__epoch)) {

    //                     switch isItem
    //                     case 1 {
    //                         sstore(agency__sptr, 0)

    //                         let proof__sptr := keccak256(0x80, 0x40)

    //                         let proof := sload(proof__sptr)

    //                         // prettier-ignore
    //                         for { let j := 8 } lt(j, 17) { j := add(j, 1) } {
    //                             if eq(j, 16) { panic(Error__0x79__ProofHasNoFreeSlot) }

    //                             if iszero(and(shr(mul(j, 16), proof), 0xffff)) {
    //                                 let tmp := shr(24, tokenId)
    //                                 proof := xor(proof, shl(mul(j, 16), tmp))
    //                                 break
    //                             }
    //                         }

    //                         sstore(proof__sptr, proof)

    //                         mstore(0xA0, proof)

    //                         log4(0xA0, 0x20, Event__TransferItem, 0x00, agency__addr, shl(240, shr(24, tokenId)))
    //                     }
    //                     default {
    //                         let proof__sptr := keccak256(0x80, 0x40)

    //                         if iszero(sload(proof__sptr)) {
    //                             mstore(0xA0, hotproof.slot)
    //                             mstore(0x80, mod(tokenId, HOT_PROOF_AMOUNT))
    //                             let hotproof__sptr := keccak256(0x80, 0x40)
    //                             sstore(proof__sptr, sload(hotproof__sptr))
    //                             sstore(hotproof__sptr, 0x10000)
    //                         }

    //                         // if either exists for this token, set the proof

    //                         // save the updated agency
    //                         sstore(
    //                             agency__sptr,
    //                             xor(
    //                                 // =============================
    //                                 /* addr     0       [ */
    //                                 agency__addr, /*  ] 160 */
    //                                 /* eth      160,    [    next         ] 230 */
    //                                 /* epoch    230,    [    active       ] 254 */
    //                                 shl(
    //                                     /* flag  */
    //                                     254,
    //                                     /* [ */
    //                                     0x01 /* ] 255 */
    //                                 )
    //                             )
    //                         ) // ==========================================================

    //                         // "transfer" token to the new owner
    //                         log4(
    //                             // =======================================================
    //                             /* param #0:n/a  */
    //                             0x00,
    //                             /* [ n/a ] */
    //                             0x00,
    //                             /* topic #1:sig  */
    //                             Event__Transfer,
    //                             /* topic #2:from */
    //                             address(),
    //                             /* topic #3:to   */
    //                             agency__addr,
    //                             /* topic #4:id   */
    //                             tokenId
    //                         ) // ===========================================================
    //                     }
    //                 }
    //             }

    //             // calculate offers.slot storage pointer
    //             mstore(add(mptroffset, 0x40), tokenId)
    //             let offer__sptr := keccak256(add(mptroffset, 0x40), 0x40)

    //             // calculate offers[tokenId].slot storage pointer
    //             mstore(0x80, sender)
    //             mstore(0xa0, offer__sptr)
    //             offer__sptr := keccak256(0x80, 0x40)

    //             let offer__cache := sload(offer__sptr)

    //             // ensure this user has an offer to claim
    //             if iszero(offer__cache) {
    //                 continue
    //             }

    //             mstore(0xA0, proofs.slot)

    //             if isItem {
    //                 if iszero(trust) {
    //                     panic(Error__0x74__Untrusted)
    //                 }
    //             }

    //             // accumulate and send value at once at end
    //             // to save on gas for most common use case
    //             acc := add(acc, juke(offer__cache, 26, 186))

    //             // delete offer before we potentially send value
    //             sstore(offer__sptr, 0)

    //             switch isItem
    //             case 1 {
    //                 log4(0x00, 0x00, Event__ClaimItem, and(tokenId, 0xffffff), shl(240, shr(24, tokenId)), sender)
    //             }
    //             default {
    //                 log3(0x00, 0x00, Event__Claim, tokenId, sender)
    //             }
    //         }

    //         // skip sending value if amount to send is 0
    //         if iszero(acc) {
    //             return(0, 0)
    //         }

    //         acc := mul(acc, LOSS)

    //         // send accumulated value * LOSS to msg.sender
    //         if iszero(call(gas(), caller(), acc, 0, 0, 0, 0)) {
    //             // if someone really ends up here, just donate the eth
    //             sstore(stake.slot, add(sload(stake.slot), shl(96, acc)))
    //         }
    //     }
    // }

    //     function claim3(uint64[] calldata offerIds) public {
    //     uint256 active = epoch();

    //     assembly {
    //         function panic(code) {
    //             mstore(0x00, Revert__Sig)
    //             mstore8(31, code)
    //             revert(27, 0x5)
    //         }

    //         function juke(x, L, R) -> b {
    //             b := shr(R, shl(L, x))
    //         }

    //         // extract length of tokenIds array from calldata
    //         let len := calldataload(sub(offerIds.offset, 0x20))

    //         // // ensure arrays the same length
    //         // if iszero(eq(len, calldataload(sub(accounts.offset, 0x20)))) {
    //         //     panic(Error__0x76__InvalidArrayLengths)
    //         // }

    //         let acc := 0

    //         /*========= memory ============
    //           0x00: tokenId
    //           0x20: agency.slot
    //           [keccak]: agency[tokenId].slot = "agency__sptr"
    //           --------------------------
    //           0x40: tokenId
    //           0x60: offers.slot
    //           [keccak]: offers[tokenId].slot = "offer__sptr"
    //           --------------------------
    //           0x80: offerer
    //           0xA0: offers[tokenId].slot
    //           [keccak]: itemOffers[tokenId][offerer].slot = "offer__sptr"
    //           --------------------------
    //           0xC0: itemId || sellingTokenId
    //           0xE0: itemAgency.slot
    //           [keccak]: itemAgency[itemId || sellingTokenId].slot = "agency__sptr"
    //           --------------------------
    //           0x100: itemId|sellingTokenId
    //           0x120: itemOffers.slot
    //           [keccak]: itemOffers[itemId||sellingTokenId].slot
    //         ==============================*/

    //         // store common slot for agency in memory
    //         mstore(0x20, agency.slot)

    //         // store common slot for offers in memory
    //         mstore(0x60, offers.slot)

    //         // // store common slot for agency in memory
    //         // mstore(0xE0, itemAgency.slot)

    //         // // store common slot for offers in memory
    //         // mstore(0x120, itemOffers.slot)

    //         // store common slot for proof in memory
    //         mstore(0x160, proofs.slot)

    //         for {
    //             let i := 0
    //         } lt(i, len) {
    //             i := add(i, 1)
    //         } {
    //             // tokenIds[i]
    //             let offerId := calldataload(add(offerIds.offset, shl(5, i)))

    //             let isItem := gt(offerId, 0xffffff)

    //             let sender := caller()

    //             let trust := 0

    //             if isItem {
    //                 // sender := shr(40, offerId)

    //                 // mstore(0x00, sender)

    //                 // let offerer__agency := sload(keccak256(0x00, 0x40))

    //                 // trust := eq(caller(), juke(offerer__agency, 96, 96))

    //                 // offerId := and(offerId, 0xffffffffff)
    //             }

    //             // calculate agency.slot storeage ptr
    //             mstore(0x00, offerId)

    //             let agency__sptr := keccak256(0x00, 0x40)

    //             // load agency value from storage
    //             let agency__cache := sload(agency__sptr)

    //             // if it is marked as a swap -
    //             // -- and the user is the agent
    //             // -- and the swap is over or not started
    //             // then complete the trade

    //             if eq(shr(254, agency__cache), 0x03) {
    //                 let agency__epoch := juke(agency__cache, 2, 232)
    //                 let agency__addr := juke(agency__cache, 96, 96)

    //                 mstore(0x40, offerId)
    //                 mstore(0x40, keccak256(0x40, 0x40))
    //                 let offer__sptr := keccak256(0x40, 0x40)

    //                 // calculate offers.slot storage pointer
    //                 mstore(add(mptroffset, 0x40), tokenId)

    //                 // calculate offers[tokenId].slot storage pointer
    //                 mstore(0x80, sender)
    //                 mstore(0xa0, offer__sptr)
    //                 offer__sptr := keccak256(0x80, 0x40)

    //                 if or(iszero(agency__epoch), gt(active, agency__epoch)) {

    //                     switch isItem
    //                     case 1 {
    //                         sstore(agency__sptr, 0)

    //                         let proof__sptr := keccak256(0x80, 0x40)

    //                         let proof := sload(proof__sptr)

    //                         // prettier-ignore
    //                         for { let j := 8 } lt(j, 17) { j := add(j, 1) } {
    //                             if eq(j, 16) { panic(Error__0x79__ProofHasNoFreeSlot) }

    //                             if iszero(and(shr(mul(j, 16), proof), 0xffff)) {
    //                                 let tmp := shr(24, tokenId)
    //                                 proof := xor(proof, shl(mul(j, 16), tmp))
    //                                 break
    //                             }
    //                         }

    //                         sstore(proof__sptr, proof)

    //                         mstore(0xA0, proof)

    //                         log4(0xA0, 0x20, Event__TransferItem, 0x00, agency__addr, shl(240, shr(24, tokenId)))
    //                     }
    //                     default {
    //                         let proof__sptr := keccak256(0x80, 0x40)

    //                         if iszero(sload(proof__sptr)) {
    //                             mstore(0xA0, hotproof.slot)
    //                             mstore(0x80, mod(tokenId, HOT_PROOF_AMOUNT))
    //                             let hotproof__sptr := keccak256(0x80, 0x40)
    //                             sstore(proof__sptr, sload(hotproof__sptr))
    //                             sstore(hotproof__sptr, 0x10000)
    //                         }

    //                         // if either exists for this token, set the proof

    //                         // save the updated agency
    //                         sstore(
    //                             agency__sptr,
    //                             xor(
    //                                 // =============================
    //                                 /* addr     0       [ */
    //                                 agency__addr, /*  ] 160 */
    //                                 /* eth      160,    [    next         ] 230 */
    //                                 /* epoch    230,    [    active       ] 254 */
    //                                 shl(
    //                                     /* flag  */
    //                                     254,
    //                                     /* [ */
    //                                     0x01 /* ] 255 */
    //                                 )
    //                             )
    //                         ) // ==========================================================

    //                         // "transfer" token to the new owner
    //                         log4(
    //                             // =======================================================
    //                             /* param #0:n/a  */
    //                             0x00,
    //                             /* [ n/a ] */
    //                             0x00,
    //                             /* topic #1:sig  */
    //                             Event__Transfer,
    //                             /* topic #2:from */
    //                             address(),
    //                             /* topic #3:to   */
    //                             agency__addr,
    //                             /* topic #4:id   */
    //                             tokenId
    //                         ) // ===========================================================
    //                     }
    //                 }
    //             }

    //             // calculate offers.slot storage pointer
    //             mstore(add(mptroffset, 0x40), tokenId)
    //             let offer__sptr := keccak256(add(mptroffset, 0x40), 0x40)

    //             // calculate offers[tokenId].slot storage pointer
    //             mstore(0x80, sender)
    //             mstore(0xa0, offer__sptr)
    //             offer__sptr := keccak256(0x80, 0x40)

    //             let offer__cache := sload(offer__sptr)

    //             // ensure this user has an offer to claim
    //             if iszero(offer__cache) {
    //                 continue
    //             }

    //             mstore(0xA0, proofs.slot)

    //             if isItem {
    //                 if iszero(trust) {
    //                     panic(Error__0x74__Untrusted)
    //                 }
    //             }

    //             // accumulate and send value at once at end
    //             // to save on gas for most common use case
    //             acc := add(acc, juke(offer__cache, 26, 186))

    //             // delete offer before we potentially send value
    //             sstore(offer__sptr, 0)

    //             switch isItem
    //             case 1 {
    //                 log4(0x00, 0x00, Event__ClaimItem, and(tokenId, 0xffffff), shl(240, shr(24, tokenId)), sender)
    //             }
    //             default {
    //                 log3(0x00, 0x00, Event__Claim, tokenId, sender)
    //             }
    //         }

    //         // skip sending value if amount to send is 0
    //         if iszero(acc) {
    //             return(0, 0)
    //         }

    //         acc := mul(acc, LOSS)

    //         // send accumulated value * LOSS to msg.sender
    //         if iszero(call(gas(), caller(), acc, 0, 0, 0, 0)) {
    //             // if someone really ends up here, just donate the eth
    //             sstore(stake.slot, add(sload(stake.slot), shl(96, acc)))
    //         }
    //     }
    // }

    /// @inheritdoc INuggftV1Swap
    function sell(uint160 tokenId, uint96 floor) public override {
        assembly {
            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore8(31, code)
                revert(27, 0x5)
            }

            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            let mptr := mload(0x40)

            mstore(0x20, agency.slot)

            let sender := caller()

            let isItem := gt(tokenId, 0xffffff)

            if isItem {
                sender := and(tokenId, 0xffffff)

                tokenId := and(tokenId, 0xffffffffff)

                mstore(0x00, sender)

                let buyerTokenAgency := sload(keccak256(0x00, 0x40))

                // ensure the caller is the agent
                if iszero(eq(juke(buyerTokenAgency, 96, 96), caller())) {
                    panic(Error__0xA2__NotItemAgent)
                }

                let flag := shr(254, buyerTokenAgency)

                // ensure the caller is really the agent
                if and(eq(flag, 0x3), iszero(iszero(juke(buyerTokenAgency, 2, 232)))) {
                    panic(Error__0xA3__NotItemAuthorizedAgent)
                }

                mstore(0x20, itemAgency.slot)
            }

            mstore(0x00, tokenId)

            let agency__sptr := keccak256(0x00, 0x40)

            let agency__cache := sload(agency__sptr)

            // update agency to reflect the new sale

            switch isItem
            case 1 {
                if iszero(iszero(agency__cache)) {
                    panic(Error__0x97__ItemAgencyAlreadySet)
                }

                mstore(0x00, sender)

                // store common slot for offers in memory
                mstore(0x20, proofs.slot)

                let proof__sptr := keccak256(0x00, 0x40)

                let proof := sload(proof__sptr)

                let id := shr(24, tokenId)

                // start at 1 to jump over the base
                let j := 1

                // prettier-ignore
                for { } lt(j, 16) { j := add(j, 1) } {
                    if eq(and(shr(mul(j, 16), proof), 0xffff), id) {
                        proof := and(proof, not(shl(mul(j, 16), 0xffff)))
                        break
                    }
                }

                if eq(j, 16) {
                    panic(Error__0xA9__ProofDoesNotHaveItem)
                }

                // sstore(protocolItems.slot, add(sload(protocolItems.slot), 1))

                sstore(proof__sptr, proof)

                mstore(0x00, proof)

                log4(0x00, 0x20, Event__TransferItem, tokenId, 0x00, shl(240, shr(24, tokenId)))

                // ==== agency[tokenId] =====
                //   flag  = SWAP(0x03)
                //   epoch = 0
                //   eth   = seller decided floor / .1 gwei
                //   addr  = seller
                // ==========================

                agency__cache := xor(xor(shl(254, 0x03), shl(160, div(floor, LOSS))), sender)

                sstore(agency__sptr, agency__cache)

                // log2 with 'Sell(uint160,bytes32)' topic
                mstore(0x00, agency__cache)

                log3(0x00, 0x20, Event__SellItem, and(tokenId, 0xffffff), shl(240, shr(24, tokenId)))
            }
            default {
                // ensure the caller is the agent
                if iszero(eq(shr(96, shl(96, agency__cache)), caller())) {
                    panic(Error__0xA1__NotAgent)
                }

                // ensure the agent is the owner
                if iszero(eq(shr(254, agency__cache), 0x1)) {
                    panic(Error__0x77__NotOwner)
                }

                let stake__cache := sload(stake.slot)

                let activeEps := div(juke(stake__cache, 64, 160), shr(192, stake__cache))

                if lt(floor, activeEps) {
                    panic(Error__0x70__FloorTooLow)
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
                mstore(0x00, agency__cache)

                log2(0x00, 0x20, Event__Sell, tokenId)
            }
        }
    }

    // @inheritdoc INuggftV1Swap
    function vfo(address sender, uint160 tokenId) public view override returns (uint96) {
        // canOffer = true;

        uint24 activeEpoch = epoch();

        uint96 _msp = msp();

        assembly {
            let _nextSwapAmount := 0
            let _senderCurrentOffer := 0

            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)

            let swapData := sload(keccak256(0x00, 0x40))

            let offerData := swapData

            if iszero(eq(juke(swapData, 96, 96), sender)) {
                mstore(0x20, offers.slot)
                mstore(0x20, keccak256(0x00, 0x40))
                mstore(0x00, sender)
                offerData := sload(keccak256(0x00, 0x40))
            }

            switch iszero(swapData)
            case 1 {
                switch eq(tokenId, activeEpoch)
                case 1 {
                    _nextSwapAmount := _msp
                }
                default {
                    mstore(0x00, 0x00)
                    mstore(0x20, 0x00)
                    return(0x00, 0x40)
                }
            }
            default {
                _senderCurrentOffer := mul(juke(offerData, 26, 186), LOSS)

                _nextSwapAmount := mul(juke(swapData, 26, 186), LOSS)
            }

            if lt(_nextSwapAmount, 10000000) {
                _nextSwapAmount := 10000000
            }

            _nextSwapAmount := div(mul(_nextSwapAmount, 10200), 10000)

            mstore(0x00, sub(_nextSwapAmount, _senderCurrentOffer))
            return(0x00, 0x20)
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
