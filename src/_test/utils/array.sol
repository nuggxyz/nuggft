// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

library arrayHelpers {
    function add(uint256[] memory input) internal pure returns (uint256 res) {
        for (uint256 i = 0; i < input.length; i++) {
            res += input[i];
        }
    }

    function singleton(uint256 a) internal pure returns (uint256[] memory res) {
        res = new uint256[](1);
        res[0] = a;
    }

    function repeat(uint256 a, uint16 amount) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](amount);

        for (uint256 i = 0; i < amount; i++) {
            arr[i] = a;
        }
    }

    function build(uint256 a) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](1);
        arr[0] = a;
    }

    function build(uint256 a, uint256 b) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](2);

        arr[0] = a;
        arr[1] = b;
    }

    function build(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](3);

        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
    }

    function build(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d
    ) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](4);

        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
    }

    function build(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e
    ) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](5);

        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
    }

    function build(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e,
        uint256 f
    ) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](6);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        arr[5] = f;
    }

    function build(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e,
        uint256 f,
        uint256 g
    ) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](7);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        arr[5] = f;
        arr[6] = g;
    }

    function build(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e,
        uint256 f,
        uint256 g,
        uint256 h
    ) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](8);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        arr[5] = f;
        arr[6] = g;
        arr[7] = h;
    }
}

