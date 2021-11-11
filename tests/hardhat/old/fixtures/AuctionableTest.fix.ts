import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { Fixture, MockProvider } from 'ethereum-waffle';
import { BigNumber, Wallet } from 'ethers';
import { expect } from 'chai';

import { AuctionableTest } from '../../types/AuctionableTest';
import { deployContract } from '../shared';
import { AuctionableTest__factory } from '../../types';
import { ETH_ZERO, toEth } from '../shared/conversion';

export interface AuctionableTestFixture {
    contract: AuctionableTest;
    blockOffset: BigNumber;
    bids: { [index: string]: BigNumber };
    highestBid: BigNumber;
    bid(args: BidArgs): Chai.AsyncAssertion;
    claim(args: ClaimArgs): Chai.AsyncAssertion;
    args: AuctionableTestFixtureArgs;
}

type AuctionableTestFixtureArgs = {
    interval: number;
    floor: BigNumber;
    newPercent: number;
};

export const auctionableTestArgs: AuctionableTestFixtureArgs = {
    interval: 255,
    floor: toEth('0.03'),
    newPercent: 15,
};

export const auctionableTestFixture: Fixture<AuctionableTestFixture> = async function (
    wallets: Wallet[],
    provider: MockProvider,
): Promise<AuctionableTestFixture> {
    const contract = await deployContract<AuctionableTest__factory>({
        factory: 'Auctionable_Test',
        from: provider.getSigner(0),
        args: [auctionableTestArgs.interval, auctionableTestArgs.floor, auctionableTestArgs.newPercent],
    });

    const blockOffset = await contract.genesisBlock();

    const bids: { [index: string]: BigNumber } = {};
    const highestBid: BigNumber = BigNumber.from(0);

    return { contract, blockOffset, bids, highestBid, bid, claim, args: auctionableTestArgs };
};

type BidArgs = {
    fix: AuctionableTestFixture;
    account: SignerWithAddress;
    epoch: number;
    amount: BigNumber;
    revertString?: string;
};

const bid = (args: BidArgs): Chai.AsyncAssertion => {
    if (args.revertString) {
        return expect(args.fix.contract.connect(args.account).placeBid(args.epoch, { value: args.amount })).to.be.revertedWith(
            args.revertString,
        );
    }

    if (args.fix.bids[args.account.address] === undefined) args.fix.bids[args.account.address] = BigNumber.from(0);
    args.fix.bids[args.account.address] = args.fix.bids[args.account.address].add(args.amount);
    const lastHighesstBid = args.fix.highestBid;
    args.fix.highestBid = args.fix.bids[args.account.address];

    const rewardAmt = args.fix.highestBid.sub(lastHighesstBid);
    // const tuck = rewardAmt.mul(0).div(100000);

    return expect(async () => {
        return await args.fix.contract.connect(args.account).placeBid(args.epoch, { value: args.amount });
    }).to.changeEtherBalances([args.account, args.fix.contract], [args.amount.mul(-1), args.amount]);
};

type ClaimArgs = {
    fix: AuctionableTestFixture;
    account: SignerWithAddress;
    epoch: number;
    revertString?: string;
};

const claim = (args: ClaimArgs): Chai.AsyncAssertion => {
    if (args.revertString) {
        return expect(args.fix.contract.connect(args.account).claim(args.epoch)).to.be.revertedWith(args.revertString);
    }
    const amount = args.fix.bids[args.account.address];
    if (amount.eq(args.fix.highestBid)) {
        return expect(async () => {
            return await args.fix.contract.connect(args.account).claim(args.epoch);
        }).to.changeEtherBalances([args.fix.contract, args.account], [ETH_ZERO, ETH_ZERO]);
    }
    return expect(async () => {
        return await args.fix.contract.connect(args.account).claim(args.epoch);
    }).to.changeEtherBalances([args.fix.contract, args.account], [amount.mul(-1), amount]);
};
