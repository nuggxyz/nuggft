import { BigNumber } from 'ethers';

import { BINARY_128 } from '../shared/conversion';

export class MockQuadMath {
    public static mulDiv = (x: BigNumber, y: BigNumber, d: BigNumber): BigNumber => {
        return x.mul(y).div(d);
    };

    public static mulDivRoundingUp = (x: BigNumber, y: BigNumber, d: BigNumber): BigNumber => {
        return x
            .mul(y)
            .div(d)
            .add(x.mul(y).mod(d).gt(0) ? 1 : 0);
    };

    public static mulDivRealRound = (x: BigNumber, y: BigNumber, d: BigNumber): BigNumber => {
        const ytmp = y.mul(BINARY_128);
        const dtmp = d.mul(BINARY_128.div(100000));
        console.log(ytmp.toString());
        return x
            .mul(y)
            .div(d)
            .add(x.mul(ytmp).mod(dtmp).gte(500000) ? 1 : 0);
    };
}

export class MockQuadMathTests {
    public static mulDiv = (x: BigNumber, y: BigNumber, d: BigNumber): BigNumber => {
        return x.mul(y).div(d);
    };

    public static mulDivRoundingUp = (x: BigNumber, y: BigNumber, d: BigNumber): BigNumber => {
        return x
            .mul(y)
            .div(d)
            .add(x.mul(y).mod(d).gt(0) ? 1 : 0);
    };
}

export const js_mulDiv = (x: BigNumber, y: BigNumber, d: BigNumber): BigNumber => {
    return x.mul(y).div(d);
};

export const js_mulDivRoundingUp = (x: BigNumber, y: BigNumber, d: BigNumber): BigNumber => {
    return x
        .mul(y)
        .div(d)
        .add(x.mul(y).mod(d).gt(0) ? 1 : 0);
};
