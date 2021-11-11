import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';
import Decimal from 'decimal.js';

import { NamedAccounts } from '../hardhat.config';

import { getHRE } from './shared/deployment';
import { prepareAccounts } from './shared';
import { expect } from './shared/expect';
import { NuggFatherFix, NuggFatherFixture } from './fixtures/NuggFather.fix';
const createFixtureLoader = waffle.createFixtureLoader;
const {
    constants: { MaxUint256 },
} = ethers;

Decimal.config({ toExpNeg: -500, toExpPos: 500 });
let loadFixture: ReturnType<typeof createFixtureLoader>;
let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let fix: NuggFatherFixture;

const refresh = async () => {
    accounts = await prepareAccounts();
    loadFixture = createFixtureLoader();
    fix = await loadFixture(NuggFatherFix);
    getHRE().tracer.nameTags[accounts.deployer.address] = 'father';
};

describe('address prefix checks', async function () {
    before(async () => {
        await refresh();
    });
    it('addresses exist', () => {
        console.log('father   ', fix.father.address);
        console.log('weth:      ', fix.weth.address);

        console.log('nuggeth:   ', fix.nuggeth.address);
        console.log('relay:     ', fix.relay.address);
        console.log('dotnugg:   ', fix.dotnugg.address);
        console.log('nuggft:    ', fix.nuggft.address);
        console.log('auction:   ', fix.auction.address);
    });

    it('NuggETH has prefix', async () => {
        expect(fix.nuggeth.address).to.contain('0x420690');
    });
    it('NuggEthRelay has prefix', async () => {
        expect(fix.relay.address).to.contain('0x420690');
    });
    it('DotNugg has prefix', async () => {
        expect(fix.dotnugg.address).to.contain('0x420690');
    });

    it('NuggFT has prefix', async () => {
        expect(fix.nuggft.address).to.contain('0x420690');
    });

    it('NuggAuction has prefix', async () => {
        expect(fix.auction.address).to.contain('0x420690');
    });
});