library array {
    function toAddress(uint256[] memory a) internal pure returns (address[] memory res) {
        assembly {
            res := a
        }
    }

    function to256(uint256[] memory a) internal pure returns (uint256[] memory res) {
        res = a;
    }

    function to160(uint256[] memory a) internal pure returns (uint160[] memory res) {
        assembly {
            res := a
        }
    }

    function to40(uint256[] memory a) internal pure returns (uint40[] memory res) {
        assembly {
            res := a
        }
    }

    function to24(uint256[] memory a) internal pure returns (uint24[] memory res) {
        assembly {
            res := a
        }
    }

    function to16(uint256[] memory a) internal pure returns (uint16[] memory res) {
        assembly {
            res := a
        }
    }

    function to8(uint256[] memory a) internal pure returns (uint8[] memory res) {
        assembly {
            res := a
        }
    }

    ///////////////////////////////////////////////////////////////

    function fromAddress(address[] memory a) internal pure returns (uint256[] memory res) {
        assembly {
            res := a
        }
    }

    function from256(uint256[] memory a) internal pure returns (uint256[] memory res) {
        assembly {
            res := a
        }
    }

    function from160(uint160[] memory a) internal pure returns (uint256[] memory res) {
        assembly {
            res := a
        }
    }

    function from40(uint40[] memory a) internal pure returns (uint256[] memory res) {
        assembly {
            res := a
        }
    }

    function from24(uint24[] memory a) internal pure returns (uint256[] memory res) {
        assembly {
            res := a
        }
    }

    function from16(uint16[] memory a) internal pure returns (uint256[] memory res) {
        assembly {
            res := a
        }
    }

    function from8(uint8[] memory a) internal pure returns (uint256[] memory res) {
        assembly {
            res := a
        }
    }

    ///////////////////////////////////////////////////////////////

    function r256(uint256 a, uint16 amount) internal pure returns (uint256[] memory arr) {
        return arrayHelpers.repeat(a, amount);
    }

    function rAddress(address a, uint16 amount) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.repeat(uint160(a), amount));
    }

    function r160(uint160 a, uint16 amount) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.repeat(a, amount));
    }

    function r40(uint40 a, uint16 amount) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.repeat(a, amount));
    }

    function r24(uint24 a, uint16 amount) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.repeat(a, amount));
    }

    function r16(uint16 a, uint16 amount) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.repeat(a, amount));
    }

    function r8(uint8 a, uint16 amount) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.repeat(a, amount));
    }

    ///////////////////////////////////////////////////////////////

    function s256(uint256 a) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.singleton(a));
    }

    function sAddress(address a) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.singleton(uint160(a)));
    }

    function s160(uint160 a) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.singleton(a));
    }

    function s40(uint40 a) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.singleton(a));
    }

    function s24(uint24 a) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.singleton(a));
    }

    function s16(uint16 a) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.singleton(a));
    }

    function s8(uint8 a) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.singleton(a));
    }

    ///////////////////////////////////////////////////////////////

    function a256(uint256[] memory a) internal pure returns (uint256) {
        return arrayHelpers.add(a);
    }

    function aAddress(address[] memory a) internal pure returns (address) {
        return address(uint160(arrayHelpers.add(fromAddress(a))));
    }

    function a160(uint160[] memory a) internal pure returns (uint160) {
        return uint160(arrayHelpers.add(from160(a)));
    }

    function a40(uint40[] memory a) internal pure returns (uint40) {
        return uint40(arrayHelpers.add(from40(a)));
    }

    function a24(uint24[] memory a) internal pure returns (uint24) {
        return uint24(arrayHelpers.add(from24(a)));
    }

    function a16(uint16[] memory a) internal pure returns (uint16) {
        return uint16(arrayHelpers.add(from16(a)));
    }

    function a8(uint8[] memory a) internal pure returns (uint8) {
        return uint8(arrayHelpers.add(from8(a)));
    }

    ///////////////////////////////////////////////////////////////

    function b256(uint256 a) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.build(a));
    }

    function b256(uint256 a, uint256 b) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.build(a, b));
    }

    function b256(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.build(a, b, c));
    }

    function b256(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d
    ) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.build(a, b, c, d));
    }

    function b256(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e
    ) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.build(a, b, c, d, e));
    }

    function b256(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e,
        uint256 f
    ) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.build(a, b, c, d, e, f));
    }

    function b256(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e,
        uint256 f,
        uint256 g
    ) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.build(a, b, c, d, e, f, g));
    }

    function b256(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e,
        uint256 f,
        uint256 g,
        uint256 h
    ) internal pure returns (uint256[] memory arr) {
        return to256(arrayHelpers.build(a, b, c, d, e, f, g, h));
    }

    ///////////////////////////////////////////////////////////////

    function b160(uint256 a) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.build(a));
    }

    function b160(uint160 a, uint160 b) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.build(a, b));
    }

    function b160(
        uint160 a,
        uint160 b,
        uint160 c
    ) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.build(a, b, c));
    }

    function b160(
        uint160 a,
        uint160 b,
        uint160 c,
        uint160 d
    ) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.build(a, b, c, d));
    }

    function b160(
        uint160 a,
        uint160 b,
        uint160 c,
        uint160 d,
        uint160 e
    ) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.build(a, b, c, d, e));
    }

    function b160(
        uint160 a,
        uint160 b,
        uint160 c,
        uint160 d,
        uint160 e,
        uint160 f
    ) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.build(a, b, c, d, e, f));
    }

    function b160(
        uint160 a,
        uint160 b,
        uint160 c,
        uint160 d,
        uint160 e,
        uint160 f,
        uint160 g
    ) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.build(a, b, c, d, e, f, g));
    }

    function b160(
        uint160 a,
        uint160 b,
        uint160 c,
        uint160 d,
        uint160 e,
        uint160 f,
        uint160 g,
        uint160 h
    ) internal pure returns (uint160[] memory arr) {
        return to160(arrayHelpers.build(a, b, c, d, e, f, g, h));
    }

    ///////////////////////////////////////////////////////////////

    function b40(uint256 a) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.build(a));
    }

    function b40(uint40 a, uint40 b) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.build(a, b));
    }

    function b40(
        uint40 a,
        uint40 b,
        uint40 c
    ) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.build(a, b, c));
    }

    function b40(
        uint40 a,
        uint40 b,
        uint40 c,
        uint40 d
    ) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.build(a, b, c, d));
    }

    function b40(
        uint40 a,
        uint40 b,
        uint40 c,
        uint40 d,
        uint40 e
    ) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.build(a, b, c, d, e));
    }

    function b40(
        uint40 a,
        uint40 b,
        uint40 c,
        uint40 d,
        uint40 e,
        uint40 f
    ) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.build(a, b, c, d, e, f));
    }

    function b40(
        uint40 a,
        uint40 b,
        uint40 c,
        uint40 d,
        uint40 e,
        uint40 f,
        uint40 g
    ) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.build(a, b, c, d, e, f, g));
    }

    function b40(
        uint40 a,
        uint40 b,
        uint40 c,
        uint40 d,
        uint40 e,
        uint40 f,
        uint40 g,
        uint40 h
    ) internal pure returns (uint40[] memory arr) {
        return to40(arrayHelpers.build(a, b, c, d, e, f, g, h));
    }

    ///////////////////////////////////////////////////////////////

    function b24(uint256 a) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.build(a));
    }

    function b24(uint24 a, uint24 b) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.build(a, b));
    }

    function b24(
        uint24 a,
        uint24 b,
        uint24 c
    ) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.build(a, b, c));
    }

    function b24(
        uint24 a,
        uint24 b,
        uint24 c,
        uint24 d
    ) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.build(a, b, c, d));
    }

    function b24(
        uint24 a,
        uint24 b,
        uint24 c,
        uint24 d,
        uint24 e
    ) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.build(a, b, c, d, e));
    }

    function b24(
        uint24 a,
        uint24 b,
        uint24 c,
        uint24 d,
        uint24 e,
        uint24 f
    ) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.build(a, b, c, d, e, f));
    }

    function b24(
        uint24 a,
        uint24 b,
        uint24 c,
        uint24 d,
        uint24 e,
        uint24 f,
        uint24 g
    ) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.build(a, b, c, d, e, f, g));
    }

    function b24(
        uint24 a,
        uint24 b,
        uint24 c,
        uint24 d,
        uint24 e,
        uint24 f,
        uint24 g,
        uint24 h
    ) internal pure returns (uint24[] memory arr) {
        return to24(arrayHelpers.build(a, b, c, d, e, f, g, h));
    }

    ///////////////////////////////////////////////////////////////

    function b16(uint256 a) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.build(a));
    }

    function b16(uint16 a, uint16 b) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.build(a, b));
    }

    function b16(
        uint16 a,
        uint16 b,
        uint16 c
    ) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.build(a, b, c));
    }

    function b16(
        uint16 a,
        uint16 b,
        uint16 c,
        uint16 d
    ) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.build(a, b, c, d));
    }

    function b16(
        uint16 a,
        uint16 b,
        uint16 c,
        uint16 d,
        uint16 e
    ) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.build(a, b, c, d, e));
    }

    function b16(
        uint16 a,
        uint16 b,
        uint16 c,
        uint16 d,
        uint16 e,
        uint16 f
    ) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.build(a, b, c, d, e, f));
    }

    function b16(
        uint16 a,
        uint16 b,
        uint16 c,
        uint16 d,
        uint16 e,
        uint16 f,
        uint16 g
    ) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.build(a, b, c, d, e, f, g));
    }

    function b16(
        uint16 a,
        uint16 b,
        uint16 c,
        uint16 d,
        uint16 e,
        uint16 f,
        uint16 g,
        uint16 h
    ) internal pure returns (uint16[] memory arr) {
        return to16(arrayHelpers.build(a, b, c, d, e, f, g, h));
    }

    ///////////////////////////////////////////////////////////////

    function b8(uint256 a) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.build(a));
    }

    function b8(uint8 a, uint8 b) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.build(a, b));
    }

    function b8(
        uint8 a,
        uint8 b,
        uint8 c
    ) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.build(a, b, c));
    }

    function b8(
        uint8 a,
        uint8 b,
        uint8 c,
        uint8 d
    ) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.build(a, b, c, d));
    }

    function b8(
        uint8 a,
        uint8 b,
        uint8 c,
        uint8 d,
        uint8 e
    ) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.build(a, b, c, d, e));
    }

    function b8(
        uint8 a,
        uint8 b,
        uint8 c,
        uint8 d,
        uint8 e,
        uint8 f
    ) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.build(a, b, c, d, e, f));
    }

    function b8(
        uint8 a,
        uint8 b,
        uint8 c,
        uint8 d,
        uint8 e,
        uint8 f,
        uint8 g
    ) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.build(a, b, c, d, e, f, g));
    }

    function b8(
        uint8 a,
        uint8 b,
        uint8 c,
        uint8 d,
        uint8 e,
        uint8 f,
        uint8 g,
        uint8 h
    ) internal pure returns (uint8[] memory arr) {
        return to8(arrayHelpers.build(a, b, c, d, e, f, g, h));
    }

    ///////////////////////////////////////////////////////////////

    function bAddress(address a) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.build(uint160(a)));
    }

    function bAddress(address a, address b) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.build(uint160(a), uint160(b)));
    }

    function bAddress(
        address a,
        address b,
        address c
    ) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.build(uint160(a), uint160(b), uint160(c)));
    }

    function bAddress(
        address a,
        address b,
        address c,
        address d
    ) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.build(uint160(a), uint160(b), uint160(c), uint160(d)));
    }

    function bAddress(
        address a,
        address b,
        address c,
        address d,
        address e
    ) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.build(uint160(a), uint160(b), uint160(c), uint160(d), uint160(e)));
    }

    function bAddress(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f
    ) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.build(uint160(a), uint160(b), uint160(c), uint160(d), uint160(e), uint160(f)));
    }

    function bAddress(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f,
        address g
    ) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.build(uint160(a), uint160(b), uint160(c), uint160(d), uint160(e), uint160(f), uint160(g)));
    }

    function bAddress(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f,
        address g,
        address h
    ) internal pure returns (address[] memory arr) {
        return toAddress(arrayHelpers.build(uint160(a), uint160(b), uint160(c), uint160(d), uint160(e), uint160(f), uint160(g), uint160(h)));
    }
}
