pragma solidity 0.8.9;

import '../../NuggftV1.test.sol';

import {ShiftLib} from '../../../libraries/ShiftLib.sol';

contract logic__ShiftLib__mask is NuggftV1Test {
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

        assertEq(got, exp_a, 'A');

        uint256 exp_b = mask__safe__b(bits);

        assertEq(got, exp_b, 'B');

        uint256 exp_c = mask__safe__c(bits);

        assertEq(got, exp_c, 'c');
    }

    function test__logic__ShiftLib__manual__mask() public {
        assertEq(ShiftLib.mask(0), 0x00, '0');
        assertEq(ShiftLib.mask(1), 0x01, '1');
        assertEq(ShiftLib.mask(2), 0x03, '2');
        assertEq(ShiftLib.mask(3), 0x07, '3');

        assertEq(ShiftLib.mask(252), 0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, '255');
        assertEq(ShiftLib.mask(253), 0x1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, '255');
        assertEq(ShiftLib.mask(254), 0x3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, '255');
        assertEq(ShiftLib.mask(255), 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, '255');
        assertEq(ShiftLib.mask(), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, '256');
    }
}

contract logic__ShiftLib__imask is NuggftV1Test {
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

        assertEq(got, exp_a, 'A');

        uint256 exp_b = imask__safe__b(bits, offset);

        assertEq(got, exp_b, 'B');

        uint256 exp_c = imask__safe__c(bits, offset);

        assertEq(got, exp_c, 'C');
    }

    function test__logic__ShiftLib__manual__imask() public {
        assertEq(ShiftLib.imask(0, 0), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, '(0,0)');
        assertEq(ShiftLib.imask(16, 8), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ff, '(16,8)');
        assertEq(ShiftLib.imask(255, 252), 0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, '(255, 252)');
        assertEq(ShiftLib.imask(255, 255), 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, '(255, 255)');
    }
}
