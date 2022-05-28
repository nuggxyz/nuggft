// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import {INuggftV1Swap} from "../interfaces/nuggftv1/INuggftV1Swap.sol";
import {INuggftV1ItemSwap} from "../interfaces/nuggftv1/INuggftV1ItemSwap.sol";

import {NuggftV1Stake} from "./NuggftV1Stake.sol";
import "../_test/utils/forge.sol";

/// @notice mechanism for trading of nuggs between users (and items between nuggs)
/// @dev Explain to a developer any extra details
abstract contract NuggftV1Swap is INuggftV1ItemSwap, INuggftV1Swap, NuggftV1Stake {
    function offers(uint24 tokenId, address account) public view returns (uint256 value) {
        return _offers[tokenId][account];
    }

    function itemAgency(uint24 sellingTokenId, uint16 itemId) public view returns (uint256 value) {
        return _itemAgency[uint40(sellingTokenId) | (uint40(itemId) << 24)];
    }

    function itemOffers(
        uint24 buyingTokenid,
        uint24 sellingTokenId,
        uint16 itemId
    ) public view returns (uint256 value) {
        return _itemOffers[uint40(sellingTokenId) | (uint40(itemId) << 24)][buyingTokenid];
    }

    /// @inheritdoc INuggftV1Swap
    function offer(uint24 tokenId) public payable override {
        _offer(tokenId);
    }

    /// @inheritdoc INuggftV1ItemSwap
    function offer(
        uint24 buyingTokenId,
        uint24 sellingTokenId,
        uint16 itemId
    ) external payable override {
        _offer((uint64(buyingTokenId) << 40) | (uint64(itemId) << 24) | uint64(sellingTokenId));
    }

    function _offer(uint256 tokenId) private {
        uint256 agency__sptr;
        uint256 agency__cache;

        uint256 active = epoch();

        address sender;
        uint256 offersSlot;

        bool isItem;

        assembly {
            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore8(31, code)
                revert(27, 0x5)
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

                mstore(0x20, _itemAgency.slot)

                offersSlot := _itemOffers.slot
            }
            default {
                sender := caller()

                offersSlot := _offers.slot
            }

            mstore(0x00, tokenId)

            agency__sptr := keccak256(0x00, 0x40)
            agency__cache := sload(agency__sptr)
        }

        // check to see if this nugg needs to be minted
        if (active == tokenId && agency__cache == 0) {
            // [Offer:Mint]

            uint256 _proof = initFromSeed(calculateSeed(uint24(active)));

            // uint256 hotproof__cache = hotproof[uint8(tokenId % HOT_PROOF_AMOUNT)];

            // // if hot slot 1 is open, save there
            // if (hotproof__cache == HOT_PROOF_EMPTY) {
            //     hotproof[uint8(tokenId % HOT_PROOF_AMOUNT)] = proof;
            // } else {
            proof[uint24(tokenId)] = _proof;

            address itemHolder = address(xnuggftv1);
            // }
            // xnuggftv1.proofTransferBatch(proof, address(0), address(this));

            // otherwise this
            addStakedShare(msg.value);

            // prettier-ignore
            assembly {
                // save the updated agency
                agency__cache := xor(xor(xor( // =============================
                          /* addr     0       [ */ caller(),              /* ] 160 */
                    shl(  /* eth   */ 160, /* [ */ div(callvalue(), LOSS) /* ] 230 */ )),
                    shl(  /* epoch */ 230, /* [ */ active                 /* ] 254 */ )),
                    shl(  /* flag  */ 254, /* [ */ 0x03                   /* ] 255 */ )
                ) // ==========================================================

                // log the updated agency
                mstore(0x00, agency__cache)
                mstore(0x20, _proof)

                log2( // -------------------------------------------------------
                    /* param #1: agency  */ 0x00, /* [ agency[tokenId]    ]     0x20,
                       param #2: proof      0x20,    [ proof[tokenId]     ]     0x40,
                       param #3: proof      0x40,    [ stake              ]  */ 0x60,
                    /* topic #1: sig     */ Event__OfferMint,
                    /* topic #2: tokenId */ tokenId
                ) // ===========================================================

                mstore(0x00, Function__transferBatch)
                mstore(0x40, 0x00)
                mstore(0x60, address())

                if iszero(call(gas(), itemHolder, 0x00, 0x1C, 0x64, 0x00, 0x00)) {
                    mstore(0x00, Revert__Sig)
                    mstore8(31, Error__0xAE__FailedCallToItemsHolder)
                    revert(27, 0x5)
                }

                log4( // =======================================================
                    /* param #0:n/a  */ 0x00, /* [ n/a ] */  0x00,
                    /* topic #1:sig  */ Event__Transfer,
                    /* topic #2:from */ 0,
                    /* topic #3:to   */ address(),
                    /* topic #4:id   */ tokenId
                ) // ===========================================================



                sstore(agency__sptr, agency__cache)

            }

            return;
        } else if (!isItem && agency__cache == 0) {
            premint(uint24(tokenId));
            return;
        }

        // prettier-ignore
        assembly {
            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
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
                0x00, /* [ tokenId        )    0x20
                0x20     [ offers[X].slot ) */ 0x40
            ))// =======================================================

            mstore(0x00, sender)

             offersSlot := keccak256( // ===========================
                0x00, /* [ msg.sender     )    0x20
                0x20     [ offers[X].slot ) */ 0x40
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
                offer__cache := sload(offersSlot)
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
            // if so, we know this swap has not yet been offered on
            case 1 { // [Offer:Commit]

                let nextEpoch := add(active, SALE_LEN)

                // update the epoch to begin auction
                agency__cache := xor( // =====================================
                    /* start */  agency__cache,
                    // we know that the epoch is 0
                    // -------------------------------------------------------
                        /* address       0,    [                 ) 160 */
                        /* eth         160,    [                 ) 230 */
                   shl( /* epoch    */ 230, /* [ */ nextEpoch /* ) 254 */ )
                        /* flag        254,    [                 ) 256 */
                ) // ==========================================================

                switch isItem
                case 1 {
                    // check to make sure there is not a swap
                    // this effectivly blocks more than one swap of a particular item of ending in the same epoch

                    mstore(0x80, shr(24, tokenId))
                    mstore(0xA0, lastItemSwap.slot)

                    let kek := keccak256(0x80, 0x40)

                    let val := sload(kek)

                    if eq(nextEpoch, and(val, 0xffffff)) {
                        panic(Error__0xAC__MustFinalizeOtherItemSwap)
                    }

                    val := shl(48, val)

                    val := or(val, shl(24, and(tokenId, 0xffffff)))

                    // since epoch 1 cant happen (unless OFFSET is 0)
                    sstore(kek, or(val, nextEpoch))

                }
                default {
                    // Event__Transfer the token to the contract for the remainder of sale
                    // the seller (agency__addr) approves this when they put the token up for sale

                    // log4( // =======================================================
                    //     /* param 0: n/a  */ 0x00, 0x00,
                    //     /* topic 1: sig  */ Event__Transfer,
                    //     /* topic 2: from */ agency__addr,
                    //     /* topic 3: to   */ address(),
                    //     /* topic 4: id   */ tokenId
                    // ) // ===========================================================
                }
            }
            default { // [Offer:Carry]
                // otherwise we validate the epoch to ensure the swap is still active
                // baisically, "is the auction's epoch in the past?"
                if lt(agency__epoch, active) {
                    // - if yes, we revert
                    panic(Error__0xA4__ExpiredEpoch)
                }
            }

            /////////////////////////////////////////////////////////////////////

            // parse last offer value
           let last := juke(agency__cache, 26, 186)

            // store callvalue formatted in .1 gwei for caculation of total offer
            let next := div(callvalue(), LOSS)

            // parse and caculate next offer value
            next := add(juke(offer__cache, 26, 186), next)

            if iszero(gt(next, 100)) {
                panic(Error__0x68__OfferLowerThanLOSS)
            }

            let remain := sub(INTERVAL, mod(number(), INTERVAL))

            switch and(eq(agency__epoch, active),lt(remain, 45))
            case 1 {
                remain := add(mul(sub(50, remain), 100), BASE_BPS)
            }
            default {
                remain := INCREMENT_BPS
            }

            // ensure next offer includes at least a 2% increment
            if gt(div(mul(last, remain), BASE_BPS), next) {
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
                    /* address      0     [ */ sender /* ) 160 */ ),
               shl( /* eth     */ 160, /* [ */ next   /* ) 230 */ )
                    /* epoch      230     [              ) 254 */
                    /* flag       254     [              ) 256 */
            ) // ===============================================================

            sstore(agency__sptr, agency__cache)

            sstore(offersSlot, agency__cache)

            mstore(0x00, agency__cache)

            // switch eq(tokenId, active)
            // case 1 {
            //     next := div(last, PROTOCOL_FEE_FRAC_MINT_DIV)
            // }
            // default {
                next := div(last, PROTOCOL_FEE_FRAC)
            // }
            last := add(sload(stake.slot), or(shl(96, sub(last, next)), next))
            sstore(stake.slot, last)
            mstore(0x20, last)

            switch isItem
            case 1 {
                log3( // =======================================================
                    /* param #1: agency   bytes32 */ 0x00, /* [ _itemAgency[tokenId][itemId] )    0x20
                       param #2: stake    bytes32    0x20     [ stake                       ) */ 0x40,
                    // ---------------------------------------------------------
                    /* topic #1: sig              */ Event__OfferItem,
                    /* topic #2: sellerId uint24  */ and(tokenId, 0xffffff),
                    /* topic #3: itemId   uint16  */ shr(24, tokenId)
                ) // ===========================================================
            }
            default {
                log2( // =======================================================
                    /* param #1: agency  bytes32 */ 0x00, /* [ agency[tokenId] )    0x20
                       param #2: stake   bytes32    0x20     [ stake           ) */ 0x40,
                    // ---------------------------------------------------------
                    /* topic #1: sig             */ Event__Offer,
                    /* topic #2: tokenId uint24 */ tokenId
                ) // ===========================================================
            }

            // add the increment * LOSS to staked eth

        }
    }

    function premint(uint24 tokenId) internal {
        _repanic(agency[tokenId] == 0, Error__0x65__TokenNotMintable);

        (uint24 first, uint24 last) = premintTokens();

        _repanic(tokenId >= first && tokenId <= last, Error__0x65__TokenNotMintable);

        uint256 _agency = (0x01 << 254) + uint160(address(this));

        uint256 _proof = initFromSeed(calculateEarlySeed(tokenId));

        uint256 prefix = (0x03 << 254) + (uint256((msp() / LOSS)) << 160);

        _agency = prefix + uint160(address(this));

        // emit Sell(tokenId, bytes32(_agency));

        uint16 item = uint16(_proof >> 0x90);

        uint256 __itemAgency = prefix | uint256(tokenId);

        xnuggftv1.transferBatch(_proof, address(0), address(this));

        _itemAgency[((uint40(item) << 24) | uint40(tokenId))] = __itemAgency;

        // prettier-ignore
        assembly {
            _proof := and(_proof, not(shl(mul(9, 16), 0xffff)))

            log4( // =======================================================
                /* param #0:n/a  */ 0x00, /* [ n/a ] */  0x00,
                /* topic #1:sig  */ Event__Transfer,
                /* topic #2:from */ 0,
                /* topic #3:to   */ address(),
                /* topic #4:id   */ tokenId
            ) // ===========================================================

        }

        emit PreMint(tokenId, bytes32(_proof), bytes32(_agency), item, bytes32(__itemAgency));

        proof[tokenId] = _proof;
        agency[tokenId] = _agency;

        // a little reentrancy never hurt nobody
        offer(tokenId);

        delete _offers[tokenId][address(this)];
    }

    /// @inheritdoc INuggftV1Swap
    function claim(
        uint24[] calldata tokenIds,
        address[] calldata accounts,
        uint24[] calldata buyingTokenIds,
        uint16[] calldata itemIds
    ) public override {
        uint256 active = epoch();

        address itemsHolder = address(xnuggftv1);

        // prettier-ignore
        assembly {

            mstore(0x200, itemsHolder)
            pop(itemsHolder)

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

            // ensure arrays the same length
            if iszero(eq(len, calldataload(sub(itemIds.offset, 0x20)))) {
                panic(Error__0x76__InvalidArrayLengths)
            }

            if iszero(eq(len, calldataload(sub(buyingTokenIds.offset, 0x20)))) {
                panic(Error__0x76__InvalidArrayLengths)
            }

            let acc := 0

            /*========= memory ============
              0x00: tokenId
              0x20: agency.slot
              [keccak]: agency[tokenId].slot = "agency__sptr"
              --------------------------
              0x40: tokenId
              0x60: _offers.slot
              [keccak]: offers[tokenId].slot = "offer__sptr"
              --------------------------
              0x80: offerer
              0xA0: offers[tokenId].slot
              [keccak]: _itemOffers[tokenId][offerer].slot = "offer__sptr"
              --------------------------
              0xC0: itemId || sellingTokenId
              0xE0: _itemAgency.slot
              [keccak]: _itemAgency[itemId || sellingTokenId].slot = "agency__sptr"
              --------------------------
              0x100: itemId|sellingTokenId
              0x120: _itemOffers.slot
              [keccak]: _itemOffers[itemId||sellingTokenId].slot
            ==============================*/

            // store common slot for agency in memory
            mstore(0x20, agency.slot)

            // store common slot for offers in memory
            mstore(0x60, _offers.slot)

            // store common slot for agency in memory
            mstore(0xE0, _itemAgency.slot)

            // store common slot for offers in memory
            mstore(0x120, _itemOffers.slot)

            // store common slot for proof in memory
            mstore(0x160, proof.slot)



            for { let i := 0 } lt(i, len) { i := add(i, 1) } {

                let isItem

                 // accounts[i]
                let offerer := calldataload(add(accounts.offset, shl(5, i)))

                // tokenIds[i]
                let tokenId := calldataload(add(tokenIds.offset, shl(5, i)))

                if iszero(offerer) {
                    offerer := calldataload(add(buyingTokenIds.offset, shl(5, i)))
                    isItem := 1
                    tokenId := or(tokenId, shl(24, calldataload(add(itemIds.offset, shl(5, i)))))
                }

                //
                let trusted := offerer

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

                // calculate _offers.slot storage pointer
                mstore(add(mptroffset, 0x40), tokenId)
                let offer__sptr := keccak256(add(mptroffset, 0x40), 0x40)

                // calculate offers[tokenId].slot storage pointer
                mstore(0x80, offerer)
                mstore(0xA0, offer__sptr)
                offer__sptr := keccak256(0x80, 0x40)


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

                        mstore(0x140, offerer)

                        let proof__sptr := keccak256(0x140, 0x40)

                        let _proof := sload(proof__sptr)

                        // prettier-ignore
                        for { let j := 8 } lt(j, 16) { j := add(j, 1) } {
                            if iszero(and(shr(mul(j, 16), _proof), 0xffff)) {
                                let tmp := shr(24, tokenId)
                                _proof := xor(_proof, shl(mul(j, 16), tmp))
                                break
                            }
                        }

                        sstore(proof__sptr, _proof)


                        mstore(0x220, Function__transferSingle )
                        mstore(0x240, shr(24, tokenId))
                        mstore(0x260, address())
                        mstore(0x280, caller())

                        if iszero(call(gas(), mload(0x200), 0x00, 0x23C, 0x64, 0x00, 0x00)) {
                            panic(Error__0xAE__FailedCallToItemsHolder)
                         }

                        mstore(0x1A0, _proof)
                    }
                    default {

                        mstore(0x140, tokenId)

                        let _proof := sload(keccak256(0x140, 0x40))

                        mstore(0x220, Function__transferBatch)
                        mstore(0x240, _proof)
                        mstore(0x260, address())
                        mstore(0x280, caller())

                        // this call can only fail if not enough gas is passed
                        if iszero(call(gas(), mload(0x200), 0x00, 0x23C, 0x64, 0x00, 0x00)) {
                            panic(Error__0xAE__FailedCallToItemsHolder)
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
                    log4(0x1A0, 0x20, Event__ClaimItem, and(tokenId, 0xffffff), shr(24, tokenId), offerer)
                    mstore(0x1A0, 0x00)
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

            // we could add a whole bunch of logic all over to ensure that contracts cant use this, but
            // lets just keep it simple - if you own you nugg with a contract, you have no way to make any
            // eth on it.

            // since a meaninful claim can only be made the epoch after a swap is over, it is at least 1 block
            // later. So, if a contract that has offered will not be in creation when it hits here,
            // so our call to extcodesize is sufficcitent to check if caller is a contract or not

            // send accumulated value * LOSS to msg.sender
            switch iszero(extcodesize(caller()))
            case 1 {
                pop(call(gas(), caller(), acc, 0, 0, 0, 0))
            }
            default {
                // if someone really ends up here, just donate the eth
                let pro := div(acc, PROTOCOL_FEE_FRAC)

                let cache := add(sload(stake.slot), or(shl(96, sub(acc, pro)), pro))

                sstore(stake.slot, cache)

                mstore(0x00, cache)

                log1(0x00, 0x20, Event__Stake)
            }
        }
    }

    /// @inheritdoc INuggftV1ItemSwap
    function sell(
        uint24 sellingTokenId,
        uint16 itemId,
        uint96 floor
    ) external override {
        _sell((uint40(itemId) << 24) | uint40(sellingTokenId), floor);
    }

    /// @inheritdoc INuggftV1Swap
    function sell(uint24 tokenId, uint96 floor) public override {
        _sell(tokenId, floor);
    }

    function _sell(uint40 tokenId, uint96 floor) private {
        address itemHolder = address(xnuggftv1);

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
                // aka makes sure they are not in the middle of a swap
                if and(eq(flag, 0x3), iszero(iszero(juke(buyerTokenAgency, 2, 232)))) {
                    panic(Error__0xA3__NotItemAuthorizedAgent)
                }

                mstore(0x20, _itemAgency.slot)
            }

            mstore(0x00, tokenId)

            let agency__sptr := keccak256(0x00, 0x40)

            let agency__cache := sload(agency__sptr)

            // update agency to reflect the new sale

            switch isItem
            case 1 {
                if iszero(iszero(agency__cache)) {
                    // panic(Error__0x97__ItemAgencyAlreadySet)

                    agency__cache := xor(xor(shl(254, 0x03), shl(160, div(floor, LOSS))), sender)

                    sstore(agency__sptr, agency__cache)

                    mstore(0x00, agency__cache)
                    mstore(0x20, 0x00)

                    log3(0x00, 0x40, Event__SellItem, and(tokenId, 0xffffff), shr(24, tokenId))

                    // panic(Error__0x97__ItemAgencyAlreadySet)

                    return(0, 0)
                }

                mstore(0x00, sender)

                // store common slot for offers in memory
                mstore(0x20, proof.slot)

                let proof__sptr := keccak256(0x00, 0x40)

                let _proof := sload(proof__sptr)

                let id := shr(24, tokenId)

                // start at 1 to jump over the visibles
                let j := 1

                // prettier-ignore
                for { } lt(j, 16) { j := add(j, 1) } {
                    if eq(and(shr(mul(j, 16), _proof), 0xffff), id) {
                        _proof := and(_proof, not(shl(mul(j, 16), 0xffff)))
                        break
                    }
                }

                if eq(j, 16) {
                    panic(Error__0xA9__ProofDoesNotHaveItem)
                }

                sstore(proof__sptr, _proof)

                // ==== agency[tokenId] =====
                //   flag  = SWAP(0x03)
                //   epoch = 0
                //   eth   = seller decided floor / .1 gwei
                //   addr  = seller
                // ==========================

                agency__cache := xor(xor(shl(254, 0x03), shl(160, div(floor, LOSS))), sender)

                sstore(agency__sptr, agency__cache)

                // log2 with 'Sell(uint24,bytes32)' topic
                mstore(0x00, agency__cache)
                mstore(0x20, _proof)

                log3(0x00, 0x40, Event__SellItem, and(tokenId, 0xffffff), shr(24, tokenId))

                mstore(0x00, Function__transferSingle)
                mstore(0x20, shr(24, tokenId))
                mstore(0x40, caller())
                mstore(0x60, address())

                if iszero(call(gas(), itemHolder, 0x00, 0x1C, 0x64, 0x00, 0x00)) {
                    panic(Error__0xAE__FailedCallToItemsHolder)
                }
            }
            default {
                // ensure the caller is the agent
                if iszero(eq(shr(96, shl(96, agency__cache)), caller())) {
                    panic(Error__0xA1__NotAgent)
                }

                let flag := shr(254, agency__cache)

                let isWaitingForOffer := and(eq(flag, 0x3), iszero(juke(agency__cache, 2, 232)))

                // ensure the agent is the owner
                if iszero(isWaitingForOffer) {
                    // ensure the agent is the owner
                    if iszero(eq(flag, 0x1)) {
                        panic(Error__0x77__NotOwner)
                    }
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

                agency__cache := xor(xor(shl(254, 0x03), shl(160, div(floor, LOSS))), caller())

                sstore(agency__sptr, agency__cache)

                // log2 with 'Sell(uint24,bytes32)' topic
                mstore(0x00, agency__cache)

                log2(0x00, 0x20, Event__Sell, tokenId)

                if iszero(isWaitingForOffer) {
                    // prettier-ignore
                    log4( // =======================================================
                        /* param 0: n/a  */ 0x00, 0x00,
                        /* topic 1: sig  */ Event__Transfer,
                        /* topic 2: from */ caller(),
                        /* topic 3: to   */ address(),
                        /* topic 4: id   */ tokenId
                    ) // ===========================================================

                    mstore(0x00, tokenId)
                    mstore(0x20, proof.slot)

                    let _proof := sload(keccak256(0x00, 0x40))

                    mstore(0x00, Function__transferBatch)
                    mstore(0x20, _proof)
                    mstore(0x40, address())
                    mstore(0x60, caller())

                    if iszero(call(gas(), itemHolder, 0x00, 0x1C, 0x64, 0x00, 0x00)) {
                        panic(Error__0xAE__FailedCallToItemsHolder)
                    }
                }
            }
        }
    }

    // @inheritdoc INuggftV1Swap
    function vfo(address sender, uint24 tokenId) public view override returns (uint96 res) {
        (bool canOffer, uint96 next, uint96 current, ) = check(sender, tokenId);

        if (canOffer) res = next - current;
    }

    // @inheritdoc INuggftV1Swap
    function check(address sender, uint24 tokenId)
        public
        view
        override
        returns (
            bool canOffer,
            uint96 next,
            uint96 current,
            uint96 incrementBps
        )
    {
        canOffer = true;

        uint24 activeEpoch = epoch();

        uint96 _msp = msp();

        uint24 _early = early;

        incrementBps = INCREMENT_BPS;

        assembly {
            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)

            let swapData := sload(keccak256(0x00, 0x40))

            let offerData := swapData

            let isLeader := eq(juke(swapData, 96, 96), sender)

            if iszero(isLeader) {
                mstore(0x20, _offers.slot)
                mstore(0x20, keccak256(0x00, 0x40))
                mstore(0x00, sender)
                offerData := sload(keccak256(0x00, 0x40))
            }

            switch iszero(swapData)
            case 1 {
                switch eq(tokenId, activeEpoch)
                case 1 {
                    next := _msp
                }
                default {
                    if iszero(and(iszero(lt(tokenId, MINT_OFFSET)), lt(tokenId, add(MINT_OFFSET, _early)))) {
                        mstore(0x00, 0x00)
                        mstore(0x20, 0x00)
                        mstore(0x40, 0x00)
                        mstore(0x60, 0x00)
                        return(0x00, 0x80)
                    }

                    next := _msp
                }
            }
            default {
                let swapEpoch := juke(swapData, 2, 232)

                if and(isLeader, iszero(swapEpoch)) {
                    canOffer := 0
                }

                if eq(swapEpoch, activeEpoch) {
                    let remain := sub(INTERVAL, mod(number(), INTERVAL))

                    if lt(remain, 45) {
                        incrementBps := add(mul(sub(50, remain), 100), BASE_BPS)
                    }
                }

                current := mul(juke(offerData, 26, 186), LOSS)

                next := mul(juke(swapData, 26, 186), LOSS)

                if lt(next, STARTING_PRICE) {
                    next := STARTING_PRICE
                    incrementBps := INCREMENT_BPS
                }

                next := mul(div(mul(div(next, LOSS), incrementBps), BASE_BPS), LOSS)
            }
        }
    }

    /// @inheritdoc INuggftV1ItemSwap
    function vfo(
        uint24 buyer,
        uint24 seller,
        uint16 itemId
    ) public view override returns (uint96 res) {
        (bool canOffer, uint96 next, uint96 current, ) = check(buyer, seller, itemId);

        if (canOffer) res = next - current;
    }

    /// @inheritdoc INuggftV1ItemSwap
    function check(
        uint24 buyer,
        uint24 seller,
        uint16 itemId
    )
        public
        view
        override
        returns (
            bool canOffer,
            uint96 next,
            uint96 current,
            uint96 incrementBps
        )
    {
        canOffer = true;

        uint24 activeEpoch = epoch();

        uint256 agency__cache = itemAgency(seller, itemId);

        uint256 offerData = agency__cache;

        if (buyer != uint24(agency__cache)) {
            offerData = itemOffers(buyer, seller, itemId);
        }

        uint24 agencyEpoch = uint24(agency__cache >> 230);

        if (agencyEpoch == 0 && offerData == agency__cache) canOffer = false;

        current = uint96((offerData << 26) >> 186) * LOSS;

        next = uint96((agency__cache << 26) >> 186) * LOSS;

        incrementBps = INCREMENT_BPS;

        assembly {
            if eq(agencyEpoch, activeEpoch) {
                let remain := sub(INTERVAL, mod(number(), INTERVAL))

                if lt(remain, 45) {
                    incrementBps := add(mul(sub(50, remain), 100), BASE_BPS)
                }
            }

            if lt(next, STARTING_PRICE) {
                next := STARTING_PRICE
                incrementBps := INCREMENT_BPS
            }

            next := mul(div(mul(div(next, LOSS), incrementBps), BASE_BPS), LOSS)
        }
    }
}
