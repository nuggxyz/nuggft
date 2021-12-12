import { BigNumber, ethers } from 'ethers';
import { Decimal } from 'decimal.js';

// export const toEth = (num: string): string => {
//     return toEthBN(num).toString();
// };

export const toEth = (num: string): ethers.BigNumber => {
    return ethers.utils.parseEther(num);
};

export const fromEth = (num: ethers.BigNumberish): string => {
    return ethers.utils.formatUnits(num);
};

// export const ETH_ONE = toEth('1');
// export const ETH_TEN = toEth('10');
// export const ETH_HUNDRED = toEth('100');
// export const ETH_THOUSAND = toEth('1000');
// export const ETH_TEN_THOUSAND = toEth('10000');
// export const ETH_HUNDRED_THOUSAND = toEth('100000');
// export const ETH_MILLION = toEth('1000000');
// export const ETH_BILLION = toEth('1000000000');
// export const ETH_TRILLION = toEth('1000000000000');
export const ETH_ZERO = toEth('0');

export const ETH_ONE = toEth('1');
export const ETH_TEN = toEth('10');
export const ETH_HUNDRED = toEth('100');
export const ETH_THOUSAND = toEth('1000');
export const ETH_TEN_THOUSAND = toEth('10000');
export const ETH_HUNDRED_THOUSAND = toEth('100000');
export const ETH_MILLION = toEth('1000000');
export const ETH_BILLION = toEth('1000000000');
export const ETH_TRILLION = toEth('1000000000000');

export const DEADLINE = '10000000000000';

export const BINARY_128 = BigNumber.from(2).pow(128);
export const BINARY_196 = BigNumber.from(2).pow(196);
export const BINARY_224 = BigNumber.from(2).pow(224);
export const BINARY_110 = BigNumber.from(2).pow(110);

export function formatTokenAmount(num: ethers.BigNumberish): string {
    return new Decimal(num.toString()).dividedBy(new Decimal(10).pow(18)).toPrecision(5);
}

export function randomBN() {
    return BigNumber.from(ethers.utils.randomBytes(48)).shr(16);
}

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

export const randomBN2 = () => {
    const seed = 1337 ^ 0xdeadbeef; // 32-bit seed with optional XOR value
    // Pad seed with Phi, Pi and E.
    // https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number
    const rand = sfc32(0x9e3779b9, 0x243f6a88, 0xb7e15162, seed);
    return BigNumber.from(ethers.utils.keccak256(BigNumber.from(Math.floor(+rand().toPrecision(10) * Math.pow(10, 10)))._hex));
    // return ethers.constants.MaxInt256.mul(rand().toPrecision(20).).toString();
};
