pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

import {ShiftLib} from "../../helpers/ShiftLib.sol";

abstract contract logic__ShiftLib is NuggftV1Test {
    function mask__safe__a(uint8 bits) public pure returns (uint256) {
        return (1 << bits) - 1;
    }

    function mask__safe__b(uint8 bits) public pure returns (uint256) {
        return 2**bits - 1;
    }

    function mask__safe__c(uint8 bits) public pure returns (uint256) {
        return 2**uint256(bits) - 1;
    }

    function test__logic__ShiftLib__gas__mask() public view trackGas returns (uint256 res) {
        uint8 input = 255;
        res = ShiftLib.mask(input);
    }

    function test__logic__ShiftLib__gas__mask__inline() public view trackGas returns (uint256 res) {
        uint8 input = 255;

        assembly {
            res := sub(shl(input, 1), 1)
        }
    }

    function test__logic__ShiftLib__gas__mask__safe__a() public view trackGas returns (uint256 res) {
        uint8 input = 255;

        res = mask__safe__a(input);
    }

    function test__logic__ShiftLib__gas__mask__safe__b() public view trackGas returns (uint256 res) {
        uint8 input = 255;

        res = mask__safe__b(input);
    }

    function test__logic__ShiftLib__gas__mask__safe__c() public view trackGas returns (uint256 res) {
        uint8 input = 255;

        res = mask__safe__c(input);
    }

    function test__logic__ShiftLib__symbolic__mask(uint8 bits) public {
        uint256 got = ShiftLib.mask(bits);

        uint256 exp_a = mask__safe__a(bits);

        assertEq(got, exp_a, "A");

        uint256 exp_b = mask__safe__b(bits);

        assertEq(got, exp_b, "B");

        uint256 exp_c = mask__safe__c(bits);

        assertEq(got, exp_c, "c");
    }

    function test__logic__ShiftLib__manual__mask() public {
        assertEq(ShiftLib.mask(0), 0x00, "0");
        assertEq(ShiftLib.mask(1), 0x01, "1");
        assertEq(ShiftLib.mask(2), 0x03, "2");
        assertEq(ShiftLib.mask(3), 0x07, "3");

        assertEq(ShiftLib.mask(252), 0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "255");
        assertEq(ShiftLib.mask(253), 0x1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "255");
        assertEq(ShiftLib.mask(254), 0x3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "255");
        assertEq(ShiftLib.mask(255), 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "255");
        assertEq(ShiftLib.mask(), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "256");
    }

    function imask__safe__a(uint8 bits, uint8 offset) public pure returns (uint256) {
        return ~(((1 << bits) - 1) << offset);
    }

    function imask__safe__b(uint8 bits, uint8 offset) public pure returns (uint256) {
        return ~((2**bits - 1) << offset);
    }

    function imask__safe__c(uint8 bits, uint8 offset) public pure returns (uint256) {
        return ~(ShiftLib.mask(bits) << offset);
    }

    function test__logic__ShiftLib__gas__imask() public view trackGas returns (uint256 res) {
        (uint8 bits, uint8 offset) = (60, 128);

        res = ShiftLib.imask(bits, offset);
    }

    function test__logic__ShiftLib__gas__imask__inline() public view trackGas returns (uint256 res) {
        (uint8 bits, uint8 offset) = (60, 128);

        assembly {
            res := not(shl(offset, sub(shl(bits, 1), 1)))
        }
    }

    function test__logic__ShiftLib__gas__imask__safe__a() public view trackGas returns (uint256 res) {
        (uint8 bits, uint8 offset) = (60, 128);

        res = imask__safe__a(bits, offset);
    }

    function test__logic__ShiftLib__gas__imask__safe__b() public view trackGas returns (uint256 res) {
        (uint8 bits, uint8 offset) = (60, 128);

        res = imask__safe__b(bits, offset);
    }

    function test__logic__ShiftLib__gas__imask__safe__c() public view trackGas returns (uint256 res) {
        (uint8 bits, uint8 offset) = (60, 128);

        res = imask__safe__c(bits, offset);
    }

    function test__logic__ShiftLib__symbolic__imask(uint8 bits, uint8 offset) public {
        uint256 got = ShiftLib.imask(bits, offset);

        uint256 exp_a = imask__safe__a(bits, offset);

        assertEq(got, exp_a, "A");

        uint256 exp_b = imask__safe__b(bits, offset);

        assertEq(got, exp_b, "B");

        uint256 exp_c = imask__safe__c(bits, offset);

        assertEq(got, exp_c, "C");
    }

    function test__logic__ShiftLib__manual__imask() public {
        assertEq(ShiftLib.imask(0, 0), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "(0,0)");
        assertEq(ShiftLib.imask(16, 8), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ff, "(16,8)");
        assertEq(ShiftLib.imask(255, 252), 0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "(255, 252)");
        assertEq(ShiftLib.imask(255, 255), 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "(255, 255)");
    }

    function get__safe__a(
        uint256 _store,
        uint8 bits,
        uint8 pos
    ) public pure returns (uint256 res) {
        res = (1 << bits) - 1;
        res = (_store >> pos) & res;
    }

    function test__logic__ShiftLib__gas__get__a() public view trackGas returns (uint256 res) {
        (uint256 _store, uint8 bits, uint8 pos) = (60, 128, 3);

        res = get__safe__a(_store, bits, pos);
    }

    function test__logic__ShiftLib__gas__get() public view trackGas returns (uint256 res) {
        (uint256 _store, uint8 bits, uint8 pos) = (60, 128, 3);

        res = ShiftLib.get(_store, bits, pos);
    }

    function test__logic__ShiftLib__symbolic__get(
        uint256 _store,
        uint8 bits,
        uint8 pos
    ) public {
        uint256 a = get__safe__a(_store, bits, pos);

        uint256 real = ShiftLib.get(_store, bits, pos);

        assertEq(a, real, "A");
    }

    function set__safe__a(
        uint256 _store,
        uint8 bits,
        uint8 pos,
        uint256 value
    ) public pure returns (uint256 res) {
        res = ~(((1 << bits) - 1) << pos);
        value = value << pos;
        res = (_store & res) | value;
    }

    function test__logic__ShiftLib__gas__set__a() public view trackGas returns (uint256 res) {
        (uint256 _store, uint8 bits, uint8 pos, uint256 value) = (60, 128, 3, 4);

        res = set__safe__a(_store, bits, pos, value);
    }

    function test__logic__ShiftLib__gas__set() public view trackGas returns (uint256 res) {
        (uint256 _store, uint8 bits, uint8 pos, uint256 value) = (60, 128, 3, 4);

        res = ShiftLib.set(_store, bits, pos, value);
    }

    function test__logic__ShiftLib__symbolic__set(
        uint256 _store,
        uint8 bits,
        uint8 pos,
        uint256 value
    ) public {
        uint256 a = set__safe__a(_store, bits, pos, value);

        uint256 real = ShiftLib.set(_store, bits, pos, value);

        assertEq(a, real, "B");
    }
}
