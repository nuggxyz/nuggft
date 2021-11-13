import { Decimal } from 'decimal.js';
import { ethers } from 'hardhat';
import { BigNumber } from 'ethers';

import { ETH_HUNDRED } from './conversion';

const {
    constants: { MaxUint256 },
} = ethers;

Decimal.config({ toExpNeg: -500, toExpPos: 500 });

export const wait = (timeout: number) => {
    return new Promise((resolve) => {
        setTimeout(resolve, timeout);
    });
};

export const pseudoRandomBigNumber = () => {
    return BigNumber.from(new Decimal(MaxUint256.toString()).mul(Math.random().toString()).round().toString());
};

// function xmur3(str) {
//     for (var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) (h = Math.imul(h ^ str.charCodeAt(i), 3432918353)), (h = (h << 13) | (h >>> 19));
//     return function () {
//         h = Math.imul(h ^ (h >>> 16), 2246822507);
//         h = Math.imul(h ^ (h >>> 13), 3266489909);
//         return (h ^= h >>> 16) >>> 0;
//     };
// }

function sfc32(a: any, b: any, c: any, d: any) {
    return function () {
        a >>>= 0;
        b >>>= 0;
        c >>>= 0;
        d >>>= 0;
        let t = (a + b) | 0;
        a = b ^ (b >>> 9);
        b = (c + (c << 3)) | 0;
        c = (c << 21) | (c >>> 11);
        d = (d + 1) | 0;
        t = (t + d) | 0;
        c = (c + t) | 0;
        return (t >>> 0) / 4294967296;
    };
}

export const pseudoRandomBigNumber2 = () => {
    const seed = 1337 ^ 0xdeadbeef; // 32-bit seed with optional XOR value
    // Pad seed with Phi, Pi and E.
    // https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number
    const rand = sfc32(0x9e3779b9, 0x243f6a88, 0xb7e15162, seed);

    return BigNumber.from(new Decimal(ETH_HUNDRED.toString()).mul(rand().toString()).toString());
};

export function randomBN(max: BigNumber) {
    return ethers.BigNumber.from(ethers.utils.randomBytes(32)).mod(max);
}

export const validateContractFromMock = (con: any, mock: any) => {
    let equal = true;

    if (Array.isArray(con) && Array.isArray(mock)) {
        if (con.length !== mock.length) {
            return false;
        }
        mock.forEach((item, index) => {
            if (equal) {
                equal = validateContractFromMock(con[index], item);
            }
        });
    } else if (Array.isArray(con) && typeof mock === 'object') {
        Object.values(mock).forEach((value, index) => {
            if (equal) {
                equal = validateContractFromMock(con[index], value);
            }
        });
    } else if (typeof con === 'object' && typeof mock === 'object') {
        Object.keys(mock).forEach((key) => {
            if (equal) {
                equal = mock[key] === con[key];
            }
        });
    }

    return equal;
};
export const v2 = (con: any) => {
    return con.map((x: any) => (!BigNumber.isBigNumber(x) ? Object.values(x).flat(1) : x));
};
