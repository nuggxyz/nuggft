import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';
import { BigNumber } from 'ethers';

import { MockStakeMath } from '../archive/stakablev2/MockStakeMath';
import { NamedAccounts } from '../hardhat.config';

import { Mining } from './shared/mining';
import { prepareAccounts } from './shared';
import { toEth } from './shared/conversion';
import { NuggFatherFix, NuggFatherFixture } from './fixtures/NuggFather.fix';
import { getHRE } from './shared/deployment';
const createFixtureLoader = waffle.createFixtureLoader;
const {
    constants: { MaxUint256 },
} = ethers;

let loadFixture: ReturnType<typeof createFixtureLoader>;
let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let fix: NuggFatherFixture;

const refresh = async () => {
    accounts = await prepareAccounts();
    loadFixture = createFixtureLoader();
    fix = await loadFixture(NuggFatherFix);
};

describe('uint tests', async function () {
    beforeEach(async () => {
        await refresh();
    });

    describe('internal', async () => {
        it('should revert if shares = 0', async () => {
            await fix.nuggeth.connect(accounts.dee).deposit({ value: toEth('40') });
            const res = await fix.nuggeth.balanceOf(accounts.dee.address);
            console.log(res.toString());

            await fix.nuggeth.connect(accounts.dee).approve(fix.minter.address, toEth('40'));

            await fix.minter.connect(accounts.dee).placeBid(BigNumber.from(0), toEth('20'), 0, { value: toEth('20.000') });
            const res1 = await fix.nuggeth.balanceOf(accounts.dee.address);
            console.log(res1.toString());

            // await fix.nuggeth.connect(accounts.dee).approve(fix.minter.address, toEth('40'));

            await fix.minter.connect(accounts.frank).placeBid(BigNumber.from(0), toEth('20.0001'), 0, { value: toEth('20.0001') });
            const res4 = await fix.nuggeth.balanceOf(accounts.frank.address);
            console.log(res4.toString());

            await fix.weth.connect(accounts.frank).deposit({ value: toEth('20') });
            await fix.weth.connect(accounts.frank).approve(fix.relay.address, toEth('20'));
            await fix.relay.connect(accounts.frank).depositWETH(toEth('20'));

            // await fix.relay.connect(accounts.dee).depositWETH();
            const res2 = await fix.nuggeth.balanceOf(accounts.dee.address);
            const res3 = await fix.nuggeth.totalSupply();

            await fix.nuggeth.connect(accounts.mac).deposit({ value: toEth('40') });
            const res5 = await fix.nuggeth.balanceOf(accounts.mac.address);
            console.log(res5.toString());

            let earnings = await fix.nuggeth.earningsOf(accounts.dee.address);
            let position = await fix.nuggeth.positionOf(accounts.dee.address);
            console.log({
                PRECOMPOUND: {
                    calc: earnings.toString(),
                    trueX128: position.earnings.toString(),
                    shares: position.shares.toString(),
                },
            });

            await fix.nuggeth.connect(accounts.dee).compound();
            const res6 = await fix.nuggeth.balanceOf(accounts.dee.address);
            console.log(res6.toString());

            earnings = await fix.nuggeth.earningsOf(accounts.dee.address);
            position = await fix.nuggeth.positionOf(accounts.dee.address);
            console.log({
                AFTERCOMPOUND: {
                    calc: earnings.toString(),
                    trueX128: position.earnings.toString(),
                    shares: position.shares.toString(),
                    sudo: MockStakeMath.convertSharesToEarnings(
                        {
                            epsX128: await fix.nuggeth.epsX128(),
                            shares: await fix.nuggeth.totalShares(),
                        },
                        position.shares,
                    ).toString(),
                },
            });
            await fix.nuggeth.connect(accounts.dee).withdraw(toEth('1'));
            const res9 = await fix.nuggeth.balanceOf(accounts.dee.address);
            console.log('test withdraw', res9.toString());

            console.log(res2.toString(), res3.toString());

            await Mining.advanceBlockTo(BigNumber.from(fix.blockOffset).add(100));

            await fix.minter.connect(accounts.frank).claim(0, 0);

            await fix.nuggft.connect(accounts.frank).approve(fix.seller.address, 0);

            // const res7 = await fix.minter.getBid(0, accounts.frank.address);
            await fix.seller.connect(accounts.frank).startSale(0, 10, toEth('1'));

            await fix.seller.connect(accounts.dee).placeBid(0, toEth('3'), 0, {
                value: toEth('3'),
            });

            await Mining.advanceBlockTo(BigNumber.from(await getHRE().ethers.provider.getBlockNumber()).add(15));

            await fix.seller.connect(accounts.dee).claim(0, 0);

            await fix.seller.connect(accounts.frank).claimSale(0, 0);

            await fix.nuggft.connect(accounts.dee).approve(fix.seller.address, 0);

            // const res7 = await fix.minter.getBid(0, accounts.frank.address);
            await fix.seller.connect(accounts.dee).startSale(0, 10, toEth('1'));

            await fix.seller.connect(accounts.mac).placeBid(1, toEth('3'), 0, {
                value: toEth('3'),
            });

            await Mining.advanceBlockTo(BigNumber.from(await getHRE().ethers.provider.getBlockNumber()).add(15));

            await fix.seller.connect(accounts.mac).claim(1, 0);

            await fix.seller.connect(accounts.dee).claimSale(1, 0);

            // await fix.nuggeth.connect(accounts.dee).claimSale(1, 0);
            // await fix.nuggft.connect(accounts.mac).transferFrom(accounts.mac.address, accounts.dee.address, 0);

            // await fix.auction.connect(accounts.dee).movePendingReward();
            // // const res6 = await fix.nuggeth.balanceOf(accounts.dee.address);
            // // console.log(res6.toString());
        });
    });
});
