import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';
import Decimal from 'decimal.js';

import { NamedAccounts } from '../hardhat.config';
import { NuggDeployer__factory } from '../types/factories/NuggDeployer__factory';

import { NuggDeployer } from './../types/NuggDeployer.d';
import { deployContract, prepareAccounts } from './shared';

const createFixtureLoader = waffle.createFixtureLoader;
const {
    constants: { MaxUint256 },
} = ethers;

Decimal.config({ toExpNeg: -500, toExpPos: 500 });
let loadFixture: ReturnType<typeof createFixtureLoader>;
let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let deployer: NuggDeployer;

const refresh = async () => {
    accounts = await prepareAccounts();
    deployer = await deployContract<NuggDeployer__factory>({
        factory: 'NuggDeployer',
        from: accounts.deployer,
        args: [],
    });

    console.log('nuggft: ', await deployer.NUGGFT());
    console.log('swap:   ', await deployer.NUGGSWAP());
    console.log('pool:   ', await deployer.NUGGPOOL());
    console.log('dotnugg:', await deployer.DOTNUGG());
};

describe('uint tests', async function () {
    beforeEach(async () => {
        await refresh();
    });

    describe('internal', async () => {
        describe('_rewardIncrease', async () => {
            it('should revert if shares = 0', async () => {});
        });
    });
});
