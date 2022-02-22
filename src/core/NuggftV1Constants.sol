// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

abstract contract NuggftV1Constants {
    uint32 constant TRUSTED_MINT_TOKENS = 500;
    uint32 constant UNTRUSTED_MINT_TOKENS = 10000;

    uint256 constant LOSS = .1 gwei;
    uint8 constant HOT_PROOF_AMOUNT = 16;
    // stake
    uint96 constant PROTOCOL_FEE_BPS = 10;

    // epoch
    uint8 constant INTERVAL_SUB = 4;
    uint16 constant MINT_INTERVAL = 4;

    uint16 constant INTERVAL = 256;
    uint24 constant OFFSET = 3000;

    // loan
    uint24 constant LIQUIDATION_PERIOD = 1024;
    uint96 public constant REBALANCE_FEE_BPS = 100;

    // swap
    uint256 constant SALE_LEN = 1;

    // events
    bytes32 constant Event__Transfer = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 constant Event__Stake = 0xaa5755b13aae1e22c9577b90686d1db9a410d173607fc31d743b5d26182e18d5;
    bytes32 constant Event__Rebalance = 0x4cdd6143e1dfcbcf11937a29941c151f57e9467e19fcff2bf87ce9b4255c92bd;
    bytes32 constant Event__Liquidate = 0x7dc78d32e32a79dbb28ffc73e80d5c0d1961c893f5b437aa8328ab854f08e09f;
    bytes32 constant Event__Loan = 0x764dd32e4d33677f4bc9a37133c10ecef6409f7feb33af67a31d1fb01b392867;
    bytes32 constant Event__Claim = 0x938187ad30d2557f8eb68b094a2305a858ec4f65c86a957b4bc26d9c0a496fef;
    bytes32 constant Event__ClaimItem = 0x9cdb8f349681fb33da8eae743ee1c7f93ab8fbeeded70db2ed922ac97cef1dff;
    bytes32 constant Event__Sell = 0x251e78527ba3c62fcb4405d22087f8ab0c434b97b46e2d7f020d112e763171b3;
    bytes32 constant Event__SellItem = 0x91326786da537fd0b77dd15cd4ab14aa79e51ebb26c238b77abc403ad5ad61ef;
    bytes32 constant Event__Offer = 0x82cc12214e0c6e2eaeafbb2aaf730e41d45e9cc2d0467fb2f0fcf709e9443886;
    bytes32 constant Event__Repayment = 0xc928c04c08e9d5085139dee5b4b0a24f48d84c91f8f44caefaea39da6108fce3;
    bytes32 constant Event__OfferItem = 0xece1c1f9e5c92bf1d13cc47d0a5d490cbbc4be21c8d492368d4b8a8aba35e41d;
    bytes32 constant Event__TransferItem = 0x31cf2357b228de5e7b21be4ee816920a4eabd32196b782ad557ba4a0f5c20af1;
    bytes32 constant Event__Mint = 0x7fa02ea2addb9a3ae24bb783f3817cbebd2aaa24af58c5eee6faf5b776797f95;
    bytes32 constant Event__Rotate = 0x9a674c377cfb461eed8c85cebc9fc607ef62cecde152900174f519f861f90b57;
    bytes32 constant Event__OfferMint = 0x4ab47a8596088efecb0e4588e1fa409c1173c35ad3530cc3eee52dd1bbecf1b6;

    error Revert(bytes1);

    bytes4 constant Revert__Sig = 0x7e863b48;

    bytes1 constant Error__0x65__TokenNotMintable = 0x65;
    bytes1 constant Error__0x66__TokenNotTrustMintable = 0x66;
    bytes1 constant Error__0x67__WinningClaimTooEarly = 0x67;
    bytes1 constant Error__0x68__OfferLowerThanLOSS = 0x68;
    bytes1 constant Error__0x69__Wut = 0x69;
    bytes1 constant Error__0x70__FloorTooLow = 0x70;
    bytes1 constant Error__0x71__ValueTooLow = 0x71;
    bytes1 constant Error__0x72__IncrementTooLow = 0x72;
    bytes1 constant Error__0x73__InvalidProofIndex = 0x73;
    bytes1 constant Error__0x74__Untrusted = 0x74;
    bytes1 constant Error__0x75__SendEthFailureToCaller = 0x75;
    bytes1 constant Error__0x76__InvalidArrayLengths = 0x76;
    bytes1 constant Error__0x77__NotOwner = 0x77;
    bytes1 constant Error__0x78__TokenDoesNotExist = 0x78;
    bytes1 constant Error__0x79__ProofHasNoFreeSlot = 0x79;
    bytes1 constant Error__0x80__TokenDoesExist = 0x80;
    bytes1 constant Error__0x81__MigratorNotSet = 0x81;
    bytes1 constant Error__0x97__ItemAgencyAlreadySet = 0x97;
    bytes1 constant Error__0x98__BlockHashIsZero = 0x98;
    bytes1 constant Error__0x99__InvalidEpoch = 0x99;
    bytes1 constant Error__0xA0__NotSwapping = 0xA0;
    bytes1 constant Error__0xA1__NotAgent = 0xA1;
    bytes1 constant Error__0xA2__NotItemAgent = 0xA2;
    bytes1 constant Error__0xA3__NotItemAuthorizedAgent = 0xA3;
    bytes1 constant Error__0xA4__ExpiredEpoch = 0xA4;
    bytes1 constant Error__0xA5__NoOffer = 0xA5;
    bytes1 constant Error__0xA6__NotAuthorized = 0xA6;
    bytes1 constant Error__0xA7__LiquidationPaymentTooLow = 0xA7;
    bytes1 constant Error__0xA8__NotLoaned = 0xA8;
    bytes1 constant Error__0xA9__ProofDoesNotHaveItem = 0xA9;
    bytes1 constant Error__0xAA__RebalancePaymentTooLow = 0xAA;

    function _panic(bytes1 code) internal pure {
        assembly {
            mstore(0x00, Revert__Sig)
            mstore(0x04, code)
            revert(0x00, 0x5)
        }
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
