import { Promise as BlueBirdPromise } from 'bluebird';
import { BigNumber } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';

import { NamedAccounts } from '../../hardhat.config';
import { EpochMathTest, EpochMathTest__factory } from '../typechain';

import { MockEpochMathState, MockEpochMathTests } from './mocks/MockEpochMath';
import { ETH_BILLION } from './shared/conversion';
import { randomBN } from './shared/general';
import { deployContract, prepareAccounts } from './shared';

const STARTS_WITH = 'data:application/json;base64,';
const STARTS_WITH_2 = 'data:image/svg+xml;base64,';

let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let main: EpochMathTest;

// describe('Static Tests', async function () {
//     before(async function () {
//         accounts = await prepareAccounts();

//         epochMathTest = await deployContract<EpochMathTest__factory>({
//             factory: 'EpochMath_Test',
//             from: accounts.deployer,s
//         });
//     });
// });

const refresh = async () => {
    accounts = await prepareAccounts();

    main = await deployContract<EpochMathTest__factory>({
        factory: 'EpochMath_Test',
        from: accounts.deployer,
        args: [],
    });
};

describe('Mock checks', async function () {
    before(async function () {
        await refresh();
    });

    describe('case 1', async function () {
        it('getCurrentEpoch', async function () {
            const state: MockEpochMathState = {
                interval: BigNumber.from(255),
                genesisBlock: BigNumber.from(4204000),
            };
            const id = BigNumber.from(0);
            const blocknum = BigNumber.from(state.genesisBlock.add(1));

            await MockEpochMathTests.getIdFromBlocknum(main, state, blocknum);
            await MockEpochMathTests.getStartBlockFromId(main, state, id);
            await MockEpochMathTests.getEndBlockFromId(main, state, id);
            await MockEpochMathTests.getStatus(main, state, id, blocknum);
            await MockEpochMathTests.getEpoch(main, state, id, blocknum);
        });
    });
});

describe('fuzzer', async () => {
    before(async () => {
        await refresh();
    });

    it('should not fail - mod 1e4', async function () {
        this.timeout(10000000000);
        const args: { [index: string]: BigNumber }[] = await BlueBirdPromise.map(Array(50), () => {
            return {
                a: randomBN(BigNumber.from(10_000)),
                b: randomBN(BigNumber.from(10_000)),
                c: randomBN(BigNumber.from(10_000)),
            };
        });

        await BlueBirdPromise.map(
            args,
            async (arg: { [index: string]: BigNumber }, index) => {
                // it('getCurrentEpoch', async function () {
                const state: MockEpochMathState = {
                    interval: BigNumber.from(255),
                    genesisBlock: arg.b,
                };

                const id = arg.a;
                const blocknum = state.genesisBlock.add(arg.c.mod(100_000_000));
                await MockEpochMathTests.getIdFromBlocknum(main, state, blocknum);
                await MockEpochMathTests.getStartBlockFromId(main, state, id);
                await MockEpochMathTests.getEndBlockFromId(main, state, id);
                await MockEpochMathTests.getStatus(main, state, id, blocknum);
                await MockEpochMathTests.getEpoch(main, state, id, blocknum);
            },
            { concurrency: 1 },
        );
    });

    it('should not fail - mod 1e9', async function () {
        this.timeout(10000000000);
        const args: { [index: string]: BigNumber }[] = await BlueBirdPromise.map(Array(50), () => {
            return {
                a: randomBN(BigNumber.from(1_000_000_000)),
                b: randomBN(BigNumber.from(1_000_000_000)),
                c: randomBN(BigNumber.from(1_000_000_000)),
            };
        });

        await BlueBirdPromise.map(
            args,
            async (arg: { [index: string]: BigNumber }, index) => {
                // it('getCurrentEpoch', async function () {
                const state: MockEpochMathState = {
                    interval: BigNumber.from(255),
                    genesisBlock: arg.b.mod(100_000_00),
                };

                const id = arg.a.mod(100_000);
                const blocknum = state.genesisBlock.add(arg.c.mod(100_000_000));
                await MockEpochMathTests.getIdFromBlocknum(main, state, blocknum);
                await MockEpochMathTests.getStartBlockFromId(main, state, id);
                await MockEpochMathTests.getEndBlockFromId(main, state, id);
                await MockEpochMathTests.getStatus(main, state, id, blocknum);
                await MockEpochMathTests.getEpoch(main, state, id, blocknum);
            },
            { concurrency: 1 },
        );
    });

    it('should not fail - mod 1e27', async function () {
        this.timeout(10000000000);
        const args: { [index: string]: BigNumber }[] = await BlueBirdPromise.map(Array(50), () => {
            return {
                a: randomBN(BigNumber.from(ETH_BILLION)),
                b: randomBN(BigNumber.from(ETH_BILLION)),
                c: randomBN(BigNumber.from(ETH_BILLION)),
            };
        });

        await BlueBirdPromise.map(
            args,
            async (arg: { [index: string]: BigNumber }, index) => {
                // it('getCurrentEpoch', async function () {
                const state: MockEpochMathState = {
                    interval: BigNumber.from(255),
                    genesisBlock: arg.b,
                };

                const id = arg.a;
                const blocknum = state.genesisBlock.add(arg.c);

                await MockEpochMathTests.getIdFromBlocknum(main, state, blocknum);
                await MockEpochMathTests.getStartBlockFromId(main, state, id);
                await MockEpochMathTests.getEndBlockFromId(main, state, id);
                await MockEpochMathTests.getStatus(main, state, id, blocknum);
                await MockEpochMathTests.getEpoch(main, state, id, blocknum);
            },
            { concurrency: 1 },
        );
    });
});
