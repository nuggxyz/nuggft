// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Epoch} from '../interfaces/nuggftv1/INuggftV1Epoch.sol';

/// @custom:testing OK
abstract contract NuggftV1Epoch is INuggftV1Epoch {
    uint256 public immutable genesis;

    uint16 constant INTERVAL = 69;
    uint24 constant OFFSET = 3000;

    uint256 constant LOSS = 1000000000;
    uint256 constant SALE_LEN = 1;

    bytes32 constant TRANSFER = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 constant STAKE = 0xaa5755b13aae1e22c9577b90686d1db9a410d173607fc31d743b5d26182e18d5;
    bytes32 constant REBALANCE = 0x4cdd6143e1dfcbcf11937a29941c151f57e9467e19fcff2bf87ce9b4255c92bd;
    bytes32 constant LIQUIDATE = 0x7dc78d32e32a79dbb28ffc73e80d5c0d1961c893f5b437aa8328ab854f08e09f;
    bytes32 constant LOAN = 0x764dd32e4d33677f4bc9a37133c10ecef6409f7feb33af67a31d1fb01b392867;
    bytes32 constant CLAIM = 0x938187ad30d2557f8eb68b094a2305a858ec4f65c86a957b4bc26d9c0a496fef;

    constructor() {
        genesis = block.number;
        emit Genesis(block.number, INTERVAL, OFFSET);
    }

    /// @inheritdoc INuggftV1Epoch
    function epoch() public view override returns (uint24 res) {
        require(block.number >= genesis, hex'03');
        res = toEpoch(block.number, genesis);
    }

    function calculateSeed() internal view returns (uint256 res, uint24 _epoch) {
        _epoch = epoch();
        res = calculateSeed(_epoch);
    }

    function tryCalculateSeed(uint24 _epoch) internal view returns (uint256 res) {
        res = calculateSeed(_epoch);
    }

    /// @notice calculates a random-enough seed that will stay the
    function calculateSeed(uint24 _epoch) internal view returns (uint256 res) {
        uint256 startblock = toStartBlock(_epoch, genesis);
        bytes32 bhash = getBlockHash(startblock - 2);
        require(bhash != 0, hex'0E');
        res = uint256(keccak256(abi.encodePacked(bhash, _epoch, address(this))));
    }

    function getBlockHash(uint256 blocknum) internal view virtual returns (bytes32 res) {
        return blockhash(blocknum);
    }

    function toStartBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        assembly {
            res := add(mul(sub(_epoch, OFFSET), INTERVAL), gen)
        }
    }

    function toEpoch(uint256 blocknum, uint256 gen) internal pure returns (uint24 res) {
        assembly {
            res := add(div(sub(blocknum, gen), INTERVAL), OFFSET)
        }
    }

    function toEndBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        unchecked {
            res = toStartBlock(_epoch + 1, gen) - 1;
        }
    }
}
