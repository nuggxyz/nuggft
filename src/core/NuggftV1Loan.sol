// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import {INuggftV1, INuggftV1Execute, INuggftV1Lens} from "git.nugg.xyz/nuggft/src/interfaces/INuggftV1.sol";

import {NuggftV1Swap} from "./NuggftV1Swap.sol";

/// @author nugg.xyz - danny7even and dub6ix - 2022
abstract contract NuggftV1Loan is NuggftV1Swap {
	/// @inheritdoc INuggftV1Execute
	function loan(uint24[] calldata tokenIds) external override {
		uint96 amt = eps();

		uint256 active = epoch();

		assembly {
			function juke(x, L, R) -> b {
				b := shr(R, shl(L, x))
			}

			function panic(code) {
				mstore(0x00, Revert__Sig)
				mstore8(0x4, code)
				revert(0x00, 0x5)
			}

			// load the length of the calldata array
			let len := calldataload(sub(tokenIds.offset, 0x20))

			let mptr := mload(0x40)

			// calculate agency.slot storeage ptr
			mstore(add(mptr, 0x20), agency.slot)

			// prettier-ignore
			for { let i := 0 } lt(i, len) { i := add(i, 0x1) } {
				// get a tokenId from calldata and store it to mem pos 0x00
				mstore(mptr, calldataload(add(tokenIds.offset, mul(i, 0x20))))

				let agency__sptr := keccak256(mptr, 0x40)

				// load agency value from storage
				let agency__cache := sload(agency__sptr)

				// ensure the caller is the agent
				if iszero(eq(juke(agency__cache, AAJL, AAJR), caller())) { panic(Error__0xA1__NotAgent) }

				// ensure the agent is the owner
				if iszero(eq(shr(AFJO, agency__cache), 0x1)) { panic(Error__0x77__NotOwner) }

				// compress amt into 70 bits
				amt := div(amt, LOSS)

				// update agency to reflect the loan

				// ==== agency[tokenId] ====
				//  flag  = LOAN(0x02)
				//  epoch = active
				//  eth   = eps / LOSS
				//  addr  = agent
				// =========================

				agency__cache := xor(caller(), xor(shl(AVJO, amt), xor(shl(AEJO, active), shl(AFJO, 0x2))))

				// store updated agency
				// done before external call to prevent reentrancy
				sstore(agency__sptr, agency__cache)

				// decompress amt back to eth
				// amt becomes a floored to LOSS version of eps()
				// ensures amt stored in agency and eth sent to caller are the same
				amt := mul(amt, LOSS)

				// send accumulated value * LOSS to msg.sender
				switch iszero(extcodesize(caller()))
				case 1 { pop(call(gas(), caller(), amt, 0, 0, 0, 0)) }
				default {
					// if someone really ends up here, just donate the eth
					let pro := div(amt, PROTOCOL_FEE_FRAC)

					let cache := add(sload(stake.slot), or(shl(96, sub(amt, pro)), pro))

					sstore(stake.slot, cache)

					mstore(0x00, cache)

					log1(0x00, 0x20, Event__Stake)
				}

				// log2 with "Loan(uint24,bytes32)" topic
				mstore(add(mptr, 0x40), agency__cache)

				log2(add(mptr, 0x40), 0x20, Event__Loan, mload(mptr))
			}
		}
	}

	/// @inheritdoc INuggftV1Execute
	function liquidate(uint24 tokenId) external payable override {
		uint256 active = epoch();
		address itemHolder = address(xnuggftv1);

		assembly {
			function juke(x, L, R) -> b {
				b := shr(R, shl(L, x))
			}

			function panic(code) {
				mstore(0x00, Revert__Sig)
				mstore8(0x4, code)
				revert(0x00, 0x5)
			}

			let stake__cache := sload(stake.slot)

			let shrs := shr(192, stake__cache)

			let activeEps := div(juke(stake__cache, 64, 160), shrs)

			let mptr := mload(0x40)

			// ========= memory ==========
			//   0x00: tokenId
			//   0x20: agency.slot
			// ===========================

			mstore(mptr, tokenId)
			mstore(add(mptr, 0x20), agency.slot)

			let agency__sptr := keccak256(mptr, 64)

			let agency__cache := sload(agency__sptr)

			let loaner := juke(agency__cache, AAJL, AAJR)

			// ensure that the agency flag is LOAN
			if iszero(eq(shr(AFJO, agency__cache), 0x02)) { panic(Error__0xA8__NotLoaned) }

			// check to see if msg.sender is the loaner
			if iszero(eq(caller(), loaner)) {
				// "is the loan past due"
				switch lt(add(juke(agency__cache, AEJL, AEJR), LIQUIDATION_PERIOD), active)
				case 1 {
					// if the loan is past due, then the liquidator recieves the nugg
					// this transfer event is the only extra logic required here since the
					// ... agency is updated to reflect "caller()" as the owner at the end
					log4(0x00, 0x00, Event__Transfer, loaner, caller(), tokenId)

					mstore(0x00, tokenId)
					mstore(0x20, proof.slot)

					let _proof := sload(keccak256(0x00, 0x40))

					mstore(0x00, Function__transfer)
					mstore(0x20, _proof)
					mstore(0x40, xor(address(), shl(160, and(tokenId, 0xffffff))))
					mstore(0x60, caller())

					pop(call(gas(), itemHolder, 0x00, 0x1C, 0x64, 0x00, 0x00))
				}
				default {
					// if not, then we revert.
					// only the "loaner" can liquidate unless the loan is past due
					panic(Error__0xA6__NotAuthorized)
				}
			}

			// parse agency for principal, converting it back to eth
			// represents the value that has been sent to the user for this loan
			let principal := mul(juke(agency__cache, AVJL, AVJR), LOSS)

			// the amount of value earned by this token since last rebalance
			// must be computed because fee needs to be paid
			// increase in earnings per share since last rebalance
			let earn := sub(activeEps, principal)

			// true fee
			let fee := add(div(principal, REBALANCE_FEE_BPS), principal)

			let value := add(earn, callvalue())

			if lt(value, fee) { panic(Error__0xA7__LiquidationPaymentTooLow) }

			earn := sub(value, fee)

			fee := sub(fee, principal)

			let pro := div(fee, PROTOCOL_FEE_FRAC)

			stake__cache := add(stake__cache, or(shl(96, sub(fee, pro)), pro))

			sstore(stake.slot, stake__cache)

			/////////////////////////////////////////////////////////////////////

			// update agency to return ownership of the token
			// done before external call to prevent reentrancy

			// ==== agency[tokenId] =====
			//     flag  = OWN(0x01)
			//     epoch = 0
			//     eth   = 0
			//     addr  = msg.sender
			// =========================

			agency__cache := or(caller(), shl(AFJO, 0x01))

			sstore(agency__sptr, agency__cache)

			/////////////////////////////////////////////////////////////////////

			// send accumulated value * LOSS to msg.sender
			if iszero(call(gas(), caller(), earn, 0, 0, 0, 0)) {
				// if someone really ends up here, just donate the eth
				pro := div(earn, PROTOCOL_FEE_FRAC)

				stake__cache := add(stake__cache, or(shl(96, sub(earn, pro)), pro))

				sstore(stake.slot, stake__cache)
			}

			/////////////////////////////////////////////////////////////////////

			// ========== event ==========
			// emit Stake(stake__cache)
			// ===========================

			mstore(0x00, stake__cache)
			log1(0x00, 0x20, Event__Stake)

			// ========== event ==========
			// emit Liquidate(tokenId, agency__cache)
			// ===========================

			mstore(0x00, agency__cache)
			log2(0x00, 0x20, Event__Loan, tokenId)
		}
	}

	/// @inheritdoc INuggftV1Execute
	function rebalance(uint24[] calldata tokenIds) external payable {
		uint256 active = epoch();

		assembly {
			function juke(x, L, R) -> b {
				b := shr(R, shl(L, x))
			}

			function panic(code) {
				mstore(0x00, Revert__Sig)
				mstore8(0x4, code)
				revert(0x00, 0x5)
			}

			// load the length of the calldata array
			let len := calldataload(sub(tokenIds.offset, 0x20))

			let stake__cache := sload(stake.slot)

			let shrs := shr(192, stake__cache)

			let activeEps := div(juke(stake__cache, 64, 160), shrs)

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

			// store agency slot for continuous calculation of storage pointers
			mstore(0x20, agency.slot)

			// hold the cumlative value to send back to the user
			// it starts off with callvalue in case there is a fee for the user to pay
			// ...that is not covered by the amount earned
			let acc := callvalue()

			// holds the cumlitve fee of all tokens being rebalanced
			// this is the amount to stake
			let accFee := 0

			// prettier-ignore
			for { let i := 0 } lt(i, len) { i := add(i, 0x1) } {
				// get a tokenId from calldata and store it to mem pos 0x00
				mstore(0x00, calldataload(add(tokenIds.offset, mul(i, 0x20))))

				let agency__sptr := keccak256(0x00, 0x40)

				//
				let agency__cache := sload(agency__sptr)

				let agency__addr := juke(agency__cache, AAJL, AAJR)

				// make sure this token is loaned
				if iszero(eq(shr(AFJO, agency__cache), 0x02)) { panic(Error__0xA8__NotLoaned) }

				// is the caller different from the agent?
				if iszero(eq(caller(), agency__addr)) {
					// if so: ensure the loan is expired
					// why? - only after a loan has expired are the "earnings" up for grabs.
					// otherwise only the loaner is entitled to them
					// TODO subtract some amount from LIQUIDATION_PERIOD here, to give rebalancers a head start
					if iszero(lt(add(juke(agency__cache, AEJL, AEJR), LIQUIDATION_PERIOD), active)) {
						panic(Error__0xA4__ExpiredEpoch) // ERR:0x3B
					}
				}

				// parse agency for principal, converting it back to eth
				// represents the value that has been sent to the user for this loan
				let principal := mul(juke(agency__cache, AVJL, AVJR), LOSS)

				// the amount of value earned by this token since last rebalance
				// must be computed because fee needs to be paid
				// increase in earnings per share since last rebalance
				let earn := sub(activeEps, principal)

				// the maximum fee that can be levied
				// let fee := earn

				// true fee
				let fee := div(principal, REBALANCE_FEE_BPS)

				let value := add(earn, acc)

				if lt(value, fee) { panic(Error__0xAA__RebalancePaymentTooLow) }

				accFee := add(accFee, fee)

				acc := sub(value, fee)

				mstore(add(0x60, mul(i, 0xA0)), agency__addr)

				// set the agency temporarily to 1 to avoid reentrancy
				// reentrancy here referes to a tokenId being passed multiple times in the calldata array
				// the only value that actually matters here is the "flag", but since it is reset below
				// ... we can just set the entire agency to 1
				sstore(agency__sptr, 0x01)
			}

			let pro := div(accFee, PROTOCOL_FEE_FRAC)

			stake__cache := add(stake__cache, or(shl(96, sub(accFee, pro)), pro))

			sstore(stake.slot, stake__cache)

			let newPrincipal := div(juke(stake__cache, 64, 160), mul(shrs, LOSS))

			// prettier-ignore
			for { let i := 0 } lt(i, len) { i := add(i, 0x1) } {
				mstore(0x00, calldataload(add(tokenIds.offset, mul(i, 0x20))))

				let account := mload(add(0x60, mul(i, 0xA0)))

				// update agency to reflect new principle and epoch
				// ==== agency[tokenId] =====
				//     flag  = LOAN(0x02)
				//     epoch = active
				//     eth   = eps
				//     addr  = loaner
				// =========================
				let agency__cache := or(shl(AFJO, 0x2), or(shl(AEJO, active), or(shl(AVJO, newPrincipal), account)))

				sstore(keccak256(0x00, 0x40), agency__cache)

				mstore(0x40, agency__cache)

				log2(0x40, 0x20, Event__Loan, mload(0x00))
			}

			// ======================================================================

			// send accumulated value * LOSS to msg.sender
			if iszero(call(gas(), caller(), acc, 0, 0, 0, 0)) {
				// if someone really ends up here, just donate the eth
				pro := div(acc, PROTOCOL_FEE_FRAC)

				stake__cache := add(stake__cache, or(shl(96, sub(acc, pro)), pro))

				sstore(stake.slot, stake__cache)
			}

			mstore(0x00, stake__cache)
			log1(0x00, 0x20, Event__Stake)
		}
	}

	function calc(
		uint96 principal,
		uint96 activeEps
	)
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

	/// @inheritdoc INuggftV1Lens
	function debt(uint24 tokenId)
		public
		view
		returns (bool isLoaned, address account, uint96 prin, uint96 fee, uint96 earn, uint24 expire)
	{
		uint96 activeEps = eps();

		assembly {
			function juke(x, L, R) -> b {
				b := shr(R, shl(L, x))
			}

			let mptr := mload(0x40)

			mstore(mptr, tokenId)
			mstore(add(mptr, 0x20), agency.slot)

			let agency__cache := sload(keccak256(mptr, 0x40))

			if iszero(eq(shr(AFJO, agency__cache), 0x02)) { return(0x00, 0x00) }

			isLoaned := 0x01

			expire := add(juke(agency__cache, AEJL, AEJR), LIQUIDATION_PERIOD)

			account := agency__cache

			prin := mul(juke(agency__cache, AVJL, AVJR), LOSS)

			earn := sub(activeEps, prin)

			fee := div(prin, REBALANCE_FEE_BPS)
		}
	}

	/// @notice vfr: "Value For Rebalance"
	/// @inheritdoc INuggftV1Lens
	function vfr(uint24[] calldata tokenIds) external view returns (uint96[] memory vals) {
		vals = new uint96[](tokenIds.length);
		for (uint256 i = 0; i < vals.length; i++) {
			(bool ok,,, uint96 fee, uint96 earn,) = debt(tokenIds[i]);

			if (!ok) continue;

			if (ok && fee > earn) {
				vals[i] = fee - earn;
			}
		}
	}

	/// @notice vfl: "Value For Liquidate"
	/// @inheritdoc INuggftV1Lens
	function vfl(uint24[] calldata tokenIds) external view returns (uint96[] memory vals) {
		vals = new uint96[](tokenIds.length);
		for (uint256 i = 0; i < vals.length; i++) {
			(bool ok,, uint96 prin, uint96 fee, uint96 earn,) = debt(tokenIds[i]);

			if (ok && (prin = prin + fee) > earn) {
				vals[i] = prin - earn;
			}
		}
	}
}
