/* eslint-disable prefer-const */
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';
import { BigNumber } from 'ethers';

import { NamedAccounts } from '../../../hardhat.config';
import { prepareAccounts } from '../lib/shared';
import { NuggFatherFix, NuggFatherFixture } from '../lib/fixtures/NuggFather.fix';
import { fromEth, toEth } from '../lib/shared/conversion';
import { Mining } from '../lib/shared/mining';

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
            console.log(await fix.nuggft.name());

            const token1 = await fix.nuggft.epoch();

            await fix.nuggft.connect(accounts.mac).delegate(token1);

            await fix.nuggft.connect(accounts.dee).delegate(token1, { value: toEth('0.0690') });

            let last = BigNumber.from(0);
            let lastShare = BigNumber.from(0);

            await Mining.advanceBlockTo(510);

            await fix.nuggft.connect(accounts.dee).claim(token1);
            await fix.nuggft.connect(accounts.mac).claim(token1);

            await fix.nuggft.connect(accounts.dee).approve(fix.nuggft.address, token1);

            await fix.nuggft.connect(accounts.dee).swap(token1, toEth('5.000'));

            const token3 = await fix.nuggft.epoch();

            await fix.nuggft.connect(accounts.frank).delegate(token3, { value: toEth('20.000') });
            await fix.nuggft.connect(accounts.frank).delegate(token1, { value: toEth('20.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(token1, { value: toEth('22.000') });
            await fix.nuggft.connect(accounts.frank).delegate(token1, { value: toEth('3.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(token1, { value: toEth('2.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(token1, { value: toEth('2.000') });
            await fix.nuggft.connect(accounts.charile).delegate(token1, { value: toEth('30.000') });

            await Mining.advanceBlockTo(2500);
            await Mining.advanceBlock();
            await fix.nuggft.connect(accounts.charile).claim(token1);
            console.log('bal before', fromEth(await accounts.dee.getBalance()));
            // console.log('bal ', fromEth(await ));

            await fix.nuggft.connect(accounts.dee).claim(token1);
            console.log('bal after', fromEth(await accounts.dee.getBalance()));
        });
    });
});
