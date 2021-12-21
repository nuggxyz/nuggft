import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';
import { Address } from 'ethereumjs-util';

import { NamedAccounts } from '../../../hardhat.config';
import { Mining } from '../lib/shared/mining';
import { prepareAccounts } from '../lib/shared';
import { fromEth, toEth } from '../lib/shared/conversion';
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
            console.log(await fix.nuggft.name());

            const token1 = await fix.nuggft.epoch();

            await fix.nuggft.connect(accounts.mac).delegate(token1);

            await fix.nuggft.connect(accounts.dee).delegate(token1, { value: toEth('3.000') });

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

            for (let i = 2000; i < 2010; i++) {
                await fix.nuggft.connect(accounts.dennis).mint(i, { value: toEth('35') });

                console.log('minshareprice: ', fromEth(await fix.nuggft.connect(accounts.frank).minSharePrice()));
            }

            await Mining.advanceBlockTo(2500);
            await Mining.advanceBlock();

            const token11 = await fix.nuggft.epoch();

            await fix.nuggft.connect(accounts.frank).delegate(token11, { value: toEth('88') });

            await Mining.advanceBlockTo(3500);
            await fix.nuggft.connect(accounts.frank).claim(token11);

            await fix.nuggft.connect(accounts.charile).claim(token1);

            const info = await fix.nuggft.parsedProofOf(token11);

            // eslint-disable-next-line prefer-const
            let dids: number[] = [];

            for (let i = 0; i < 8; i++) {
                dids[i] = (i << 8) | info.defaultIds[i];
                console.log(i, info.defaultIds[i], dids[i]);
            }

            console.log(dids[1].toString(), accounts.dee.address);

            await fix.nuggft.connect(accounts.frank).rotateFeature(token11, 1);

            await fix.nuggft.connect(accounts.frank).swapItem(token11, dids[1], toEth('14'));
            const epoch = await fix.nuggft.connect(accounts.charile).epoch();

            await fix.nuggft.connect(accounts.charile).delegateItem(token11, dids[1], token1, { value: toEth('43') });

            await Mining.advanceBlockTo(4500);

            console.log('epoch', epoch.toString());

            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));

            const info0 = await fix.nuggft.parsedProofOf(token1);

            // eslint-disable-next-line prefer-const
            let dids2: number[] = [];

            for (let i = 0; i < 8; i++) {
                dids2[i] = (i << 8) | info0.defaultIds[i];
                console.log(i, info0.defaultIds[i], dids2[i]);
            }

            await fix.nuggft.connect(accounts.charile).rotateFeature(token1, 2);

            await fix.nuggft.connect(accounts.charile).swapItem(token1, dids2[2], toEth('55'));

            // await fix.nuggft.connect(accounts.charile).claimItem(token11, dids[1], 0, epoch.add(1));

            await fix.nuggft.connect(accounts.frank).approve(fix.nuggft.address, token11);

            await fix.nuggft.connect(accounts.charile).claimItem(token11, dids[1], token1);

            await fix.nuggft.connect(accounts.charile).approve(fix.nuggft.address, token1);

            await Mining.advanceBlockTo(500);

            const epoch1 = await fix.nuggft.connect(accounts.charile).epoch();

            const check1 = await fix.nuggft.connect(accounts.charile).proofOf(epoch1);

            // await fix.nuggft.connect(accounts.charile).delegate(epoch1, { value: toEth('55.000') });

            // await Mining.advanceBlockTo(10000);

            // const check2 = await fix.nuggft.connect(accounts.charile).proofOf(epoch1);

            // console.log(check1, check2, check1.eq(check2));

            console.log(await fix.processor.dotnuggToRaw(fix.nuggft.address, token1, Address.zero().toString(), 45, 10));

            await fix.nuggft.connect(accounts.charile).loan(token1);

            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalProtocolEth()', fromEth(await fix.nuggft.totalProtocolEth()));

            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(token1, { value: toEth('40') });

            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalProtocolEth()', fromEth(await fix.nuggft.totalProtocolEth()));

            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(token1, { value: toEth('40') });
            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));

            console.log('totalProtocolEth()', fromEth(await fix.nuggft.totalProtocolEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(token1, { value: toEth('40') });
            console.log('bal ', (await accounts.charile.getBalance()).toString());

            console.log('activeEthPerShare()', (await fix.nuggft.activeEthPerShare()).toString());
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalProtocolEth()', fromEth(await fix.nuggft.totalProtocolEth()));

            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));

            await fix.nuggft.connect(accounts.charile).payoff(token1, { value: toEth('90') });

            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));
            console.log('bal ', (await accounts.charile.getBalance()).toString());

            await fix.nuggft.connect(fix.deployer).extractProtocolEth();

            await fix.nuggft.connect(accounts.deployer).setMigrator(fix.migrator.address);

            await fix.nuggft.connect(fix.deployer).setIsTrusted(accounts.frank.address);

            await fix.nuggft.connect(accounts.frank).trustedMint(69, accounts.mac.address, { value: toEth('250') });

            await fix.nuggft.connect(accounts.charile).approve(fix.nuggft.address, token1);

            await fix.nuggft.connect(accounts.charile).migrateStake(token1);

            // await fix.nuggft.connect(accounts.frank).payoff(token11, { value: await fix.nuggft.payoffAmount() });
        });
    });
});
