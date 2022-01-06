/* eslint-disable prefer-const */
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';
import { Address } from 'ethereumjs-util';
import { BigNumber } from 'ethers';

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

            // const check = await fix.processor.raw(fix.nuggft.address, await fix.nuggft.epoch(), zeroAddress(), 10, 45);

            const proof = await fix.nuggft.proofToDotnuggMetadata(await fix.nuggft.epoch());
            console.log({ proof });
            let tmp = 1;
            for (let i = 0; i < 8; i++) {
                let lep = await fix.nuggft.lengthOf(i);
                tmp *= lep;
                console.log(i, lep, tmp);
            }

            console.log(tmp);
            const token1 = await fix.nuggft.epoch();

            await fix.nuggft.connect(accounts.mac).delegate(accounts.mac.address, token1, { value: toEth('0.040') });

            await fix.nuggft.connect(accounts.dee).delegate(accounts.dee.address, token1, { value: toEth('0.0690') });

            let last = BigNumber.from(0);
            let lastShare = BigNumber.from(0);

            for (let i = 2000; i < 2010; i++) {
                await fix.nuggft.connect(accounts.dennis).mint(i, {
                    value: await fix.nuggft.minSharePrice(),
                    gasLimit: '89000',
                    accessList: {
                        [`${fix.nuggft.address}`]: ['0x000000000000000000000000000000000000000000000000000000000000000a'],
                    },
                });
                let working = await fix.nuggft.connect(accounts.frank).minSharePrice();
                let workingShare = await fix.nuggft.connect(accounts.frank).ethPerShare();

                console.log(
                    'diff: ',
                    fromEth(working.sub(last)),
                    'diffShare: ',
                    fromEth(workingShare.sub(lastShare)),
                    'minshareprice: ',
                    fromEth(working),
                    'minsharepriceShare: ',
                    fromEth(workingShare),
                );
                last = working;
                lastShare = workingShare;
            }

            await Mining.advanceBlockTo(150);

            await fix.nuggft.connect(accounts.dee).claim(accounts.dee.address, token1);
            await fix.nuggft.connect(accounts.mac).claim(accounts.mac.address, token1);

            await fix.nuggft.connect(accounts.dee).approve(fix.nuggft.address, token1);

            await fix.nuggft.connect(accounts.dee).swap(token1, toEth('5.000'));

            const token3 = await fix.nuggft.epoch();

            await fix.nuggft.connect(accounts.frank).delegate(accounts.frank.address, token3, { value: toEth('20.000') });
            await fix.nuggft.connect(accounts.frank).delegate(accounts.frank.address, token1, { value: toEth('20.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(accounts.dennis.address, token1, { value: toEth('22.000') });
            await fix.nuggft.connect(accounts.frank).delegate(accounts.frank.address, token1, { value: toEth('3.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(accounts.dennis.address, token1, { value: toEth('2.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(accounts.dennis.address, token1, { value: toEth('2.000') });
            await fix.nuggft.connect(accounts.charile).delegate(accounts.charile.address, token1, { value: toEth('30.000') });

            // for (let i = 2000; i < 2001; i++) {
            //     let [ok, next, useroffer] = await fix.nuggft.connect(accounts.dennis).valueForDelegate(accounts.dennis.address, token1);
            //     console.log('dennis should: ', ok, fromEth(next.sub(useroffer)));
            //     await fix.nuggft.connect(accounts.dennis).delegate(accounts.dennis.address, token1, { value: next.sub(useroffer) });

            //     [ok, next, useroffer] = await fix.nuggft.connect(accounts.charile).valueForDelegate(accounts.charile.address, token1);
            //     console.log('charile should: ', ok, fromEth(next.sub(useroffer)));

            //     await fix.nuggft.connect(accounts.charile).delegate(accounts.charile.address, token1, { value: next.sub(useroffer) });
            //     // console.log('minshareprice: ', fromEth(await fix.nuggft.connect(accounts.frank).valueForDelegate()));
            // }

            await Mining.advanceBlockTo(2000);
            await Mining.advanceBlock();

            const token11 = await fix.nuggft.epoch();

            await fix.nuggft.connect(accounts.frank).delegate(accounts.frank.address, token11, { value: toEth('88') });

            await Mining.advanceBlockTo(2500);
            await fix.nuggft.connect(accounts.frank).claim(accounts.frank.address, token11);

            await fix.nuggft.connect(accounts.charile).claim(accounts.charile.address, token1);

            const info = await fix.nuggft.proofToDotnuggMetadata(token11);

            // eslint-disable-next-line prefer-const
            let dids: number[] = [];

            for (let i = 0; i < 8; i++) {
                dids[i] = (i << 8) | info.defaultIds[i];
                console.log(i, info.defaultIds[i], dids[i]);
            }

            console.log(dids[1].toString(), accounts.dee.address);

            await fix.nuggft.connect(accounts.frank).rotate(token11, 1, 19);

            await fix.nuggft.connect(accounts.frank).swapItem(token11, dids[1], toEth('14'));
            const epoch = await fix.nuggft.connect(accounts.charile).epoch();

            await fix.nuggft.connect(accounts.charile).delegateItem(token1, token11, dids[1], { value: toEth('43') });

            await Mining.advanceBlockTo(4500);

            console.log('epoch', epoch.toString());

            console.log('ethPerShare()', fromEth(await fix.nuggft.ethPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('stakedEth()', fromEth(await fix.nuggft.stakedEth()));

            const info0 = await fix.nuggft.proofToDotnuggMetadata(token1);

            // eslint-disable-next-line prefer-const
            let dids2: number[] = [];

            for (let i = 0; i < 8; i++) {
                dids2[i] = (i << 8) | info0.defaultIds[i];
                console.log(i, info0.defaultIds[i], dids2[i]);
            }

            await fix.nuggft.connect(accounts.charile).rotate(token1, 2, 20);

            await fix.nuggft.connect(accounts.charile).swapItem(token1, dids2[2], toEth('55'));

            // await fix.nuggft.connect(accounts.charile).claimItem(token11, dids[1], 0, epoch.add(1));

            await fix.nuggft.connect(accounts.frank).approve(fix.nuggft.address, token11);

            await fix.nuggft.connect(accounts.charile).claimItem(token1, token11, dids[1]);

            await fix.nuggft.connect(accounts.charile).approve(fix.nuggft.address, token1);

            await Mining.advanceBlockTo(500);

            const epoch1 = await fix.nuggft.connect(accounts.charile).epoch();

            const check1 = await fix.nuggft.connect(accounts.charile).proofOf(epoch1);

            // await fix.nuggft.connect(accounts.charile).delegate(epoch1, { value: toEth('55.000') });

            // await Mining.advanceBlockTo(10000);

            // const check2 = await fix.nuggft.connect(accounts.charile).proofOf(epoch1);

            // console.log(check1, check2, check1.eq(check2));

            console.log(await fix.processor.raw(fix.nuggft.address, token1, Address.zero().toString(), '0x00'));

            await fix.nuggft.connect(accounts.charile).loan(token1);

            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('ethPerShare()', fromEth(await fix.nuggft.ethPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('protocolEth()', fromEth(await fix.nuggft.protocolEth()));

            console.log('stakedEth()', fromEth(await fix.nuggft.stakedEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(token1, { value: toEth('40') });

            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('ethPerShare()', fromEth(await fix.nuggft.ethPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('protocolEth()', fromEth(await fix.nuggft.protocolEth()));

            console.log('stakedEth()', fromEth(await fix.nuggft.stakedEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(token1, { value: toEth('40') });
            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('ethPerShare()', fromEth(await fix.nuggft.ethPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('stakedEth()', fromEth(await fix.nuggft.stakedEth()));

            console.log('protocolEth()', fromEth(await fix.nuggft.protocolEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(token1, { value: toEth('40') });
            console.log('bal ', (await accounts.charile.getBalance()).toString());

            console.log('ethPerShare()', (await fix.nuggft.ethPerShare()).toString());
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('protocolEth()', fromEth(await fix.nuggft.protocolEth()));

            console.log('stakedEth()', fromEth(await fix.nuggft.stakedEth()));

            await fix.nuggft.connect(accounts.charile).payoff(token1, { value: toEth('90') });

            console.log('ethPerShare()', fromEth(await fix.nuggft.ethPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('stakedEth()', fromEth(await fix.nuggft.stakedEth()));
            console.log('bal ', (await accounts.charile.getBalance()).toString());

            await fix.nuggft.connect(fix.deployer).extractProtocolEth();

            await fix.nuggft.connect(accounts.deployer).setMigrator(fix.migrator.address);

            await fix.nuggft.connect(fix.deployer).setIsTrusted(accounts.frank.address, true);

            await fix.nuggft.connect(accounts.frank).trustedMint(69, accounts.mac.address, { value: toEth('250') });

            await fix.nuggft.connect(accounts.charile).approve(fix.nuggft.address, token1);

            const a = await fix.nuggft.connect(accounts.charile).proofOf(token1);

            const b = await fix.nuggft.connect(accounts.charile).minSharePrice();

            console.log(a);
            console.log(b);

            await fix.nuggft.connect(accounts.charile).migrate(token1);

            // await fix.nuggft.connect(accounts.frank).payoff(token11, { value: await fix.nuggft.payoffAmount() });
        });
    });
});
