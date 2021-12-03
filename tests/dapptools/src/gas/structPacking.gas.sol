// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import '../../lib/DSTestExtended.sol';

contract AssemblyGasTest is DSTestExtended {
    struct Packed {
        address _address;
        uint32 _uint32;
        uint64 _uint64;
    }

    uint256 _shift_cold;

    Packed _pack_cold;

    uint256 _shift_warm = 42;

    Packed _pack_warm = Packed({_address: address(this), _uint32: type(uint32).max, _uint64: type(uint64).max});

    function test_pack_SSTORE() public {
        _pack_cold = encodeStructPack(address(1), 300, 300);
    }

    function test_pack_SLOAD() public view {
        decodeStructPack(_pack_warm);
    }

    function test_shift_SSTORE() public {
        _shift_cold = encodeByteShift(address(1), 300, 300);
    }

    function test_shift_SLOAD() public view {
        decodeByteShift(_shift_warm);
    }

    function decodeStructPack(Packed memory res)
        internal
        pure
        returns (
            address _address,
            uint64 _uint64,
            uint32 _uint32
        )
    {
        _address = res._address;
        _uint64 = res._uint64;
        _uint32 = res._uint32;
    }

    function encodeStructPack(
        address _address,
        uint64 _uint64,
        uint32 _uint32
    ) internal pure returns (Packed memory res) {
        res._address = _address;
        res._uint64 = _uint64;
        res._uint32 = _uint32;
    }

    function decodeByteShift(uint256 _unparsed)
        internal
        pure
        returns (
            address _address,
            uint64 _uint64,
            uint32 _uint32
        )
    {
        _uint32 = uint32(_unparsed >> (256 - 32));
        _uint64 = uint64(_unparsed >> (256 - 96));
        _address = address(uint160(_unparsed));
    }

    function encodeByteShift(
        address _address,
        uint64 _uint64,
        uint32 _uint32
    ) internal pure returns (uint256 res) {
        res = (uint256(_uint32) << (256 - 32)) | (uint256(_uint64) << (256 - 96)) | uint160(address(_address));
    }
}
