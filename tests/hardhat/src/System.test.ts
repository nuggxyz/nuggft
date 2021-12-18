import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';

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
            await fix.nuggft.connect(accounts.mac).delegate2(1);

            await fix.nuggft.connect(accounts.dee).delegate(1, { value: toEth('3.000') });

            await Mining.advanceBlockTo(51);

            await fix.nuggft.connect(accounts.dee).claim(1);
            await fix.nuggft.connect(accounts.mac).claim(1);

            await fix.nuggft.connect(accounts.dee).approve(fix.nuggft.address, 1);
            await fix.nuggft.connect(accounts.dee).swap(1, toEth('5.000'));

            await fix.nuggft.connect(accounts.frank).delegate(3, { value: toEth('20.000') });
            await fix.nuggft.connect(accounts.frank).delegate(1, { value: toEth('20.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(1, { value: toEth('22.000') });
            await fix.nuggft.connect(accounts.frank).delegate(1, { value: toEth('3.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(1, { value: toEth('2.000') });
            await fix.nuggft.connect(accounts.dennis).delegate(1, { value: toEth('2.000') });
            await fix.nuggft.connect(accounts.charile).delegate(1, { value: toEth('55.000') });

            await Mining.advanceBlockTo(250);
            await Mining.advanceBlock();

            await fix.nuggft.connect(accounts.frank).delegate(11, { value: toEth('88') });

            await Mining.advanceBlockTo(350);
            await fix.nuggft.connect(accounts.frank).claim(11);

            await fix.nuggft.connect(accounts.charile).claim(1);
            const info = await fix.nuggft.parsedProofOf(11);

            console.log(info.defaultIds[1].toString(), accounts.dee.address);

            await fix.nuggft.connect(accounts.frank).swapItem(11, info.defaultIds[1], toEth('14'));
            const epoch = await fix.nuggft.connect(accounts.charile).epoch();

            await fix.nuggft.connect(accounts.charile).delegateItem(11, info.defaultIds[1], 1, { value: toEth('43') });

            await Mining.advanceBlockTo(450);

            console.log('epoch', epoch.toString());

            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));

            const info0 = await fix.nuggft.parsedProofOf(1);

            await fix.nuggft.connect(accounts.charile).swapItem(1, info0.defaultIds[2], toEth('55'));

            // await fix.nuggft.connect(accounts.charile).claimItem(11, info.defaultIds[1], 0, epoch.add(1));

            await fix.nuggft.connect(accounts.frank).approve(fix.nuggft.address, 11);

            await fix.nuggft.connect(accounts.charile).claimItem(11, info.defaultIds[1], 1);

            await fix.nuggft.connect(accounts.charile).approve(fix.nuggft.address, 1);

            await Mining.advanceBlockTo(500);

            const epoch1 = await fix.nuggft.connect(accounts.charile).epoch();

            const check1 = await fix.nuggft.connect(accounts.charile).proofOf(epoch1);

            // await fix.nuggft.connect(accounts.charile).delegate(epoch1, { value: toEth('55.000') });

            // await Mining.advanceBlockTo(10000);

            // const check2 = await fix.nuggft.connect(accounts.charile).proofOf(epoch1);

            // console.log(check1, check2, check1.eq(check2));

            console.log(await fix.nuggft.rawProcessURI(1));

            await fix.nuggft.connect(accounts.charile).loan(1);

            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalProtocolEth()', fromEth(await fix.nuggft.totalProtocolEth()));

            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(1, { value: toEth('40') });

            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalProtocolEth()', fromEth(await fix.nuggft.totalProtocolEth()));

            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(1, { value: toEth('40') });
            console.log('bal ', fromEth(await accounts.charile.getBalance()));
            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));

            console.log('totalProtocolEth()', fromEth(await fix.nuggft.totalProtocolEth()));
            await fix.nuggft.connect(accounts.charile).rebalance(1, { value: toEth('40') });
            console.log('bal ', (await accounts.charile.getBalance()).toString());

            console.log('activeEthPerShare()', (await fix.nuggft.activeEthPerShare()).toString());
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalProtocolEth()', fromEth(await fix.nuggft.totalProtocolEth()));

            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));

            await fix.nuggft.connect(accounts.frank).burn(11);

            console.log('activeEthPerShare()', fromEth(await fix.nuggft.activeEthPerShare()));
            console.log('totalSupply()', fromEth(await fix.nuggft.totalSupply()));
            console.log('totalStakedEth()', fromEth(await fix.nuggft.totalStakedEth()));

            // await fix.nuggft.connect(accounts.frank).payoff(11, { value: await fix.nuggft.payoffAmount() });
        });
    });
});
