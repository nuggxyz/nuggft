import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';

import { NamedAccounts } from '../../../hardhat.config';
import { Mining } from '../lib/shared/mining';
import { prepareAccounts } from '../lib/shared';
import { toEth } from '../lib/shared/conversion';
import { NuggFatherFix, NuggFatherFixture } from '../lib/fixtures/NuggFather.fix';

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
            await fix.nuggft.connect(accounts.mac).delegate(0);

            await fix.nuggft.connect(accounts.dee).offer(0, { value: toEth('3.000') });

            await Mining.advanceBlockTo(50);

            await fix.nuggft.connect(accounts.dee).claim(0, 0);
            await fix.nuggft.connect(accounts.mac).claim(0, 0);

            await fix.nuggft.connect(accounts.dee).approve(fix.nuggft.address, 0);
            await fix.nuggft.connect(accounts.dee).swap(0, toEth('.02000'));

            await fix.nuggft.connect(accounts.frank).mint(2, { value: toEth('20.000') });
            await fix.nuggft.connect(accounts.frank).commit(0, { value: toEth('20.000') });
            await fix.nuggft.connect(accounts.dennis).offer(0, { value: toEth('22.000') });
            await fix.nuggft.connect(accounts.frank).offer(0, { value: toEth('3.000') });
            await fix.nuggft.connect(accounts.dennis).offer(0, { value: toEth('2.000') });
            await fix.nuggft.connect(accounts.dennis).offer(0, { value: toEth('2.000') });
            await fix.nuggft.connect(accounts.charile).offer(0, { value: toEth('55.000') });

            await Mining.advanceBlockTo(250);
            await Mining.advanceBlock();

            await fix.nuggft.connect(accounts.frank).mint(9, { value: toEth('88') });

            await Mining.advanceBlockTo(350);
            await fix.nuggft.connect(accounts.frank).claim(9, 9);

            await fix.nuggft.connect(accounts.charile).claim(0, 3);

            const info = await fix.nuggft.parsedProofOf(9);
            console.log(info.defaultIds[0].toString(), accounts.dee.address);
            await fix.nuggft.connect(accounts.frank).swapItem(9, info.defaultIds[0], toEth('14'));
            const epoch = await fix.nuggft.connect(accounts.charile).epoch();

            await fix.nuggft.connect(accounts.charile).delegateItem(9, info.defaultIds[0], 0, { value: toEth('43') });

            await Mining.advanceBlockTo(450);

            console.log('epoch', epoch.toString());

            const info0 = await fix.nuggft.parsedProofOf(0);

            await fix.nuggft.connect(accounts.charile).swapItem(0, info0.defaultIds[2], toEth('55'));

            await fix.nuggft.connect(accounts.charile).claimItem(9, info.defaultIds[0], 0, epoch.add(2));
        });
    });
});
