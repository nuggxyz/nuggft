// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

abstract contract NuggftV1Constants {
    uint96 constant STARTING_PRICE = .001 ether;

    uint24 constant TRUSTED_MINT_TOKENS = 1000;

    uint24 constant OFFSET = 1; // must be > 0

    uint24 constant MINT_OFFSET = 1000000;

    uint24 constant MAX_TOKENS = type(uint24).max;

    uint256 constant HOT_PROOF_EMPTY = 0x10000;

    uint96 constant LOSS = .1 gwei;

    // the portion of all other earnings to protocol
    uint96 constant PROTOCOL_FEE_FRAC = 10;

    // the portion added to mints that goes to protocol
    uint96 constant PROTOCOL_FEE_FRAC_MINT = 1;

    // the portion of overpayment to protocol
    uint96 constant PROTOCOL_FEE_FRAC_MINT_DIV = 2;

    // epoch
    uint8 constant INTERVAL_SUB = 16;

    uint24 constant INTERVAL = 64;

    uint24 constant PREMIUM_DIV = 2000;

    uint96 constant BASE_BPS = 10000;

    uint96 constant INCREMENT_BPS = 10500;

    // warning: causes liq and reb noFallback tests to break with +-1 wei rounding error if 600
    uint96 public constant REBALANCE_FEE_BPS = 100;

    // loan
    uint24 constant LIQUIDATION_PERIOD = 200;

    // swap
    uint256 constant SALE_LEN = 1;

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
    bytes32 constant Event__Rebalance = 0xeb8e55e8fc88bc9f628322210d29573d744e485c0d6187a21a714f78d7d061b4;
    bytes32 constant Event__Liquidate = 0x7fd4eefc393ae5de976724f1b15e506c4a3defc689243aaed3055caac17fb264;
    bytes32 constant Event__Loan = 0x9fee03d24f4262ff4c5fb3232ff16949f4dccdd085da00bf1f1193c3723eee53;
    bytes32 constant Event__Claim = 0xbacda7540a51e78a634d77c6141a7d5a880d452aaa9eadbd7dcf76f28df7116d;
    bytes32 constant Event__ClaimItem = 0xcd1615176b23cfc579068e17d243a2b8aa647d8052f1f285153e4d2464c5faf8;
    bytes32 constant Event__Sell = 0x8db33e627ce35c1bbfb6417c838e02c148d2c95bed15ec87fdaf3855d0afbb8c;
    bytes32 constant Event__SellItem = 0xe6b9f9b164a3157991009234a9a3018382c7bef2519e6293bfa9e496174fbbcb;
    bytes32 constant Event__Offer = 0x4c15f3795daf7602f4762cff646acbca438577dc8ba33ed2af7f2d37f321cbd1;
    bytes32 constant Event__Repayment = 0xc928c04c08e9d5085139dee5b4b0a24f48d84c91f8f44caefaea39da6108fce3;
    bytes32 constant Event__OfferItem = 0xe8cac8b90eb1aeaafc7f3d81f15f23eb57e6855f3045d04c8b7ca5e49560bb6b;
    bytes32 constant Event__Mint = 0xf361d74158bc4afac21219557dde72e7cd117ff4502a0912efa7611ea209d561;
    bytes32 constant Event__Rotate = 0x3164c3636b11a9bb92d737b9969a71092afc31f7e1559858875ba56e59167402;
    bytes32 constant Event__OfferMint = 0x4698de13feeaed20868f2b3ea382b32ad4ba5de37e7b73a101ef23a886a2dd04;

    uint64 constant Function__transferSingle = 0x49a035e3;
    uint64 constant Function__transferBatch = 0xdec6d46d;

    error Revert(bytes1);

    uint40 constant Revert__Sig = 0x7e863b4800;

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

    // uint8 constant Error__0xAE__InvalidZeroProof = 0xAD;

    function _panic(uint8 code) internal pure {
        assembly {
            mstore(0x00, Revert__Sig)
            mstore8(31, code)
            revert(27, 0x5)
        }
    }

    function _repanic(bool yes, uint8 code) internal pure {
        if (!yes) _panic(code);
    }
}

// bytes4 constant Error__TokenNotMintable = bytes4(abi.encodeWithSignature('TokenNotMintable()')); // 0x65__TokenNotMintable

// bytes4 constant Error__TokenNotTrustMintable = bytes4(abi.encodeWithSignature('TokenNotTrustMintable()'));

// bytes4 constant Error__WinningClaimTooEarly = bytes4(abi.encodeWithSignature('WinningClaimTooEarly()'));

// bytes4 constant Error__OfferLowerThanLOSS = bytes4(abi.encodeWithSignature('OfferLowerThanLOSS()'));

// bytes4 constant Error__Wut = bytes4(abi.encodeWithSignature('Wut()'));

// bytes4 constant Error__FloorTooLow = bytes4(abi.encodeWithSignature('FloorTooLow()'));

// bytes4 constant Error__ValueTooLow = bytes4(abi.encodeWithSignature('ValueTooLow()'));

