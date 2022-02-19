// SPDX-License-Identifier: MIT

import '../_test/utils/forge.sol';

pragma solidity 0.8.12;

abstract contract NuggftV1Constants {
    uint256 constant LOSS = .1 gwei;

    // stake
    uint96 constant PROTOCOL_FEE_BPS = 8;

    // epoch
    uint16 constant INTERVAL_SUB = 2;
    uint16 constant MINT_INTERVAL = 4;

    uint16 constant INTERVAL = 69;
    uint24 constant OFFSET = 3000;

    // loan
    uint24 constant LIQUIDATION_PERIOD = 1024;
    uint96 public constant REBALANCE_FEE_BPS = 128;

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
    bytes32 constant Event__Mint = 0x7c80a7f346b69f118a49fc9d825f66c511507d357166e827c04de87b5a3df4a2;
    // errors

    uint8 constant Error__A__0x65__TokenNotMintable = 0x65; // 0x65__TokenNotMintable
    uint8 constant Error__B__0x66__TokenNotTrustMintable = 0x66; // 0x66__TokenNotTrustMintable
    uint8 constant Error__C__0x67__WinningClaimTooEarly = 0x67; // 0x67__WinningClaimTooEarly
    uint8 constant Error__D__0x68__OfferLowerThanLOSS = 0x68; // 0xF0__OfferLowerThanLOSS
    uint8 constant Error__E__0x69__Wut = 0x69; // 0x69__Wut
    uint8 constant Error__F__0x70__FloorTooLow = 0x70; // 0x70__FloorTooLow
    uint8 constant Error__G__0x71__ValueTooLow = 0x71; // 0x71__ValueTooLow
    uint8 constant Error__H__0x72__IncrementTooLow = 0x72; // 0x72__IncrementTooLow
    uint8 constant Error__I__0x73__InvalidProofIndex = 0x73; // 0x73__InvalidProofIndex
    uint8 constant Error__J__0x74__Untrusted = 0x74; // 0x88__Untrusted
    uint8 constant Error__K__0x75__SendEthFailureToCaller = 0x75; // 0x92__SendEthFailureToCaller
    uint8 constant Error__L__0x76__InvalidArrayLengths = 0x76; // 0x99__InvalidArrayLengths
    uint8 constant Error__M__0x77__NotOwner = 0x77; // 0xE9__NotOwner
    uint8 constant Error__N__0x78__TokenDoesNotExist = 0x78; // 0xEE__TokenDoesNotExist
    uint8 constant Error__O__0x79__ProofHasNoFreeSlot = 0x79; // 0xF9__ProofHasNoFreeSlot
    uint8 constant Error__P__0x80__TokenDoesExist = 0x80; // 0xF9__TokenDoesExist

    uint8 constant Error__a__0x97__ItemAgencyAlreadySet = 0x97; // Error__0x09__ItemAgencyAlreadySet
    uint8 constant Error__b__0x98__BlockHashIsZero = 0x98; // 0x0E__BlockHashIsZero
    uint8 constant Error__c__0x99__InvalidEpoch = 0x99; // 0x0F__InvalidEpoch
    uint8 constant Error__d__0xA0__NotSwapping = 0xA0; //_0x24__NotSwapping
    uint8 constant Error__e__0xA1__NotAgent = 0xA1; //0x2A__NotAgent
    uint8 constant Error__f__0xA2__NotItemAgent = 0xA2; // 0x2B__NotItemAgent
    uint8 constant Error__g__0xA3__NotItemAuthorizedAgent = 0xA3; // 0x2D__NotItemAuthorizedAgent
    uint8 constant Error__h__0xA4__ExpiredEpoch = 0xA4; // 0x2F__ExpiredEpoch
    uint8 constant Error__i__0xA5__NoOffer = 0xA5; // 0x2E__NoOffer
    uint8 constant Error__j__0xA6__NotAuthorized = 0xA6; // 0x31__NotAuthorized
    uint8 constant Error__k__0xA7__LiquidationPaymentTooLow = 0xA7; // 0x32__LiquidationPaymentTooLow
    uint8 constant Error__l__0xA8__NotLoaned = 0xA8; // 0x33__NotLoaned
    uint8 constant Error__m__0xA9__ProofDoesNotHaveItem = 0xA9; // 0x34__ProofDoesNotHaveItem
    uint8 constant Error__o__0xAA__RebalancePaymentTooLow = 0xAA; // 0x3A__RebalancePaymentTooLow

    function _panic(uint8 code) internal pure {
        assembly {
            mstore8(0, code)
            revert(0, 0x01)
        }
    }
}
