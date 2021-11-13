import { Promise as BlueBirdPromise } from 'bluebird';
import { BigNumber } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';

import { StakeMathTest } from '../typechain';
import { MockStakeMathTests } from '../archive/stakablev2/MockStakeMath';
import { NamedAccounts } from '../hardhat.config';

import { ETH_ONE, BINARY_128, ETH_ZERO } from './shared/conversion';
import { StakeMathTest__factory } from './../typechain/factories/StakeMathTest__factory';
import { randomBN } from './shared/general';
import { deployContract, prepareAccounts } from './shared';

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
                a: randomBN(ETH_ONE),
                b: randomBN(ETH_ONE),
                c: randomBN(ETH_ONE),
                d: randomBN(ETH_ONE),
                e: randomBN(ETH_ONE),
                f: randomBN(ETH_ONE),
            };
        });

        const tester = new MockStakeMathTests();

        await BlueBirdPromise.map(
            args,
            async (arg: { [index: string]: BigNumber }, index) => {
                context('fuzzer ' + index, async function (this) {
                    this.bail(true);

                    const state: any = {
                        shares: arg.a,
                        epsX128: arg.b.mul(BINARY_128),
                    };

                    const position: any = {
                        shares: arg.a.mul(arg.d.mod(100)).div(100),
                        earnings: arg.c.mul(arg.f.mod(50)).div(100),
                    };

                    // console.log(state);
                    // console.log(position);
                    const amountBuy: BigNumber = arg.e;

                    const amountSell: BigNumber = position.shares.mul(arg.e.mod(200)).div(100);

                    it('fuzzer getEarnings', async function () {
                        await tester.getEarnings(main, state, position);
                    });

                    it('fuzzer applyRealize', async function () {
                        await tester.applyRealize(main, state, position);
                    });

                    // it('fuzzer applyCompound', async function () {
                    //     await tester.applyCompound(main, state, position);
                    //     console.log('errors: ', tester.errorChecks);
                    // });

                    // DANNY it is called here
                    it('fuzzer applyShareIncrease', async function () {
                        await tester.applyShareIncrease(main, state, position, amountBuy);
                    });

                    it('fuzzer applyShareDecrease', async function () {
                        await tester.applyShareDecrease(main, state, position, amountSell);
                    });

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

        const state: any = {
            shares: ETH_ZERO,
            epsX128: ETH_ZERO,
        };

        let position = {
            shares: ETH_ZERO,
            earnings: ETH_ZERO,
        };

        await BlueBirdPromise.map(
            args,
            async (arg: { [index: string]: BigNumber }, index) => {
                context('fuzzer ' + index, async function (this) {
                    this.bail(true);

                    it('fuzzer applyShareIncrease', async function () {
                        if (!position.shares.eq(ETH_ZERO)) await tester.applyShareIncrease(main, state, position, ETH_ONE);
                    });

                    position = {
                        shares: BigNumber.from(1),
                        earnings: BigNumber.from(1),
                    };

                    const rewardIncrease = arg.c;

                    it('fuzzer applyRewardIncrease', async function () {
                        await tester.applyRewardIncrease(main, state, rewardIncrease);
                    });

                    it('fuzzer getEarnings', async function () {
                        await tester.getEarnings(main, state, position);
                        console.log('errors: ', state.epsX128.toString());
                    });
                });
            },
            { concurrency: 1 },
        );
    });
});