// bytes4 constant Error__IncrementTooLow = bytes4(abi.encodeWithSignature('IncrementTooLow()'));

// bytes4 constant Error__InvalidProofIndex = bytes4(abi.encodeWithSignature('InvalidProofIndex()'));

// bytes4 constant Error__Untrusted = bytes4(abi.encodeWithSignature('Untrusted()'));

// bytes4 constant Error__SendEthFailureToCaller = bytes4(abi.encodeWithSignature('SendEthFailureToCaller()'));

// bytes4 constant Error__InvalidArrayLengths = bytes4(abi.encodeWithSignature('InvalidArrayLengths()'));

// bytes4 constant Error__NotOwner = bytes4(abi.encodeWithSignature('NotOwner()'));

// bytes4 constant Error__TokenDoesNotExist = bytes4(abi.encodeWithSignature('TokenDoesNotExist()'));

// bytes4 constant Error__ProofHasNoFreeSlot = bytes4(abi.encodeWithSignature('ProofHasNoFreeSlot()'));

// bytes4 constant Error__TokenDoesExist = bytes4(abi.encodeWithSignature('TokenDoesExist()'));

// bytes4 constant Error__0x66__TokenNotTrustMintable = 0x3c962da2;  error TokenNotTrustMintable__0x66();
// bytes4 constant Error__0x67__WinningClaimTooEarly = 0x2a2cb709;    error WinningClaimTooEarly__0x67();
// bytes4 constant Error__0x68__OfferLowerThanLOSS = 0xae038e3d;        error OfferLowerThanLOSS__0x68();
// bytes4 constant Error__0x69__Wut = 0x163f6e5f;                                      error Wut__0x69();
// bytes4 constant Error__0x70__FloorTooLow = 0x6c6781e4;                      error FloorTooLow__0x70();
// bytes4 constant Error__0x71__ValueTooLow = 0xe64e0225;                      error ValueTooLow__0x71();
// bytes4 constant Error__0x72__IncrementTooLow = 0xa4e7d094;              error IncrementTooLow__0x72();
// bytes4 constant Error__0x73__InvalidProofIndex = 0x45f451ba;          error InvalidProofIndex__0x73();
// bytes4 constant Error__0x74__Untrusted = 0xc79dea53;                          error Untrusted__0x74();
// bytes4 constant Error__0x75__SendEthFailureToCaller = 0x2789ce21; error SendEthFailureToCaller__0x75();
// bytes4 constant Error__0x76__InvalidArrayLengths = 0xb83c1b80;      error InvalidArrayLengths__0x76();
// bytes4 constant Error__0x77__NotOwner = 0x71ebbd41;                            error NotOwner__0x77();
// bytes4 constant Error__0x78__TokenDoesNotExist = 0x1b23da5c;          error TokenDoesNotExist__0x78();
// bytes4 constant Error__0x79__ProofHasNoFreeSlot = 0x941a6f38;        error ProofHasNoFreeSlot__0x79();
// bytes4 constant Error__0x80__TokenDoesExist = 0xec16a2aa;                error TokenDoesExist__0x80();
// bytes4 constant Error__0x97__ItemAgencyAlreadySet = 0x2b5f209d;    error ItemAgencyAlreadySet__0x97();
// bytes4 constant Error__0x98__BlockHashIsZero = 0x498b90eb;              error BlockHashIsZero__0x98();
// bytes4 constant Error__0x99__InvalidEpoch = 0x72e1e2b1;                    error InvalidEpoch__0x99();
// bytes4 constant Error__0xA0__NotSwapping = 0xbd282b32;                      error NotSwapping__0xA0();
// bytes4 constant Error__0xA1__NotAgent = 0x5045c4a4;                            error NotAgent__0xA1();
// bytes4 constant Error__0xA2__NotItemAgent = 0xd516fa17;                    error NotItemAgent__0xA2();
// bytes4 constant Error__0xA3__NotItemAuthorizedAgent = 0x3c962da2; error NotItemAuthorizedAgent__0xA3();
// bytes4 constant Error__0xA4__ExpiredEpoch = 0x3c962da2;                    error ExpiredEpoch__0xA4();
// bytes4 constant Error__0xA5__NoOffer = 0x3c962da2;                              error NoOffer__0xA5();
// bytes4 constant Error__0xA6__NotAuthorized = 0x3c962da2;                  error NotAuthorized__0xA6();
// bytes4 constant Error__0xA7__LiquidationPaymentTooLow = 0x3c962da2; error LiquidationPaymentTooLow__0xA7();
// bytes4 constant Error__0xA8__NotLoaned = 0x3c962da2;                          error NotLoaned__0xA8();
// bytes4 constant Error__0xA9__ProofDoesNotHaveItem = 0x3c962da2;    error ProofDoesNotHaveItem__0xA9();
// bytes4 constant Error__0xAA__RebalancePaymentTooLow = 0x3c962da2; error RebalancePaymentTooLow__0xAA();
