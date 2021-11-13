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
