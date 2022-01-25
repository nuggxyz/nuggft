// SPDX-License-Identifier: MIT

import '../_test/utils/forge.sol';

pragma solidity 0.8.11;

abstract contract NuggftV1Constants {
    uint256 constant LOSS = .1 gwei;

    // stake
    uint96 constant PROTOCOL_FEE_BPS = 10;

    // epoch
    uint16 constant INTERVAL = 256;
    uint24 constant OFFSET = 3000;

    // loan
    uint24 constant LIQUIDATION_PERIOD = 1000;
    uint96 constant REBALANCE_FEE_BPS = 100;

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
    bytes32 constant Event__ClaimItem = 0x7a0576b9edc37a53c7e05ae220b6a871cf584ae6724a63f704609baec1e72853;
    bytes32 constant Event__Sell = 0x251e78527ba3c62fcb4405d22087f8ab0c434b97b46e2d7f020d112e763171b3;
    bytes32 constant Event__Offer = 0x82cc12214e0c6e2eaeafbb2aaf730e41d45e9cc2d0467fb2f0fcf709e9443886;
    bytes32 constant Event__Repayment = 0x82cc12214e0c6e2eaeafbb2aaf730e41d45e9cc2d0467fb2f0fcf709e9443886;

    // errors
    uint8 constant Error__SendEthFailureToOther__0x91 = 0x91;
    uint8 constant Error__SendEthFailureToCaller__0x92 = 0x92;
    uint8 constant Error__InvalidArrayLengths__0x99 = 0x99;
    uint8 constant Error__NotAgent__0x2A = 0x2A;
    uint8 constant Error__NotOwner__0x2C = 0x2C;

    // swap
    uint8 constant Error__NotSwapping__0x24 = 0x24;
    uint8 constant Error__NotLoaned__0x33 = 0x33;
    uint8 constant Error__InvalidEpoch__0x0F = 0x0F;
    uint8 constant Error__ExpiredEpoch__0x2F = 0x2F;
    uint8 constant Error__WinningClaimTooEarly__0x67 = 0x67;
    uint8 constant Error__ClaimTooEarly__0x68 = 0x68;
    uint8 constant Error__NotAuthorized__0x31 = 0x31;
    uint8 constant Error__LiquidationPaymentTooLow__0x32 = 0x32;
    uint8 constant Error__RebalancePaymentTooLow__0x3A = 0x3A;

    // stake
    uint8 constant Error__ValueTooLow__0x71 = 0x71;
    uint8 constant Error__IncrementTooLow__0x72 = 0x72;
    uint8 constant Error__AlreadyForSale__0x2D = 0x2D;
}
