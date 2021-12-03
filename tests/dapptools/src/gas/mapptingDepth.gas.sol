// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import '../../lib/DSTestExtended.sol';

contract mappingDepth is DSTestExtended {
    mapping(uint256 => uint256) internal _one;
    mapping(uint256 => mapping(uint256 => uint256)) internal _two;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) internal _three;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256)))) internal _four;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))))))))
        internal _eight;

    function test_setOne() public {
        uint64 a = type(uint64).max;
        uint64 b = type(uint64).max;
        uint64 c = type(uint64).max;
        uint64 d = type(uint64).max;

        uint256 z = type(uint256).max;

        uint128 ab = (a << 64) | b;
        uint128 cd = (c << 64) | d;

        uint128 abcd = (ab << 128) | cd;

        _one[abcd] = z;
    }

    function test_setTwo() public {
        uint64 a = type(uint64).max;
        uint64 b = type(uint64).max;
        uint64 c = type(uint64).max;
        uint64 d = type(uint64).max;

        uint256 z = type(uint256).max;

        uint128 ab = (a << 128) | b;
        uint128 cd = (c << 128) | d;

        _two[ab][cd] = z;
    }

    function test_setThree() public {
        uint64 a = type(uint64).max;
        uint64 b = type(uint64).max;
        uint64 c = type(uint64).max;
        uint64 d = type(uint64).max;

        uint256 z = type(uint256).max;

        uint128 ab = (a << 128) | b;

        _three[ab][c][d] = z;
    }

    function test_setFour() public {
        uint64 a = type(uint64).max;
        uint64 b = type(uint64).max;
        uint64 c = type(uint64).max;
        uint64 d = type(uint64).max;

        uint256 z = type(uint256).max;

        _four[a][b][c][d] = z;
    }

    function test_setEight() public {
        uint64 a = type(uint64).max;
        uint64 b = type(uint64).max;
        uint64 c = type(uint64).max;
        uint64 d = type(uint64).max;

        uint256 z = type(uint256).max;

        _eight[a][b][c][d][a][b][c][d] = z;
    }
}
