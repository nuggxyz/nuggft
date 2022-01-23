abstract contract NuggftV1Constants {
    uint256 constant LOSS = .1 gwei;

    // epoch
    uint16 constant INTERVAL = 69;
    uint24 constant OFFSET = 3000;

    // loan
    uint24 constant LIQUIDATION_PERIOD = 2;
    uint96 constant REBALANCE_FEE_BPS = 100;

    // swap
    uint256 constant SALE_LEN = 1;

    // events
    bytes32 constant TRANSFER = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 constant STAKE = 0xaa5755b13aae1e22c9577b90686d1db9a410d173607fc31d743b5d26182e18d5;
    bytes32 constant REBALANCE = 0x4cdd6143e1dfcbcf11937a29941c151f57e9467e19fcff2bf87ce9b4255c92bd;
    bytes32 constant LIQUIDATE = 0x7dc78d32e32a79dbb28ffc73e80d5c0d1961c893f5b437aa8328ab854f08e09f;
    bytes32 constant LOAN = 0x764dd32e4d33677f4bc9a37133c10ecef6409f7feb33af67a31d1fb01b392867;
    bytes32 constant CLAIM = 0x938187ad30d2557f8eb68b094a2305a858ec4f65c86a957b4bc26d9c0a496fef;
    bytes32 constant CLAIMITEM = 0x7a0576b9edc37a53c7e05ae220b6a871cf584ae6724a63f704609baec1e72853;
    bytes32 constant SELL = 0x251e78527ba3c62fcb4405d22087f8ab0c434b97b46e2d7f020d112e763171b3;
    bytes32 constant OFFER = 0x82cc12214e0c6e2eaeafbb2aaf730e41d45e9cc2d0467fb2f0fcf709e9443886;

    // errors
    uint8 constant Error__NotAgent = 0x2A;
    uint8 constant Error__NotOwner = 0x2C;
}
