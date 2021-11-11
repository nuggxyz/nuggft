import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';
import BlueBirdPromise from 'bluebird';
import { BigNumber } from 'ethers';
import Decimal from 'decimal.js';

import { js_earningsSM, js_toEarningsFromEpsX128, js_toEpsX128FromShares } from '../archive/stakablev2/MockStakeMath';
import { NamedAccounts } from '../hardhat.config';

import { prepareAccounts } from './shared';
import { stakeableTestFixture, StakeableTestFixture } from './fixtures/StakeableTest.fix';
import { ETH_ONE, ETH_HUNDRED, ETH_BILLION, ETH_THOUSAND, ETH_TEN } from './shared/conversion';
import { expect } from './shared/expect';
import { randomBN } from './shared/general';
const createFixtureLoader = waffle.createFixtureLoader;
const {
    constants: { MaxUint256 },
} = ethers;

Decimal.config({ toExpNeg: -500, toExpPos: 500 });
let loadFixture: ReturnType<typeof createFixtureLoader>;
let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let fix: StakeableTestFixture;

const refresh = async () => {
    accounts = await prepareAccounts();
    loadFixture = createFixtureLoader();
    fix = await loadFixture(stakeableTestFixture);
};

describe('uint tests', async function () {
    beforeEach(async () => {
        await refresh();
    });

    describe('internal', async () => {
        describe('_rewardIncrease', async () => {
            it('should revert if shares = 0', async () => {
                const amount = ETH_ONE;
                await expect(fix.contract.test__internal__rewardIncrease(amount)).to.be.revertedWith('STAKE:RI:0');
            });

            it('should not revert if shares > 0', async () => {
                const amount = ETH_ONE;
                const shares = ETH_HUNDRED;
                await fix.contract.rig__set__shares(shares);
                await expect(fix.contract.test__internal__rewardIncrease(amount)).to.not.be.reverted;
            });

            it('should increase _epsX128 by expected amount', async () => {
                const amount = ETH_ONE;
                const shares = ETH_HUNDRED;
                const epsX128 = ETH_BILLION;
                await fix.contract.rig__set__shares(shares);
                await fix.contract.rig__set__epsX128(epsX128);
                const expectedIncrease = js_toEpsX128FromShares(amount, shares);
                const before = await fix.contract.epsX128();
                await fix.contract.test__internal__rewardIncrease(amount);
                const after = await fix.contract.epsX128();
                const diff = after.sub(before);
                expect(diff).to.equal(expectedIncrease);
            });

            it('should emit expected RewardIncrease', async () => {
                const amount = ETH_ONE;
                const shares = ETH_HUNDRED;
                const expectedIncrease = js_toEpsX128FromShares(amount, shares);
                await fix.contract.rig__set__shares(shares);
                await expect(fix.contract.test__internal__rewardIncrease(amount))
                    .to.emit(fix.contract, 'RewardIncrease')
                    .withArgs(amount, expectedIncrease);
                await expect(fix.contract.test__internal__rewardIncrease(amount))
                    .to.emit(fix.contract, 'RewardIncrease')
                    .withArgs(amount, expectedIncrease.mul(2));
            });
        });

        describe('_invest / _shareIncrease', async () => {
            it('should revert if amount = 0', async () => {
                await expect(fix.contract.test__internal__invest(accounts.frank.address, 0)).to.be.revertedWith('STAKE:SI:0');
            });

            it('should increase user earnings by expected amount', async () => {
                // fuz
                const amount = ETH_ONE;
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;

                await fix.contract.rig__set__epsX128(epsX128);

                const expectedDebtIncrease = js_toEarningsFromEpsX128(amount, epsX128);
                const before = await fix.contract.positions(account.address);
                await fix.contract.test__internal__invest(account.address, amount);
                const after = await fix.contract.positions(account.address);
                const diff = after.earnings.sub(before.earnings);
                expect(diff).to.equal(expectedDebtIncrease);
            });

            it('should increase user shares by expected amount', async () => {
                // fuz
                const amount = ETH_ONE;
                const account = accounts.frank;
                const before = await fix.contract.positions(account.address);
                await fix.contract.test__internal__invest(account.address, amount);
                const after = await fix.contract.positions(account.address);
                const diff = after.shares.sub(before.shares);
                expect(diff).to.equal(amount);
            });

            it('should increase total shares by expected amount', async () => {
                // fuz
                const amount = ETH_ONE;
                const account = accounts.frank;
                const before = await fix.contract.shares();
                await fix.contract.test__internal__invest(account.address, amount);
                const after = await fix.contract.shares();
                const diff = after.sub(before);
                expect(diff).to.equal(amount);
            });

            it('should emit expected events', async () => {
                const amount = ETH_ONE;
                const account = accounts.frank;

                await expect(fix.contract.test__internal__invest(account.address, amount))
                    .to.emit(fix.contract, 'SharesIncrease')
                    .withArgs(account.address, amount, amount, amount, 0);
            });
        });

        describe('_compound', async () => {
            // fuzz
            it('total value should remain same', async () => {
                const amount = ETH_ONE;
                const account = accounts.frank;

                await fix.contract.test__internal__invest(accounts.frank.address, amount);
                await fix.contract.test__internal__rewardIncrease(amount);
                await fix.contract.test__internal__invest(accounts.mac.address, amount);
                await fix.contract.test__internal__rewardIncrease(amount);
                await fix.contract.test__internal__invest(accounts.dee.address, amount);
                await fix.contract.test__internal__rewardIncrease(amount);
                await fix.contract.test__internal__invest(accounts.dennis.address, amount);
                await fix.contract.test__internal__rewardIncrease(amount);

                const stakerBefore = await fix.contract.positions(account.address);
                const earningsBefore = await fix.contract.earnings(account.address);
                const valueBefore = stakerBefore.shares.add(earningsBefore);

                await fix.contract.test__internal__compound(account.address);

                const stakerAfter = await fix.contract.positions(account.address);
                const earningsAfter = await fix.contract.earnings(account.address);
                const valueAfter = stakerAfter.shares.add(earningsAfter);

                console.log(earningsBefore.toString(), earningsAfter.toString());

                expect(valueAfter).to.equal(valueBefore);
            });

            it('should emit expected events', async () => {
                const amount = ETH_ONE;
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;
                const shares = ETH_HUNDRED;

                await fix.contract.rig__set__epsX128(epsX128);
                await fix.contract.rig__set__shares(shares);
                await fix.contract.rig__set__positions(account.address, { shares: amount, earnings: 0 });

                await expect(fix.contract.test__internal__compound(account.address))
                    .to.emit(fix.contract, 'SharesIncrease')
                    .and.to.emit(fix.contract, 'EarningsRealized');
            });

            it('should revert if earned is 0', async () => {
                const amount = ETH_ONE;
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;
                const shares = ETH_HUNDRED;

                const startingDebt = js_toEarningsFromEpsX128(shares, epsX128);

                await fix.contract.rig__set__epsX128(epsX128);
                await fix.contract.rig__set__shares(shares);
                await fix.contract.rig__set__positions(account.address, { shares: amount, earnings: startingDebt });

                await expect(fix.contract.test__internal__compound(account.address)).to.be.revertedWith('SM:EARN:0');
            });
        });

        describe('_earnings', async () => {
            it('returns same as js and pure implementation', async () => {
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;
                const userShares = ETH_THOUSAND;
                const userDebt = js_toEarningsFromEpsX128(ETH_ONE, epsX128);
                await fix.contract.rig__set__epsX128(epsX128);
                await fix.contract.rig__set__positions(account.address, { shares: userShares, earnings: userDebt });

                const sol = await fix.contract.test__internal__earnings(account.address);
                const js = js_earningsSM(userShares, userDebt, epsX128);
                const solPure = await fix.contract.test__internal__earnings_pure(userShares, userDebt, epsX128);

                expect(sol).to.equal(js).and.to.equal(solPure);
            });
        });

        describe('_earnings pure', async () => {
            // fuz
            it('returns same as js implementation', async () => {
                const epsX128 = ETH_BILLION;
                const userShares = ETH_THOUSAND;
                const userDebt = js_toEarningsFromEpsX128(ETH_ONE, epsX128);
                const sol = await fix.contract.test__internal__earnings_pure(userShares, userDebt, epsX128);
                const js = js_earningsSM(userShares, userDebt, epsX128);
                expect(sol).to.equal(js);
            });
        });

        describe('_collect', async () => {
            it('should revert if earned is 0', async () => {
                const amount = ETH_ONE;
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;
                const shares = ETH_HUNDRED;

                const startingDebt = js_toEarningsFromEpsX128(shares, epsX128);

                await fix.contract.rig__set__epsX128(epsX128);
                await fix.contract.rig__set__shares(shares);
                await fix.contract.rig__set__positions(account.address, { shares: amount, earnings: startingDebt });

                await expect(fix.contract.test__internal__collect(account.address)).to.be.revertedWith('SM:EARN:0');
            });

            it('should emit expected events', async () => {
                const amount = ETH_ONE;
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;
                const shares = ETH_HUNDRED;

                await fix.contract.rig__set__epsX128(epsX128);
                await fix.contract.rig__set__shares(shares);
                await fix.contract.rig__set__positions(account.address, { shares: amount, earnings: 0 });
                const earnings = await fix.contract.test__internal__earnings(account.address);
                await fix.contract.fallback({ value: earnings });

                await expect(fix.contract.test__internal__collect(account.address)).and.to.emit(fix.contract, 'EarningsRealized');
            });

            it('should move expected eth', async () => {
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;
                const userShares = ETH_THOUSAND;
                const userDebt = js_toEarningsFromEpsX128(ETH_ONE, epsX128);
                await fix.contract.rig__set__epsX128(epsX128);
                await fix.contract.rig__set__positions(account.address, { shares: userShares, earnings: userDebt });

                const earnings = await fix.contract.test__internal__earnings(account.address);
                await fix.contract.fallback({ value: earnings });

                await expect(async () => await fix.contract.test__internal__collect(account.address)).and.changeEtherBalances(
                    [fix.contract, account],
                    [earnings.mul(-1), earnings],
                );
            });
        });

        describe('_paperhand', async () => {
            it('should move expected eth', async () => {
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;
                const userShares = ETH_HUNDRED;
                const userDebt = js_toEarningsFromEpsX128(ETH_HUNDRED.div(2), epsX128);
                await fix.contract.rig__set__epsX128(epsX128);
                await fix.contract.rig__set__positions(account.address, { shares: userShares, earnings: userDebt });
                await fix.contract.rig__set__shares(userShares);

                const earnings = await fix.contract.test__internal__earnings(accounts.frank.address);
                await fix.contract.fallback({ value: earnings.add(userShares) });

                await expect(async () => await fix.contract.test__internal__paperhand(account.address, userShares)).and.changeEtherBalances(
                    [fix.contract, account],
                    [earnings.add(userShares).mul(-1), earnings.add(userShares)],
                );
            });

            it('should move expected eth (not withdrawing all)', async () => {
                const account = accounts.frank;
                const epsX128 = ETH_BILLION;
                const userShares = ETH_HUNDRED;
                const userDebt = js_toEarningsFromEpsX128(ETH_HUNDRED.div(2), epsX128);
                await fix.contract.rig__set__epsX128(epsX128);
                await fix.contract.rig__set__positions(account.address, { shares: userShares, earnings: userDebt });
                await fix.contract.rig__set__shares(userShares);

                const earnings = await fix.contract.test__internal__earnings(accounts.frank.address);
                await fix.contract.fallback({ value: earnings.add(userShares.div(2)) });

                await expect(
                    async () => await fix.contract.test__internal__paperhand(account.address, userShares.div(2)),
                ).and.changeEtherBalances(
                    [fix.contract, account],
                    [earnings.add(userShares.div(2)).mul(-1), earnings.add(userShares.div(2))],
                );
            });
        });
    });

    describe('external', async () => {});
});

