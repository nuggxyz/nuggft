import { ethers } from 'hardhat';
import { expect } from './shared/expect';
import { Decimal } from 'decimal.js';
import { QuadMathTest } from '../types/QuadMathTest';
import { BINARY_128 } from './shared/conversion';

const {
    BigNumber,
    constants: { MaxUint256 },
} = ethers;

Decimal.config({ toExpNeg: -500, toExpPos: 500 });

describe('QuadMath', function () {
    let quadMath: QuadMathTest;
    before('deploy QuadMathTest', async function () {
        const factory = await ethers.getContractFactory('QuadMath_Test');
        quadMath = (await factory.deploy()) as QuadMathTest;
    });

    describe('#mulDiv', function () {
        it('reverts if denominator is 0', async function () {
            await expect(quadMath.mulDiv(BINARY_128, 5, 0)).to.be.reverted;
        });
        it('reverts if denominator is 0 and numerator overflows', async function () {
            await expect(quadMath.mulDiv(BINARY_128, BINARY_128, 0)).to.be.reverted;
        });
        it('reverts if output overflows uint256', async function () {
            await expect(quadMath.mulDiv(BINARY_128, BINARY_128, 1)).to.be.reverted;
        });
        it('reverts if output overflows uint256', async function () {
            await expect(quadMath.mulDiv(BINARY_128, BINARY_128, 1)).to.be.reverted;
        });
        it('reverts on overflow with all max inputs', async function () {
            await expect(quadMath.mulDiv(MaxUint256, MaxUint256, MaxUint256.sub(1))).to.be.reverted;
        });

        it('all max inputs', async function () {
            // this.timeout(30000);
            // console.log('res1');

            // const res = await quadMath.mulDivRoundingUp(MaxUint256, MaxUint256, MaxUint256);
            // console.log('res', res);
            // if (res) {
            expect(await quadMath.mulDiv(MaxUint256, MaxUint256, MaxUint256)).to.eq(MaxUint256);
            // }
        });

        it('accurate without phantom overflow', async function () {
            const result = BINARY_128.div(3);
            expect(
                await quadMath.mulDiv(BINARY_128, /*0.5=*/ BigNumber.from(50).mul(BINARY_128).div(100), /*1.5=*/ BigNumber.from(150).mul(BINARY_128).div(100)),
            ).to.eq(result);
        });

        it('accurate with phantom overflow', async function () {
            const result = BigNumber.from(4375).mul(BINARY_128).div(1000);
            expect(await quadMath.mulDiv(BINARY_128, BigNumber.from(35).mul(BINARY_128), BigNumber.from(8).mul(BINARY_128))).to.eq(result);
        });

        it('accurate with phantom overflow and repeating decimal', async function () {
            const result = BigNumber.from(1).mul(BINARY_128).div(3);
            expect(await quadMath.mulDiv(BINARY_128, BigNumber.from(1000).mul(BINARY_128), BigNumber.from(3000).mul(BINARY_128))).to.eq(result);
        });
    });

    describe('#mulDivRoundingUp', function () {
        it('reverts if denominator is 0', async function () {
            await expect(quadMath.mulDivRoundingUp(BINARY_128, 5, 0)).to.be.reverted;
        });
        it('reverts if denominator is 0 and numerator overflows', async function () {
            await expect(quadMath.mulDivRoundingUp(BINARY_128, BINARY_128, 0)).to.be.reverted;
        });
        it('reverts if output overflows uint256', async function () {
            await expect(quadMath.mulDivRoundingUp(BINARY_128, BINARY_128, 1)).to.be.reverted;
        });
        it('reverts on overflow with all max inputs', async function () {
            await expect(quadMath.mulDivRoundingUp(MaxUint256, MaxUint256, MaxUint256.sub(1))).to.be.reverted;
        });

        it('reverts if mulDiv overflows 256 bits after rounding up', async function () {
            await expect(quadMath.mulDivRoundingUp('535006138814359', '432862656469423142931042426214547535783388063929571229938474969', '2')).to.be.reverted;
        });

        it('reverts if mulDiv overflows 256 bits after rounding up case 2', async function () {
            await expect(
                quadMath.mulDivRoundingUp(
                    '115792089237316195423570985008687907853269984659341747863450311749907997002549',
                    '115792089237316195423570985008687907853269984659341747863450311749907997002550',
                    '115792089237316195423570985008687907853269984653042931687443039491902864365164',
                ),
            ).to.be.reverted;
        });

        it('all max inputs', async function () {
            expect(await quadMath.mulDivRoundingUp(MaxUint256, MaxUint256, MaxUint256)).to.eq(MaxUint256);
        });

        it('accurate without phantom overflow', async function () {
            const result = BINARY_128.div(3).add(1);
            expect(
                await quadMath.mulDivRoundingUp(
                    BINARY_128,
                    /*0.5=*/ BigNumber.from(50).mul(BINARY_128).div(100),
                    /*1.5=*/ BigNumber.from(150).mul(BINARY_128).div(100),
                ),
            ).to.eq(result);
        });

        it('accurate with phantom overflow', async function () {
            const result = BigNumber.from(4375).mul(BINARY_128).div(1000);
            expect(await quadMath.mulDivRoundingUp(BINARY_128, BigNumber.from(35).mul(BINARY_128), BigNumber.from(8).mul(BINARY_128))).to.eq(result);
        });

        it('accurate with phantom overflow and repeating decimal', async function () {
            const result = BigNumber.from(1).mul(BINARY_128).div(3).add(1);
            expect(await quadMath.mulDivRoundingUp(BINARY_128, BigNumber.from(1000).mul(BINARY_128), BigNumber.from(3000).mul(BINARY_128))).to.eq(result);
        });
    });

    function pseudoRandomBigNumber() {
        return BigNumber.from(new Decimal(MaxUint256.toString()).mul(Math.random().toString()).round().toString());
    }

    // tiny fuzzer. unskip to run
    it('check a bunch of random inputs against JS implementation', async function () {
        // generates random inputs
        const tests = Array(1_000)
            .fill(null)
            .map(function () {
                return {
                    x: pseudoRandomBigNumber(),
                    y: pseudoRandomBigNumber(),
                    d: pseudoRandomBigNumber(),
                };
            })
            .map(({ x, y, d }) => {
                return {
                    input: {
                        x,
                        y,
                        d,
                    },
                    floored: quadMath.mulDiv(x, y, d),
                    ceiled: quadMath.mulDivRoundingUp(x, y, d),
                };
            });

        await Promise.all(
            tests.map(async ({ input: { x, y, d }, floored, ceiled }) => {
                if (d.eq(0)) {
                    await expect(floored).to.be.reverted;
                    await expect(ceiled).to.be.reverted;
                    return;
                }

                if (x.eq(0) || y.eq(0)) {
                    await expect(floored).to.eq(0);
                    await expect(ceiled).to.eq(0);
                } else if (x.mul(y).div(d).gt(MaxUint256)) {
                    await expect(floored).to.be.reverted;
                    await expect(ceiled).to.be.reverted;
                } else {
                    expect(await floored).to.eq(x.mul(y).div(d));
                    expect(await ceiled).to.eq(
                        x
                            .mul(y)
                            .div(d)
                            .add(x.mul(y).mod(d).gt(0) ? 1 : 0),
                    );
                }
            }),
        );
    });
});
