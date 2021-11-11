import { Promise as BlueBirdPromise } from 'bluebird';
import { BigNumber } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';

import { StakeMathTest__factory } from '../types/factories/StakeMathTest__factory';
import { StakeMathTest, StakeMathTest__factory, StakeMathTest } from '../types';
import { MockStakeMathTests } from '../archive/stakablev2/MockStakeMath';
import { NamedAccounts } from '../hardhat.config';

import { randomBN } from './shared/general';
import { deployContract, prepareAccounts } from './shared';
import { ETH_ONE, ETH_ZERO, BINARY_196 } from './shared/conversion';
import { MockStakeMathTests } from './mocks/MockStakeMath_float';

let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let main: StakeMathTest;

const refresh = async () => {
    accounts = await prepareAccounts();

    main = await deployContract<StakeMathTest__factory>({
        factory: 'StakeMath_Test',
        from: accounts.deployer,
        args: [],
    });
};

describe('fuzzers', async function () {
    before(async () => {
        await refresh();
    });

    it('fuzzer normal', async function (this) {
        this.timeout(10000000000);

        const args: { [index: string]: BigNumber }[] = await BlueBirdPromise.map(Array(1000), () => {
            return {
                a: randomBN(BINARY_196),
                b: randomBN(BINARY_196),
                c: randomBN(BINARY_196),
                d: randomBN(BINARY_196),
                e: randomBN(BINARY_196),
                f: randomBN(BINARY_196),
                g: randomBN(BINARY_196),
            };
        });

        const tester = new MockStakeMathTests();

        await BlueBirdPromise.map(
            args,
            async (arg: { [index: string]: BigNumber }, index) => {
                context('fuzzer ' + index, async function (this) {
                    this.bail(true);

                    const state = {
                        tSupply: arg.a.add(ETH_ONE),
                        rSupply: arg.b,
                    };

                    const position = {
                        rOwned: arg.c.mul(arg.f.mod(50)).div(100),
                    };

                    // console.log(state);
                    // console.log(position);
                    const amountBuy: BigNumber = arg.e;

                    const amountSell: BigNumber = position.rOwned.add(amountBuy).mul(arg.g.mod(50)).div(100);

                    it('fuzzer getEarnings', async function () {
                        await tester.getEarnings(main, state, position);
                    });

                    // it('fuzzer applyCompound', async function () {
                    //     await tester.applyCompound(main, state, position);
                    //     console.log('errors: ', tester.errorChecks);
                    // });
                    // DANNY it is called here
                    it('fuzzer applyShareIncrease', async function () {
                        await tester.applyShareIncrease(main, state, position, amountBuy);
                    });

                    // it('fuzzer applyShareDecrease', async function () {
                    //     console.log('1', state.rSupply);

                    //     await tester.applyShareIncrease(main, state, position, amountBuy);
                    //     console.log('2', state.rSupply);
                    //     await tester.applyShareDecrease(main, state, position, amountSell);
                    // });

                    it('fuzzer applyRewardIncrease', async function () {
                        await tester.applyRewardIncrease(main, state, amountBuy);
                    });

                    // it('fuzzer applyPaperhand', async function () {
                    //     await tester.applyPaperhand(main, state, position, amountSell);
                    //     console.log('errors: ', tester.errorChecks);
                    // });
                });
            },
            { concurrency: 1 },
        );
        console.log('errors: ', tester.errorChecks);
    });

    it.skip('fuzzer add', async function (this) {
        this.timeout(10000000000);

        const args: { [index: string]: BigNumber }[] = await BlueBirdPromise.map(Array(10000), () => {
            return {
                a: randomBN(BigNumber.from(2).pow(27).mul(ETH_ONE)),
                b: randomBN(BigNumber.from(2).pow(27).mul(ETH_ONE)),
                c: randomBN(BigNumber.from(2).pow(27).mul(ETH_ONE)),
                d: randomBN(BigNumber.from(2).pow(27).mul(ETH_ONE)),
                e: randomBN(BigNumber.from(2).pow(27).mul(ETH_ONE)),
                f: randomBN(BigNumber.from(2).pow(27).mul(ETH_ONE)),
            };
        });

        const tester = new MockStakeMathTests();

        let position = {
            rOwned: ETH_ZERO,
        };

        const state = {
            tSupply: ETH_ZERO,
            rSupply: ETH_ZERO,
        };

        await BlueBirdPromise.map(
            args,
            async (arg: { [index: string]: BigNumber }, index) => {
                context('fuzzer ' + index, async function (this) {
                    this.bail(true);

                    it('fuzzer applyShareIncrease', async function () {
                        if (!position.rOwned.eq(ETH_ZERO)) await tester.applyShareIncrease(main, state, position, ETH_ONE);
                    });

                    position = {
                        rOwned: BigNumber.from(1),
                    };

                    const rewardIncrease = arg.c;

                    it('fuzzer applyRewardIncrease', async function () {
                        await tester.applyRewardIncrease(main, state, rewardIncrease);
                    });

                    it('fuzzer getEarnings', async function () {
                        await tester.getEarnings(main, state, position);
                        console.log('errors: ', state.rSupply.toString());
                    });
                });
            },
            { concurrency: 1 },
        );
    });
});