describe('fuzzers', async () => {
    beforeEach(async () => {
        await refresh();
    });

    it('simulation 0', async function () {
        this.timeout(10000000000);
        const args: { [index: string]: BigNumber }[] = await BlueBirdPromise.map(Array(100), () => {
            return {
                a: randomBN(ETH_TEN),
                b: randomBN(ETH_TEN),
                c: randomBN(ETH_TEN),
                d: randomBN(ETH_TEN),
                e: randomBN(ETH_TEN),
                f: randomBN(ETH_TEN),
                g: randomBN(ETH_TEN),
                h: randomBN(ETH_TEN),
                i: randomBN(ETH_TEN),
                j: randomBN(ETH_TEN),
                k: randomBN(ETH_TEN),
                l: randomBN(ETH_TEN),
                m: randomBN(ETH_TEN),
                n: randomBN(ETH_TEN),
                o: randomBN(ETH_TEN),
                p: randomBN(ETH_TEN),
                q: randomBN(ETH_TEN),
                r: randomBN(ETH_TEN),
                s: randomBN(ETH_TEN),
                t: randomBN(ETH_TEN),
            };
        });

        await BlueBirdPromise.map(
            args,
            async (arg: { [index: string]: BigNumber }, index) => {
                await refresh();
                await fix.invest({ account: accounts.frank, ethAmount: arg.a, fix, changeEtherBalance: index % 2 == 0 });
                await fix.rewardIncrease({ fix, amount: arg.k.mod(ETH_ONE.div(2)), changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.dee, ethAmount: arg.b, fix, changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.charile, ethAmount: arg.c, fix, changeEtherBalance: index % 2 == 0 });
                await fix.paperhand({ account: accounts.charile, ethAmount: arg.c, fix, changeEtherBalance: index % 2 == 0 });
                await fix.rewardIncrease({ fix, amount: arg.l.mod(ETH_ONE.div(2)), changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.mac, ethAmount: arg.d, fix, changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.dennis, ethAmount: arg.e, fix, changeEtherBalance: index % 2 == 0 });
                await fix.rewardIncrease({ fix, amount: arg.m.mod(ETH_ONE.div(2)), changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.frank, ethAmount: arg.f, fix, changeEtherBalance: index % 2 == 0 });
                await fix.rewardIncrease({ fix, amount: arg.n.mod(ETH_ONE.div(2)), changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.dee, ethAmount: arg.g, fix, changeEtherBalance: index % 2 == 0 });
                await fix.rewardIncrease({ fix, amount: arg.o.mod(ETH_ONE.div(2)), changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.charile, ethAmount: arg.h, fix, changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.mac, ethAmount: arg.i, fix, changeEtherBalance: index % 2 == 0 });
                await fix.rewardIncrease({ fix, amount: arg.p.mod(ETH_ONE.div(2)), changeEtherBalance: index % 2 == 0 });
                await fix.invest({ account: accounts.dennis, ethAmount: arg.j, fix, changeEtherBalance: index % 2 == 0 });
                await fix.rewardIncrease({ fix, amount: arg.q.mod(ETH_ONE.div(2)) });
                await fix.compound({ account: accounts.frank, fix });
                await fix.compound({ account: accounts.frank, fix, revertString: 'STAKE:SI:0' });
                await fix.compound({ account: accounts.frank, fix, revertString: 'STAKE:SI:0' });
                await fix.compound({ account: accounts.frank, fix, revertString: 'STAKE:SI:0' });
                await fix.paperhandAll({ account: accounts.charile, fix, changeEtherBalance: index % 2 == 0 });
                await fix.paperhandAll({ account: accounts.dee, fix, changeEtherBalance: index % 2 == 0 });
                await fix.paperhandAll({ account: accounts.dennis, fix, changeEtherBalance: index % 2 == 0 });
                await fix.paperhandAll({ account: accounts.mac, fix, changeEtherBalance: index % 2 == 0 });
                await fix.paperhandAll({ account: accounts.frank, fix, changeEtherBalance: index % 2 == 0 });
            },
            { concurrency: 1 },
        );
        // });
    });
});

// it('should transfer eth by expected amount', async () => {
//     const amount = ETH_ONE;
//     const account = accounts.frank;
//     await expect(async () => {
//         return await fix.contract.test__internal__invest(account.address, amount);
//     }).to.changeEtherBalances([account, fix.contract], [amount.mul(-1), amount]);
// });
