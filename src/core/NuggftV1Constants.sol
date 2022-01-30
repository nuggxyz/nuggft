// SPDX-License-Identifier: MIT

import '../_test/utils/forge.sol';

pragma solidity 0.8.11;

abstract contract NuggftV1Constants {
    uint256 constant LOSS = .1 gwei;

    // stake
    uint96 constant PROTOCOL_FEE_BPS = 10;

    // epoch
    uint16 constant INTERVAL_SUB = 2;
    uint16 constant MINT_INTERVAL = 16;

    uint16 constant INTERVAL = 69;
    uint24 constant OFFSET = 3000;

    // loan
    uint24 constant LIQUIDATION_PERIOD = 1000;
    uint96 public constant REBALANCE_FEE_BPS = 100;

    // swap
    uint256 constant SALE_LEN = 1;
    uint256 constant PULLS_SLOC = 0x99;

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

    // errors
    uint8 constant Error__0x09__ItemAgencyAlreadySet = 0x09;
    uint8 constant Error__0x0E__BlockHashIsZero = 0x0E;
    uint8 constant Error__0x0F__InvalidEpoch = 0x0F;
    uint8 constant Error__0x24__NotSwapping = 0x24;
    uint8 constant Error__0x2A__NotAgent = 0x2A;
    uint8 constant Error__0x2B__NotItemAgent = 0x2B;
    uint8 constant Error__0x2C__NotAthorized = 0x2C;
    uint8 constant Error__0x2D__NotItemAuthorizedAgent = 0x2D;
    uint8 constant Error__0x2F__ExpiredEpoch = 0x2F;
    uint8 constant Error__0x2E__NoOffer = 0x2E;
    uint8 constant Error__0x31__NotAuthorized = 0x31;
    uint8 constant Error__0x32__LiquidationPaymentTooLow = 0x32;
    uint8 constant Error__0x33__NotLoaned = 0x33;
    uint8 constant Error__0x34__ProofDoesNotHaveItem = 0x34;
    uint8 constant Error__0x3A__RebalancePaymentTooLow = 0x3A;
    uint8 constant Error__0x65__TokenNotMintable = 0x65;
    uint8 constant Error__0x66__TokenNotTrustMintable = 0x66;

    uint8 constant Error__0x67__WinningClaimTooEarly = 0x67;
    uint8 constant Error__0x68__ClaimTooEarly = 0x68;
    uint8 constant Error__0x69__Wut = 0x69;
    uint8 constant Error__0x70__FloorTooLow = 0x70;
    uint8 constant Error__0x71__ValueTooLow = 0x71;
    uint8 constant Error__0x72__IncrementTooLow = 0x72;
    uint8 constant Error__0x73__InvalidProofIndex = 0x73;
    uint8 constant Error__0x88__Untrusted = 0x88;
    uint8 constant Error__0x91__SendEthFailureToOther = 0x91;
    uint8 constant Error__0x92__SendEthFailureToCaller = 0x92;
    uint8 constant Error__0x99__InvalidArrayLengths = 0x99;
    uint8 constant Error__0xE9__NotOwner = 0xE9;
    uint8 constant Error__0xEE__TokenDoesNotExist = 0xEE;
    uint8 constant Error__0xF0__OfferLowerThanLOSS = 0xF0;
    uint8 constant Error__0xF9__ProofHasNoFreeSlot = 0xF9;

    function _panic(uint8 code) internal pure {
        assembly {
            mstore8(0, code)
            revert(0, 0x01)
        }
    }

    // stake
}
