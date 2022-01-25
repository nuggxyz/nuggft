// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {INuggftV1Loan} from '../interfaces/nuggftv1/INuggftV1Loan.sol';

import {NuggftV1Swap} from './NuggftV1Swap.sol';

abstract contract NuggftV1Loan is INuggftV1Loan, NuggftV1Swap {
    /// @inheritdoc INuggftV1Loan
    function loan(uint160[] calldata tokenIds) external override {
        uint96 amt = eps();

        uint256 active = epoch();

        assembly {
            function iso(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }

            // load the length of the calldata array
            let len := calldataload(sub(tokenIds.offset, 0x20))

            let mptr := mload(0x40)

            // calculate agency.slot storeage ptr
            mstore(add(mptr, 0x20), agency.slot)

            for {
                let i := 0
            } lt(i, len) {
                i := add(i, 0x1)
            } {
                // get a tokenId from calldata and store it to mem pos 0x00
                mstore(mptr, calldataload(add(tokenIds.offset, mul(i, 0x20))))

                let agency__sptr := keccak256(mptr, 0x40)

                // load agency value from storage
                let agency__cache := sload(agency__sptr)

                // ensure the caller is the agent
                if iszero(eq(iso(agency__cache, 96, 96), caller())) {
                    mstore8(0x0, Error__NotAgent__0x2A)
                    revert(0x00, 0x01)
                }

                // ensure the agent is the owner
                if iszero(eq(shr(254, agency__cache), 0x1)) {
                    mstore8(0x0, Error__NotOwner__0x2C)
                    revert(0x00, 0x01)
                }

                // compress amt into 70 bits
                amt := div(amt, LOSS)

                // update agency to reflect the loan
                // ==== agency[tokenId] ====
                //  flag  = LOAN(0x02)
                //  epoch = active
                //  eth   = eps / .1 gwei
                //  addr  = agent
                // =========================
                agency__cache := xor(caller(), xor(shl(160, amt), xor(shl(230, active), shl(254, 0x2))))

                // decompress amt back to eth
                // amt becomes a floored to .1 gwei version of eps()
                // ensures amt stored in agency and eth sent to caller are the same
                amt := mul(amt, LOSS)

                // store updated agency
                // done before external call to prevent reentrancy
                sstore(agency__sptr, agency__cache)

                // send eth
                if iszero(call(gas(), caller(), amt, 0, 0, 0, 0)) {
                    mstore(0x00, Error__SendEthFailureToCaller__0x92)
                    revert(0x1F, 0x01)
                }

                // log2 with "Loan(uint160,bytes32)" topic
                mstore(add(mptr, 0x20), agency__cache)
                log2(add(mptr, 0x20), 0x20, Event__Loan, mload(mptr))
            }
        }
    }

    /// @inheritdoc INuggftV1Loan
    function liquidate(uint160 tokenId) external payable override {
        uint256 agency__slot;
        uint256 agency__cache;

        uint256 active = epoch();

        assembly {
            function iso(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }

            let stake__cache := sload(stake.slot)

            let shrs := shr(192, stake__cache)

            let activeEps := div(iso(stake__cache, 64, 160), shrs)

            let mptr := mload(0x40)

            mstore(mptr, tokenId)
            mstore(add(mptr, 0x20), agency.slot)

            agency__slot := keccak256(mptr, 64)

            agency__cache := sload(agency__slot)

            let loaner := iso(agency__cache, 96, 96)

            // ensure that the agency flag is LOAN
            if iszero(eq(shr(254, agency__cache), 0x02)) {
                mstore8(0x0, Error__NotLoaned__0x33)
                revert(0x00, 0x01)
            }

            if iszero(eq(caller(), loaner)) {
                switch lt(add(iso(agency__cache, 2, 232), LIQUIDATION_PERIOD), active)
                case 1 {
                    log4(0x00, 0x00, Event__Transfer, loaner, caller(), tokenId)
                }
                default {
                    mstore8(0x0, Error__NotAuthorized__0x31)
                    revert(0x00, 0x01)
                }
            }

            // parse agency for principal, converting it back to eth
            // represents the value that has been sent to the user for this loan
            let principal := mul(iso(agency__cache, 26, 186), LOSS)

            // the amount of value earned by this token since last rebalance
            // must be computed because fee needs to be paid
            // increase in earnings per share since last rebalance
            let earn := sub(activeEps, principal)

            // the maximum fee that can be levied
            // let fee := earn

            // true fee
            let fee := add(div(principal, REBALANCE_FEE_BPS), principal)

            let value := add(earn, callvalue())

            if lt(value, fee) {
                mstore8(0x0, Error__LiquidationPaymentTooLow__0x32)
                revert(0x00, 0x01)
            }

            earn := sub(value, fee)

            let pro := div(fee, PROTOCOL_FEE_BPS)

            stake__cache := add(stake__cache, or(shl(96, sub(fee, pro)), pro))

            sstore(stake.slot, stake__cache)

            // update agency to return ownership of the token
            // ==========================
            // agency[tokenId] = {
            //     flag  = OWN(0x01)
            //     epoch = 0
            //     eth   = 0
            //     addr  = msg.sender
            // }
            // =========================
            agency__cache := or(caller(), shl(254, 0x01))

            // store updated agency
            // done before external call to prevent reentrancy
            sstore(agency__slot, agency__cache)

            // send eth
            if iszero(call(gas(), caller(), earn, 0, 0, 0, 0)) {
                mstore8(0x0, Error__SendEthFailureToCaller__0x92)
                revert(0x00, 0x01)
            }

            // log2 with "Liquidate(uint160,bytes32)" topic
            mstore(0x00, agency__cache)
            log2(0x00, 0x32, Event__Liquidate, tokenId)
        }
    }

    /// @inheritdoc INuggftV1Loan
    function rebalance(uint160[] calldata tokenIds) external payable {
        uint256 active = epoch();

        assembly {
            function iso(val, left, right) -> b {
                b := shr(right, shl(left, val))
            }

            // load the length of the calldata array
            let len := calldataload(sub(tokenIds.offset, 0x20))

            let stake__cache := sload(stake.slot)

            let shrs := shr(192, stake__cache)

            let activeEps := div(iso(stake__cache, 64, 160), shrs)

            // ======================================================================
            // memory layout as offset from mptr:
            // ==========================
            // 0x00: tokenId                keccak = agency[tokenId].slot = "agency__sptr"
            // 0x20: agency.slot
            // --------------------------
            // 0x40: agency__cache
            // --------------------------
            // 0x60: agents address[]
            // ==========================

            let mptr := mload(0x40)

            // store agency slot for continuous calculation of storage pointers
            mstore(add(mptr, 0x20), agency.slot)

            // hold the cumlative value to send back to the user
            // it starts off with callvalue in case there is a fee for the user to pay
            // ...that is not covered by the amount earned
            let acc := callvalue()

            // holds the cumlitve fee of all tokens being rebalanced
            // this is the amount to stake
            let accFee := 0

            for {
                let i := 0
            } lt(i, len) {
                i := add(i, 0x1)
            } {
                // get a tokenId from calldata and store it to mem pos 0x00
                mstore(mptr, calldataload(add(tokenIds.offset, mul(i, 0x20))))

                let agency__sptr := keccak256(mptr, 0x40)

                //
                let agency__cache := sload(keccak256(mptr, 0x40))

                let agency__addr := iso(agency__cache, 96, 96)

                // make sure this token is loaned
                if iszero(eq(shr(254, agency__cache), 0x02)) {
                    mstore8(0x0, Error__NotLoaned__0x33)
                    revert(0x00, 0x01)
                }

                // is the caller different from the agent?
                if iszero(eq(caller(), agency__addr)) {
                    // if so: ensure the loan is expired
                    if iszero(lt(add(iso(agency__cache, 2, 232), LIQUIDATION_PERIOD), active)) {
                        mstore8(0x0, 0x3B) // ERR:0x3B
                        revert(0x00, 0x01)
                    }
                }

                // parse agency for principal, converting it back to eth
                // represents the value that has been sent to the user for this loan
                let principal := mul(iso(agency__cache, 26, 186), LOSS)

                // the amount of value earned by this token since last rebalance
                // must be computed because fee needs to be paid
                // increase in earnings per share since last rebalance
                let earn := sub(activeEps, principal)

                // the maximum fee that can be levied
                // let fee := earn

                // true fee
                let fee := div(principal, REBALANCE_FEE_BPS)

                let value := add(earn, acc)

                if lt(value, fee) {
                    mstore8(0x0, Error__RebalancePaymentTooLow__0x3A)
                    revert(0x00, 0x01)
                }

                accFee := add(accFee, fee)

                acc := sub(value, fee)

                mstore(add(add(mptr, 0x60), mul(i, 0xA0)), agency__addr)

                // set the agency temporarily to 1 to avoid reentrancy
                // reentrancy here referes to a tokenId being passed multiple times in the calldata array
                // the only value that actually matters here is the "flag", but since it is reset below
                // ... we can just set the entire agency to 1
                sstore(agency__sptr, 0x01)
            }

            let pro := div(accFee, PROTOCOL_FEE_BPS)

            stake__cache := add(stake__cache, or(shl(96, sub(accFee, pro)), pro))

            sstore(stake.slot, stake__cache)

            let newPrincipal := div(iso(stake__cache, 64, 160), mul(shrs, LOSS))

            for {
                let i := 0
            } lt(i, len) {
                i := add(i, 0x1)
            } {
                mstore(mptr, calldataload(add(tokenIds.offset, mul(i, 0x20))))

                let account := mload(add(add(mptr, 0x60), mul(i, 0xA0)))

                // update agency to reflect new principle and epoch
                // ==========================
                // agency[tokenId] = {
                //     flag  = LOAN(0x02)
                //     epoch = active
                //     eth   = eps
                //     addr  = loaner
                // }
                // =========================
                let agency__cache := or(shl(254, 0x2), or(shl(230, active), or(shl(160, newPrincipal), account)))

                sstore(keccak256(mptr, 0x40), agency__cache)

                mstore(add(mptr, 0x40), agency__cache)

                log2(add(mptr, 0x40), 0x32, Event__Rebalance, mload(mptr))
            }

            // ======================================================================

            // log1 with topic "Stake(bytes32)"
            mstore(mptr, stake__cache)
            log1(mptr, 0x32, Event__Stake)

            // accumulated eth is sent to caller
            if iszero(call(gas(), caller(), acc, 0, 0, 0, 0)) {
                mstore8(0x0, Error__SendEthFailureToCaller__0x92)
                revert(0x00, 0x01)
            }
        }
    }

    function calc(uint96 principal, uint96 activeEps)
        internal
        pure
        returns (
            // uint96 debt,
            uint96 fee,
            uint96 earn
        )
    {
        // principal can never be below activeEps
        // assert(principal <= activeEps);

        assembly {
            fee := sub(activeEps, principal)

            let checkFee := div(principal, REBALANCE_FEE_BPS)

            if gt(fee, checkFee) {
                earn := sub(fee, checkFee)
                fee := checkFee
            }
        }
    }

    /// @inheritdoc INuggftV1Loan
    function debt(uint160 tokenId)
        public
        view
        returns (
            bool isLoaned,
            address account,
            uint96 prin,
            uint96 fee,
            uint96 earn,
            uint24 expire
        )
    {
        uint96 activeEps = eps();

        assembly {
            let mptr := mload(0x40)

            mstore(mptr, tokenId)
            mstore(add(mptr, 0x20), agency.slot)

            let agency__cache := sload(keccak256(mptr, 0x40))

            if iszero(eq(shr(254, agency__cache), 0x02)) {
                return(0x00, 0x00)
            }

            isLoaned := 0x01

            expire := add(shr(230, agency__cache), LIQUIDATION_PERIOD)

            account := agency__cache

            prin := mul(shr(186, shl(26, agency__cache)), LOSS)

            earn := sub(activeEps, prin)

            // fee := earn

            fee := div(prin, REBALANCE_FEE_BPS)

            // if gt(fee, checkFee) {
            //     // earn := sub(fee, checkFee)
            //     fee := checkFee
            // }
        }
    }

    /// @notice vfr: "Value For Rebalance"
    /// @inheritdoc INuggftV1Loan
    function vfr(uint160[] calldata tokenIds) external view returns (uint96[] memory vals) {
        vals = new uint96[](tokenIds.length);
        for (uint256 i = 0; i < vals.length; i++) {
            (bool ok, , , uint96 fee, uint96 earn, ) = debt(tokenIds[i]);

            if (!ok) continue;

            if (ok && fee > earn) {
                vals[i] = fee - earn;
            }
        }
    }

    /// @notice vfl: "Value For Liquidate"
    /// @inheritdoc INuggftV1Loan
    function vfl(uint160[] calldata tokenIds) external view returns (uint96[] memory vals) {
        vals = new uint96[](tokenIds.length);
        for (uint256 i = 0; i < vals.length; i++) {
            (bool ok, , uint96 prin, uint96 fee, uint96 earn, ) = debt(tokenIds[i]);

            if (ok && (prin = prin + fee) > earn) {
                vals[i] = prin - earn;
            }
        }
    }
}
