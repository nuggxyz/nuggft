import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { BigNumber } from 'ethers';
import { expect } from 'chai';

import { NuggFT__factory } from '../types/factories/NuggFT__factory';
import { NamedAccounts } from '../hardhat.config';
import { AuctionableTest, DotNugg__factory, NuggETH, DotNugg, NuggETH__factory } from '../types';
import { NuggFT } from '../types/NuggFT';

import { deployContract, prepareAccounts } from './shared';

const STARTS_WITH = 'data:application/json;base64,';
const STARTS_WITH_2 = 'data:image/svg+xml;base64,';

let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let nuggft: NuggFT;
let dotnugg: DotNugg;
let nuggeth: NuggETH;
// let escrow: Escrow;
let auctionableTest: AuctionableTest;

let BLOCK_OFFSET: BigNumber;

const bids: { [index: string]: BigNumber } = {};
const highestBid: BigNumber = BigNumber.from(0);
const refresh = async () => {
    accounts = await prepareAccounts();

    dotnugg = await deployContract<DotNugg__factory>({
        factory: 'DotNugg',
        from: accounts.deployer,
        args: [],
    });

    nuggeth = await deployContract<NuggETH__factory>({
        factory: 'NuggETH',
        from: accounts.deployer,
        args: [],
    });

    nuggft = await deployContract<NuggFT__factory>({
        factory: 'NuggFT',
        from: accounts.deployer,
        args: [nuggeth.address, dotnugg.address],
    });
    await nuggft.launch('0x');
};

describe('Main', function () {
    const highestBid = 0;

    beforeEach(async () => {
        await refresh();
    });

    it('title', async function (this) {
        this.timeout(1000000);

        const res = await nuggft.pendingTokenURI(1);
        console.log(res);
        expect(res).to.not.be.empty;
        // auctionableTest = await deployContract<NuggFT__factory>({
        //     factory: 'NuggFT',
        //     from: accounts.deployer,
        //     args: [],
        // });
        // auctionableTest = await deployContract<AuctionableTest__factory>({
        //     factory: 'Auctionable_Test',
        //     from: accounts.deployer,
        //     args: [255],
        // });
        // BLOCK_OFFSET = await auctionableTest.genesisBlock();
        // escrow = new Contract(await auctionableTest.tummy(), Escrow__factory.abi, accounts.deployer) as Escrow;
        // await auctionableTest.launch();
        // expect(await auctionableTest.launched()).to.be.equal(true);
    });
});
