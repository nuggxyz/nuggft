import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { Fixture, MockProvider } from 'ethereum-waffle';
import { BigNumber, ethers, Wallet } from 'ethers';
import { expect } from 'chai';

import { js_earningsSM, js_toEarningsFromEpsX128, js_toEpsX128FromShares } from '../../archive/stakablev2/MockStakeMath';
import { StakeableTest } from '../../types/StakeableTest';
import { deployContract } from '../shared';
import { StakeableTest__factory } from '../../types';
import { ETH_ZERO } from '../shared/conversion';

export interface StakeableTestFixture {
    contract: StakeableTest;
    js_shares: BigNumber;
    js_epsX128: BigNumber;
    js_users: { [index: string]: { shares: BigNumber; debt: BigNumber } };
    invest(args: InvestArgs): Chai.AsyncAssertion;
    compound(args: CompoundArgs): Chai.AsyncAssertion;
    earnings(args: EarningsArgs): Chai.Assertion;
    realize(args: RealizeArgs): Chai.AsyncAssertion;
    paperhand(args: PaperhandArgs): Chai.AsyncAssertion;
    rewardIncrease(args: RewardIncreaseArgs): Chai.AsyncAssertion;
    paperhandAll(args: PaperhandAllArgs): Chai.AsyncAssertion;
    deployer: ethers.providers.JsonRpcSigner;
}

export const stakeableTestFixture: Fixture<StakeableTestFixture> = async function (
    wallets: Wallet[],
    provider: MockProvider,
): Promise<StakeableTestFixture> {
    const contract = await deployContract<StakeableTest__factory>({
        factory: 'Stakeable_Test',
        from: provider.getSigner(0),
        args: [],
    });

    const deployer = provider.getSigner(0);

    const js_shares: BigNumber = BigNumber.from(0);
    const js_epsX128: BigNumber = BigNumber.from(0);
    const js_users: { [index: string]: { shares: BigNumber; debt: BigNumber } } = {};
    return {
        contract,
        js_shares,
        js_epsX128,
        js_users,
        earnings,
        compound,
        invest,
        realize,
        paperhand,
        rewardIncrease,
        paperhandAll,
        deployer,
    };
};

type InvestArgs = {
    fix: StakeableTestFixture;
    account: SignerWithAddress;
    ethAmount: BigNumber;
    revertString?: string;
    changeEtherBalance?: boolean;
};

const invest = (args: InvestArgs): Chai.AsyncAssertion => {
    if (args.revertString) {
        return expect(args.fix.contract.connect(args.account).invest({ value: args.ethAmount })).to.be.revertedWith(args.revertString);
    }
    if (args.fix.js_users[args.account.address] === undefined)
        args.fix.js_users[args.account.address] = { shares: ETH_ZERO, debt: ETH_ZERO };
    args.fix.js_users[args.account.address].shares = args.fix.js_users[args.account.address].shares.add(args.ethAmount);
    const debt = js_toEarningsFromEpsX128(args.ethAmount, args.fix.js_epsX128);
    args.fix.js_users[args.account.address].debt = args.fix.js_users[args.account.address].debt.add(debt);
    args.fix.js_shares = args.fix.js_shares.add(args.ethAmount);

    if (args.changeEtherBalance) {
        return expect(async () => await args.fix.contract.connect(args.account).invest({ value: args.ethAmount })).to.changeEtherBalances(
            [args.account, args.fix.contract],
            [args.ethAmount.mul(-1), args.ethAmount],
        );
    }
    return expect(args.fix.contract.connect(args.account).invest({ value: args.ethAmount }))
        .and.to.emit(args.fix.contract, 'SharesIncrease')
        .withArgs(
            args.account.address,
            args.ethAmount,
            // debt,
            args.fix.js_shares,
            args.fix.js_users[args.account.address].shares,
            args.fix.js_users[args.account.address].debt,
        );
};

type RewardIncreaseArgs = {
    fix: StakeableTestFixture;
    amount: BigNumber;
    revertString?: string;
    changeEtherBalance?: boolean;
};

const rewardIncrease = (args: RewardIncreaseArgs): Chai.AsyncAssertion => {
    if (args.revertString) {
        return expect(args.fix.contract.test__internal__rewardIncrease(args.amount, { value: args.amount })).to.be.revertedWith(
            args.revertString,
        );
    }
    const increase = js_toEpsX128FromShares(args.amount, args.fix.js_shares);
    args.fix.js_epsX128 = args.fix.js_epsX128.add(increase);
    // console.log('hola2', args.amount.toString(), increase.toString(), args.fix.js_epsX128.toString());
    if (args.changeEtherBalance) {
        return expect(() => args.fix.contract.test__internal__rewardIncrease(args.amount, { value: args.amount })).to.changeEtherBalances(
            [args.fix.deployer, args.fix.contract],
            [args.amount.mul(-1), args.amount],
        );
    }
    return expect(args.fix.contract.test__internal__rewardIncrease(args.amount, { value: args.amount }))
        .to.emit(args.fix.contract, 'RewardIncrease')
        .withArgs(args.amount, args.fix.js_epsX128);
};

type CompoundArgs = {
    fix: StakeableTestFixture;
    account: SignerWithAddress;
    revertString?: string;
};

