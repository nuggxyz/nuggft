// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

/// @author nugg.xyz - danny7even and dub6ix - 2022
abstract contract NuggftV1Constants {
	uint96 constant STARTING_PRICE = .005 ether;

	uint24 constant OFFSET = 1; // must be > 0

	uint24 constant MINT_OFFSET = 1000000;

	uint24 constant MAX_TOKENS = type(uint24).max;

	uint96 constant LOSS = 10**14;

	uint96 constant MIN_BID_MINUS_LOSS = 10;

	// the portion of all other earnings to protocol
	uint96 constant PROTOCOL_FEE_FRAC = 10;

	// the portion added to mints that goes to protocol
	// need in event
	uint96 constant PROTOCOL_FEE_FRAC_MINT = 1;

	// the portion of overpayment to protocol
	uint96 constant PROTOCOL_FEE_FRAC_MINT_DIV = 2;

	// epoch
	uint8 constant INTERVAL_SUB = 16;

	uint24 constant INTERVAL = 8;

	// need in event
	uint24 constant PREMIUM_DIV = 2000;

	uint96 constant BASE_BPS = 10000;

	uint96 constant INCREMENT_BPS = 10500;

	// warning: causes liq and reb noFallback tests to break with +-1 wei rounding error if 600
	uint96 constant REBALANCE_FEE_BPS = 100;

	// uint256 constant FLAG_NONE = 0x0;
	// uint256 constant FLAG_SWAP = 0x1;
	// uint256 constant FLAG_LOAN = 0x2;
	// uint256 constant FLAG_OWN = 0x3;

	// loan
	uint24 constant LIQUIDATION_PERIOD = 4;

	// uint256 constant MAX_THROTTLE_PERCENT = 50;
	// uint256 constant THROTTLE_INCREMENT_PERCENT = 5;
	// uint256 constant THROTTLE_BLOCK_DURATION = 5;
	// uint256 constant THROTTLE_START_WITH_REMAINING_BLOCKS = 45;

	// swap
	uint256 constant SALE_LEN = 4;

	uint8 constant AVJB = 50;
	uint8 constant AFJB = 2;
	uint8 constant AAJB = 160;
	uint8 constant AEJB = 44;

	uint8 constant AVJO = 160;
	uint8 constant AFJO = 254;
	uint8 constant AAJO = 0;
	uint8 constant AEJO = 210;

	uint8 constant AVJR = 206;
	uint8 constant AFJR = 254;
	uint8 constant AAJR = 96;
	uint8 constant AEJR = 212;

	uint8 constant AVJL = 46;
	uint8 constant AFJL = 0;
	uint8 constant AAJL = 96;
	uint8 constant AEJL = 2;

	// uint8 constant AVJB = 70;
	// uint8 constant AFJB = 2;
	// uint8 constant AAJB = 160;
	// uint8 constant AEJB = 24;

	// uint8 constant AVJO = 160;
	// uint8 constant AFJO = 254;
	// uint8 constant AAJO = 0;
	// uint8 constant AEJO = 230;

	// uint8 constant AVJR = 186;
	// uint8 constant AFJR = 254;
	// uint8 constant AAJR = 96;
	// uint8 constant AEJR = 232;

	// uint8 constant AVJL = 26;
	// uint8 constant AFJL = 0;
	// uint8 constant AAJL = 96;
	// uint8 constant AEJL = 2;

	// event Rebalance(uint24,bytes32);
	// event Liquidate(uint24,bytes32);
	// event MigrateV1Accepted(address,uint24,bytes32,address,uint96);
	// event Extract(uint96);
	// event MigratorV1Updated(address);
	// event MigrateV1Sent(address,uint24,bytes32,address,uint96);
	// event Burn(uint24,address,uint96);
	// event Stake(bytes32);
	// event Rotate(uint24,bytes32);
	// event Mint(uint24,uint96,bytes32,bytes32,bytes32);
	// event Offer(uint24,bytes32,bytes32);
	// event OfferMint(uint24,bytes32,bytes32,bytes32);
	// event Claim(uint24,address);
	// event Sell(uint24,bytes32);
	// event TrustUpdated(address,bool);
	// event OfferItem(uint24,uint16,bytes32,bytes32);
	// event ClaimItem(uint24,uint16,uint24,bytes32);
	// event SellItem(uint24,uint16,bytes32,bytes32);

	// events
	bytes32 constant Event__Transfer = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
	bytes32 constant Event__Stake = 0xaa5755b13aae1e22c9577b90686d1db9a410d173607fc31d743b5d26182e18d5;
	bytes32 constant Event__Loan = 0x9fee03d24f4262ff4c5fb3232ff16949f4dccdd085da00bf1f1193c3723eee53;
	bytes32 constant Event__Claim = 0x41a23341bbb80e8168a44690c9c4a06ea716a81135bfd91090e02eb9f512dfed;
	bytes32 constant Event__Sell = 0xa22a2f700e25812c5b49134de558e904b32f69ebbb066950e5bfd52e3f65339e;
	bytes32 constant Event__Offer = 0x4c15f3795daf7602f4762cff646acbca438577dc8ba33ed2af7f2d37f321cbd1;
	bytes32 constant Event__Rotate = 0x3164c3636b11a9bb92d737b9969a71092afc31f7e1559858875ba56e59167402;

	bytes32 constant Event_TransferBatch = 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb;
	bytes32 constant Event_TransferSingle = 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62;

	uint64 constant Function__transfer = 0x80c15e11;

	uint8 constant Error__0x65__TokenNotMintable = 0x65;
	uint8 constant Error__0x66__TokenNotTrustMintable = 0x66;
	uint8 constant Error__0x67__WinningClaimTooEarly = 0x67;
	uint8 constant Error__0x68__OfferLowerThanLOSS = 0x68;
	uint8 constant Error__0x69__Wut = 0x69;
	uint8 constant Error__0x70__FloorTooLow = 0x70;
	uint8 constant Error__0x71__ValueTooLow = 0x71;
	uint8 constant Error__0x72__IncrementTooLow = 0x72;
	uint8 constant Error__0x73__InvalidProofIndex = 0x73;
	uint8 constant Error__0x74__Untrusted = 0x74;
	uint8 constant Error__0x75__SendEthFailureToCaller = 0x75;
	uint8 constant Error__0x76__InvalidArrayLengths = 0x76;
	uint8 constant Error__0x77__NotOwner = 0x77;
	uint8 constant Error__0x78__TokenDoesNotExist = 0x78;
	uint8 constant Error__0x79__ProofHasNoFreeSlot = 0x79;
	uint8 constant Error__0x80__TokenDoesExist = 0x80;
	uint8 constant Error__0x81__MigratorNotSet = 0x81;
	uint8 constant Error__0x97__ItemAgencyAlreadySet = 0x97;
	uint8 constant Error__0x98__BlockHashIsZero = 0x98;
	uint8 constant Error__0x99__InvalidEpoch = 0x99;
	uint8 constant Error__0xA0__NotSwapping = 0xA0;
	uint8 constant Error__0xA1__NotAgent = 0xA1;
	uint8 constant Error__0xA2__NotItemAgent = 0xA2;
	uint8 constant Error__0xA3__NotItemAuthorizedAgent = 0xA3;
	uint8 constant Error__0xA4__ExpiredEpoch = 0xA4;
	uint8 constant Error__0xA5__NoOffer = 0xA5;
	uint8 constant Error__0xA6__NotAuthorized = 0xA6;
	uint8 constant Error__0xA7__LiquidationPaymentTooLow = 0xA7;
	uint8 constant Error__0xA8__NotLoaned = 0xA8;
	uint8 constant Error__0xA9__ProofDoesNotHaveItem = 0xA9;
	uint8 constant Error__0xAA__RebalancePaymentTooLow = 0xAA;
	uint8 constant Error__0xAB__NotLiveItemSwap = 0xAB;
	uint8 constant Error__0xAC__MustFinalizeOtherItemSwap = 0xAC;
	uint8 constant Error__0xAD__InvalidZeroProof = 0xAD;
	uint8 constant Error__0xAE__FailedCallToItemsHolder = 0xAE;
	uint8 constant Error__0xAF__MulticallError = 0xAF;
	uint8 constant Error__0xB0__InvalidMulticall = 0xB0;
	uint8 constant Error__0xB1__InvalidMulticallValue = 0xB1;
	uint8 constant Error__0xB2__UnexpectedIncrement = 0xB2;
	uint8 constant Error__0xB3__NuggIsNotItemAgent = 0xB3;
	uint8 constant Error__0xB4__MustFinalizeOtherItemSwapFromThisEpoch = 0xB4;

	error Revert(bytes1);

	bytes4 constant Revert__Sig = 0x7e863b48;

	function _panic(uint8 code) internal pure {
		assembly {
			mstore(0x00, Revert__Sig)
			mstore8(0x4, code)
			revert(0x00, 0x5)
		}
	}

	function _repanic(bool yes, uint8 code) internal pure {
		if (!yes) _panic(code);
	}
}
