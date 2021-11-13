import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { expect } from 'chai';

import { EpochableTest, EpochableTest__factory } from '../typechain';
import { NamedAccounts } from '../hardhat.config';
import { NuggFT } from '../typechain/NuggFT';
import { NuggFT__factory } from '../typechain/factories/NuggFT__factory';
import { MockEscrow } from '../typechain/MockEscrow';

import { deployContract, prepareAccounts } from './shared';
import { Mining } from './shared/mining';

const STARTS_WITH = 'data:application/json;base64,';
const STARTS_WITH_2 = 'data:image/svg+xml;base64,';

let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let nuggft: NuggFT;
let escrow: MockEscrow;
let epochableTest: EpochableTest;

let BLOCK_OFFSET: BigNumber;

describe('Main', async function () {
    before(async function () {
        accounts = await prepareAccounts();

        nuggft = await deployContract<NuggFT__factory>({
            factory: 'NuggFT',
            from: accounts.deployer,
            args: [],
        });

        // escrow = new Contract(await nuggft.tummy(), MockEscrow__factory.abi, accounts.deployer) as MockEscrow;

        epochableTest = await deployContract<EpochableTest__factory>({
            factory: 'Epochable_Test',
            from: accounts.deployer,
            args: [255],
        });

        BLOCK_OFFSET = await epochableTest.genesisBlock();

        await nuggft.launch();

        expect(await nuggft.launched()).to.be.equal(true);

        // expect().to.changeEtherBalance()

        // console.log();
        // minter = new Contract(await nuggft.MINTER(), NuggFTMinter__factory.abi) as NuggFTMinter;
        // console.log(nuggft.address);
        // await nuggft.launch();
    });

    describe('Epochable checks', async function () {
        // BLOCKNUM TO EPOCH
        it('_currentEpochTest', async function () {
            expect(await epochableTest._currentEpochTest()).to.be.equal(0);
        });
        it('_epochFromBlocknumTest(2)', async function () {
            await Mining.advanceBlockTo(BLOCK_OFFSET.add(2));

            expect(await epochableTest._epochFromBlocknumTest(BLOCK_OFFSET.add(2))).to.be.equal(0);
        });
        it('_epochFromBlocknumTest(10)', async function () {
            const num = BLOCK_OFFSET.add(10);
            await Mining.advanceBlockTo(BLOCK_OFFSET.add(num));
            expect(await epochableTest._epochFromBlocknumTest(num)).to.be.equal(0);
        });
        it('_epochFromBlocknumTest(200)', async function () {
            const num = BLOCK_OFFSET.add(200);

            await Mining.advanceBlockTo(num);
            expect(await epochableTest._epochFromBlocknumTest(num)).to.be.equal(0);
        });
        it('_epochFromBlocknumTest(254)', async function () {
            const num = BLOCK_OFFSET.add(254);

            await Mining.advanceBlockTo(num);
            expect(await epochableTest._epochFromBlocknumTest(num)).to.be.equal(0);
        });
        it('_epochFromBlocknumTest(255)', async function () {
            const num = BLOCK_OFFSET.add(255);
            await Mining.advanceBlockTo(num);
            expect(await epochableTest._epochFromBlocknumTest(num)).to.be.equal(1);
        });
        it('_epochFromBlocknumTest(509)', async function () {
            const num = BLOCK_OFFSET.add(509);

            await Mining.advanceBlockTo(num);
            expect(await epochableTest._epochFromBlocknumTest(num)).to.be.equal(1);
        });

        // EPOCH TO BLOCKNUM
        it('_blocknumFirstFromEpochTest(0)', async function () {
            expect(await epochableTest._blocknumFirstFromEpochTest(0)).to.be.equal(BLOCK_OFFSET.add(0));
        });
        it('_blocknumFinalFromEpochTest(0)', async function () {
            expect(await epochableTest._blocknumFinalFromEpochTest(0)).to.be.equal(BLOCK_OFFSET.add(254));
        });
        it('_blocknumFirstFromEpochTest(1)', async function () {
            expect(await epochableTest._blocknumFirstFromEpochTest(1)).to.be.equal(BLOCK_OFFSET.add(255));
        });
        it('_blocknumFinalFromEpochTest(1)', async function () {
            expect(await epochableTest._blocknumFinalFromEpochTest(1)).to.be.equal(BLOCK_OFFSET.add(510));
        });
        it('_blocknumFirstFromEpochTest(5)', async function () {
            expect(await epochableTest._blocknumFirstFromEpochTest(5)).to.be.equal(BLOCK_OFFSET.add(1279));
        });
        it('_blocknumFinalFromEpochTest(5)', async function () {
            expect(await epochableTest._blocknumFinalFromEpochTest(5)).to.be.equal(BLOCK_OFFSET.add(1534));
        });

        // CHECK BLOCKHASHES
        it('_setBlockhashTest(currentEpoch)', async function () {
            const currentEpoch = await epochableTest._currentEpochTest();
            await expect(epochableTest._setBlockhashTest(currentEpoch)).to.not.be.revertedWith('EPC:SBL');
        });
        it('_getValidBlockhashTest(currentEpoch)', async function () {
            const currentEpoch = await epochableTest._currentEpochTest();
            const firstBlocknum = await epochableTest._blocknumFirstFromEpochTest(currentEpoch);
            expect(await epochableTest._getValidBlockhashTest(currentEpoch)).to.be.equal(
                (await ethers.provider._getBlock(+firstBlocknum)).hash,
            );
        });
        it('_getValidBlockhash(currentEpoch + 1)', async function () {
            const currentEpoch = await epochableTest._currentEpochTest();
            await expect(epochableTest._getValidBlockhashTest(+currentEpoch + 1)).to.be.revertedWith('EPC:GBL:0');
        });
        it('_getValidBlockhash(currentEpoch - 1)', async function () {
            const currentEpoch = await epochableTest._currentEpochTest();
            await expect(epochableTest._getValidBlockhashTest(+currentEpoch - 1)).to.be.revertedWith('EPC:GBL:1');
        });
        it('_setBlockhash(currentEpoch - 1)', async function () {
            const currentEpoch = await epochableTest._currentEpochTest();
            await expect(epochableTest._setBlockhashTest(+currentEpoch - 1)).to.be.revertedWith('EPC:SBL');
        });
        it('_setBlockhash(currentEpoch + 1)', async function () {
            const currentEpoch = await epochableTest._currentEpochTest();
            await expect(epochableTest._setBlockhashTest(+currentEpoch + 1)).to.be.revertedWith('EPC:SBL');
        });
    });
});