const compound = (args: CompoundArgs): Chai.AsyncAssertion => {
    if (args.revertString) {
        return expect(args.fix.contract.connect(args.account).compound()).to.be.revertedWith(args.revertString);
    }

    const earned = js_earnings(args.fix, args.account.address);
    args.fix.js_users[args.account.address].debt = js_toEarningsFromEpsX128(
        args.fix.js_users[args.account.address].shares,
        args.fix.js_epsX128,
    );
    args.fix.js_users[args.account.address].shares = args.fix.js_users[args.account.address].shares.add(earned);
    const debt = js_toEarningsFromEpsX128(earned, args.fix.js_epsX128);
    args.fix.js_users[args.account.address].debt = args.fix.js_users[args.account.address].debt.add(debt);
    args.fix.js_shares = args.fix.js_shares.add(earned);
    console.log(
        'elo govna',
        earned.toString(),
        debt.toString(),
        args.fix.js_shares.toString(),
        args.fix.js_users[args.account.address].shares.toString(),
        args.fix.js_users[args.account.address].debt.toString(),
    );
    // no eth should be transfered
    return (
        expect(args.fix.contract.connect(args.account).compound())
            // .to.changeEtherBalances([args.account, args.fix.contract], [ETH_ZERO, ETH_ZERO])
            .and.to.emit(args.fix.contract, 'EarningsRealized')
            .withArgs(args.account.address, earned)
            .and.to.emit(args.fix.contract, 'SharesIncrease')
            .withArgs(
                args.account.address,
                earned,
                // debt,
                args.fix.js_shares,
                args.fix.js_users[args.account.address].shares,
                args.fix.js_users[args.account.address].debt,
            )
    );
};

type EarningsArgs = {
    fix: StakeableTestFixture;
    account: SignerWithAddress;
};

const earnings = (args: EarningsArgs): Chai.Assertion => {
    const js = js_earnings(args.fix, args.account.address);
    return expect(async () => await args.fix.contract.earnings(args.account.address)).to.equal(js);
};

const js_earnings = (fix: StakeableTestFixture, account: string): BigNumber => {
    const user = fix.js_users[account];
    return js_earningsSM(user.shares, user.debt, fix.js_epsX128);

    // const res = unadjustedEarnings.sub(user.debt);

    // return res.div(10).mul(10);
};

type RealizeArgs = {
    fix: StakeableTestFixture;
    account: SignerWithAddress;
    revertString?: string;
    changeEtherBalance?: boolean;
};

const realize = (args: RealizeArgs): Chai.AsyncAssertion => {
    if (args.revertString) {
        return expect(args.fix.contract.connect(args.account).collect()).to.be.revertedWith(args.revertString);
    }
    const earned = js_earnings(args.fix, args.account.address);
    args.fix.js_users[args.account.address].debt = js_toEarningsFromEpsX128(
        args.fix.js_users[args.account.address].shares,
        args.fix.js_epsX128,
    );

    if (args.changeEtherBalance) {
        return expect(async () => await args.fix.contract.connect(args.account).collect()).to.changeEtherBalances(
            [args.account, args.fix.contract],
            [earned, earned.mul(-1)],
        );
    }

    return expect(args.fix.contract.connect(args.account).collect())
        .and.to.emit(args.fix.contract, 'EarningsRealized')
        .withArgs(args.account.address, earned);
};
//
type PaperhandArgs = {
    fix: StakeableTestFixture;
    ethAmount: BigNumber;
    account: SignerWithAddress;
    revertString?: string;
    changeEtherBalance?: boolean;
};

const paperhand = (args: PaperhandArgs): Chai.AsyncAssertion => {
    if (args.revertString) {
        return expect(args.fix.contract.connect(args.account).paperhand(args.ethAmount)).to.be.revertedWith(args.revertString);
    }

    const earned = js_earnings(args.fix, args.account.address);
    args.fix.js_users[args.account.address].debt = earned;

    const debt = js_toEarningsFromEpsX128(args.ethAmount, args.fix.js_epsX128);
    const debtTooHigh = debt.gt(args.fix.js_users[args.account.address].debt);
    args.fix.js_users[args.account.address].shares = args.fix.js_users[args.account.address].shares.sub(args.ethAmount);
    args.fix.js_users[args.account.address].debt = debtTooHigh ? ETH_ZERO : args.fix.js_users[args.account.address].debt.sub(debt);
    args.fix.js_shares = args.fix.js_shares.sub(args.ethAmount);

    const valueChanged = args.ethAmount.add(earned);

    if (args.changeEtherBalance) {
        return expect(async () => await args.fix.contract.connect(args.account).paperhand(args.ethAmount)).to.changeEtherBalances(
            [args.account, args.fix.contract],
            [valueChanged, valueChanged.mul(-1)],
        );
    }

    return expect(args.fix.contract.connect(args.account).paperhand(args.ethAmount))
        .and.to.emit(args.fix.contract, 'EarningsRealized')
        .withArgs(args.account.address, earned)
        .and.to.emit(args.fix.contract, 'SharesDecrease')
        .withArgs(
            args.account.address,
            args.ethAmount,
            // debt,
            args.fix.js_shares,
            args.fix.js_users[args.account.address].shares,
            args.fix.js_users[args.account.address].debt,
        );
};
type PaperhandAllArgs = {
    fix: StakeableTestFixture;
    account: SignerWithAddress;
    revertString?: string;
    changeEtherBalance?: boolean;
};

const paperhandAll = (args: PaperhandAllArgs): Chai.AsyncAssertion => {
    return paperhand({ ...args, ethAmount: args.fix.js_users[args.account.address].shares });
};
