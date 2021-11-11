import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { waffle } from 'hardhat';
import { expect } from 'chai';

import { NamedAccounts } from '../hardhat.config';

import { AuctionableTestFixture, auctionableTestFixture } from './fixtures/AuctionableTest.fix';
import { toEth, ETH_ZERO, ETH_ONE } from './shared/conversion';
import { prepareAccounts } from './shared';
import { advanceBlockTo } from './shared/mining';

const STARTS_WITH = 'data:application/json;base64,';
const STARTS_WITH_2 = 'data:image/svg+xml;base64,';

const createFixtureLoader = waffle.createFixtureLoader;

let loadFixture: ReturnType<typeof createFixtureLoader>;
let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let fix: AuctionableTestFixture;

const refresh = async () => {
    accounts = await prepareAccounts();
    loadFixture = createFixtureLoader();
    fix = await loadFixture(auctionableTestFixture);
};

describe('constants', async function () {
    beforeEach(async () => {
        await refresh();
    });

    it('interval is correct', async function () {
        const res = await fix.contract.interval();
        expect(res).to.equal(fix.args.interval);
    });
    it('floor is correct', async function () {
        const res = await fix.contract.test__floor();
        expect(res).to.equal(fix.args.floor);
    });

    it('newPercent is correct', async function () {
        const res = await fix.contract.test__newIncrease();
        expect(res).to.equal(fix.args.newPercent);
    });
});

describe('uint tests', async function () {
    beforeEach(async () => {
        await refresh();
    });

    // describe('_initRound', async function () {
    //     // it('blockhash is zero before call', async function () {
    //     //     const res = await fix.contract.savedBlockHashes(0);
    //     //     expect(res).to.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    //     // });

    //     // it('blockhash is set after call', async function () {
    //     //     await fix.contract.test__initRound(0, toEth('1'), ETH_ZERO);
    //     //     const res = await fix.contract.savedBlockHashes(0);
    //     //     expect(res).to.not.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    //     // });

    //     it('reverts if amount < floor', async function () {
    //         await expect(fix.contract.test__initRound(0, fix.args.floor.sub(toEth('.0001')), ETH_ZERO)).to.be.revertedWith('AUC:INIT:0');
    //     });

    //     it('reverts if amount = floor', async function () {
    //         await expect(fix.contract.test__initRound(0, fix.args.floor, ETH_ZERO)).to.be.revertedWith('AUC:INIT:0');
    //     });

    //     it('reverts if amount = 0', async function () {
    //         await expect(fix.contract.test__initRound(0, ETH_ZERO, ETH_ZERO)).to.be.revertedWith('AUC:INIT:0');
    //     });

    //     it('does not revert if amount > floor', async function () {
    //         await expect(fix.contract.test__initRound(0, fix.args.floor.add(toEth('.0001')), ETH_ZERO)).to.not.be.reverted;
    //     });

    //     it('does not set blockhash if prevHighestBid is not 0', async function () {
    //         await fix.contract.test__initRound(0, fix.args.floor.add(toEth('.0001')), ETH_ONE);
    //         const res = await fix.contract.savedBlockHashes(0);
    //         expect(res).to.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    //     });

    //     it('set blockhash if prevHighestBid is 0', async function () {
    //         await fix.contract.test__initRound(0, fix.args.floor.add(toEth('.0001')), ETH_ZERO);
    //         const res = await fix.contract.savedBlockHashes(0);
    //         expect(res).to.not.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    //     });

    //     it('emits RoundInit event if initialized', async function () {
    //         await expect(fix.contract.connect(accounts.frank).test__initRound(0, ETH_ONE, ETH_ZERO))
    //             .to.emit(fix.contract, 'RoundInit')
    //             .withArgs(0, accounts.frank.address, ETH_ONE);
    //     });

    //     it('does not emit emits RoundInit if prevHighestBid is not 0', async function () {
    //         await expect(fix.contract.test__initRound(0, ETH_ONE, 1)).to.not.emit(fix.contract, 'RoundInit');
    //     });
    // });

    describe('_bid', async function () {
        // it('calls on _initRound', async function () {
        //     await expect(fix.contract.test__placeBid(accounts.frank.address, fix.args.floor.sub(toEth('0')), 0)).to.be.revertedWith('AUC:INIT:0');
        // });
        // it('calls _requireNewBid', async function () {
        //     await fix.contract.test__placeBid(accounts.frank.address, fix.args.floor.add(toEth('.0001')), 0);
        //     await expect(fix.contract.test__placeBid(accounts.charile.address, toEth('.0001'), 0)).to.be.revertedWith('AUC:REQNB:0');
        // });
        // it('calls _requireAddToBid', async function () {
        //     await fix.contract.test__placeBid(accounts.frank.address, fix.args.floor.add(toEth('.0001')), 0);
        //     await expect(fix.contract.test__placeBid(accounts.frank.address, toEth('.0001'), 0)).to.be.revertedWith('AUC:REQATB:0');
        // });

        it('increases total bids amount by amount', async function () {
            const amount = fix.args.floor.add(toEth('.0001'));
            const before = await fix.contract.rig__rounds(0);
            await fix.contract.test__placeBid(accounts.frank.address, amount, 0);
            const after = await fix.contract.rig__rounds(0);
            const diff = after.top.amount.sub(before.top.amount);
            expect(diff).to.equal(amount);
        });

        it('sets user bid as highest bid', async function () {
            const amount = fix.args.floor.add(toEth('.0001'));
            await fix.contract.test__placeBid(accounts.frank.address, amount, 0);
            const after = await fix.contract.rig__rounds(0);
            expect(after.top.account).to.equal(accounts.frank.address);
        });

        it('increases user bid by amount', async function () {
            const amount = fix.args.floor.add(toEth('.0001'));
            const before = await fix.contract.rig__bids(0, accounts.frank.address);
            await fix.contract.test__placeBid(accounts.frank.address, amount, 0);
            const after = await fix.contract.rig__bids(0, accounts.frank.address);
            const diff = after.amount.sub(before.amount);
            expect(diff).to.equal(amount);
        });

        it('calls on _onHighestBidIncrease', async function () {
            const amount = fix.args.floor.add(1);
            const before = await fix.contract.rig__getHighestBid(0);
            await fix.contract.test__placeBid(accounts.frank.address, amount, 0);
            const after = await fix.contract.rig__getHighestBid(0);
            const diff = after.sub(before);
            expect(diff).to.equal(amount);
        });

        it('emits BidPlaced event', async function () {
            const amount = fix.args.floor.add(1);
            await expect(fix.contract.test__placeBid(accounts.frank.address, amount, 0))
                .to.emit(fix.contract, 'BidPlaced')
                .withArgs(0, accounts.frank.address, amount, amount);
        });
    });

    describe('bid', async function () {
        it('hits _biddable modifier', async function () {
            await expect(fix.contract.connect(accounts.frank).placeBid(0)).to.be.revertedWith('AUC:MSG0:0');
        });
        it('calls _bid', async function () {
            await expect(fix.contract.connect(accounts.frank).placeBid(0, { value: fix.args.floor })).to.be.revertedWith('AUC:INIT:0');
        });

        it('message sender is passed as user', async function () {
            const account = accounts.frank;
            await fix.contract.connect(account).placeBid(0, { value: fix.args.floor.add(1) });
            const after = await fix.contract.rig__rounds(0);
            expect(after.top.account).to.equal(account.address);
        });
        it('msg.value is passed as amount', async function () {
            const amount = fix.args.floor.add(1);
            await fix.contract.connect(accounts.frank).placeBid(0, { value: amount });
            const after = await fix.contract.rig__rounds(0);
            expect(after.top.amount).to.equal(amount);
        });
        it('epoch is passed correctly', async function () {
            await expect(fix.contract.connect(accounts.frank).placeBid(0, { value: fix.args.floor.add(1) })).to.not.be.revertedWith(
                'EPO:VCE:0',
            );
        });

        it('reverts on reentry', async function () {});
    });

    // describe('_onWinnerClaim', async function () {
    //     it('is successfully overridden by implementer', async function () {
    //         const amount = fix.args.floor.add(1);
    //         const before = await fix.contract.rig__getWinnerHasClaimed(0);
    //         await fix.contract.test__onWinnerClaim(0);
    //         const after = await fix.contract.rig__getWinnerHasClaimed(0);
    //         expect(before).to.equal(false);
    //         expect(after).to.equal(true);
    //     });
    // });

    // describe('_onHighestBidIncrease', async function () {
    //     it('is successfully overridden by implementer', async function () {
    //         const amount = fix.args.floor.add(1);
    //         const before = await fix.contract.rig__getHighestBid(0);
    //         await fix.contract.test__onHighestBidIncrease(0, amount);
    //         const after = await fix.contract.rig__getHighestBid(0);
    //         expect(before).to.equal('0');
    //         expect(after).to.equal(amount);
    //     });
    // });

    // describe('_claimableChecks', async function () {
    //     it('calls _requireUnclaimed', async function () {
    //         await fix.contract.rig__setUserRoundAsClaimed(0, accounts.frank.address);
    //         await expect(fix.contract.connect(accounts.frank).test__claimableChecks(0)).to.be.revertedWith('AUC:REQUNC:0');
    //     });
    //     it('calls _requireParticipent', async function () {
    //         await expect(fix.contract.connect(accounts.frank).test__claimableChecks(0)).to.be.revertedWith('AUC:REQPART:0');
    //     });
    //     it('calls _requireEpochIsOver', async function () {
    //         await fix.contract.rig__setUserRoundAmount(0, accounts.frank.address, 1);
    //         await expect(fix.contract.connect(accounts.frank).test__claimableChecks(0)).to.be.revertedWith('EPO:VEIO:0');
    //     });
    // });

    describe('_claim', async function () {
        it('sets users bid to claimed', async function () {
            const account = accounts.frank;
            const amount = ETH_ONE;
            const epoch = 0;
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            const before = await fix.contract.rig__bids(epoch, account.address);
            await fix.contract.test__claim(epoch, account.address);
            const after = await fix.contract.rig__bids(epoch, accounts.frank.address);
            expect(before.claimed).to.equal(false);
            expect(after.claimed).to.equal(true);
        });

        it('calls _onWinnerClaim for winner', async function () {
            const account = accounts.frank;
            const amount = ETH_ONE;
            const epoch = 0;
            const before = await fix.contract.rig__getWinnerHasClaimed(epoch);
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            await fix.contract.rig__setRoundHighestBid(epoch, account.address, amount);
            await fix.contract.test__claim(epoch, account.address);
            const after = await fix.contract.rig__getWinnerHasClaimed(epoch);
            expect(before).to.equal(false);
            expect(after).to.equal(true);
        });
        it('does not call _onWinnerClaim for loser', async function () {
            const account = accounts.frank;
            const amount = ETH_ONE;
            const epoch = 0;
            const before = await fix.contract.rig__getWinnerHasClaimed(epoch);
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            await fix.contract.test__claim(epoch, account.address);
            const after = await fix.contract.rig__getWinnerHasClaimed(epoch);
            expect(before).to.equal(false);
            expect(after).to.equal(false);
        });

        it('sends value to a loser', async function () {
            const account = accounts.frank;
            const amount = ETH_ONE;
            const epoch = 0;
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            await expect(async () => {
                return await fix.contract.test__claim(epoch, account.address);
            }).to.changeEtherBalances([fix.contract, account], [amount.mul(-1), amount]);
        });

        it('does not send value to winner', async function () {
            const account = accounts.frank;
            const amount = ETH_ONE;
            const epoch = 0;
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            await fix.contract.rig__setRoundHighestBid(epoch, account.address, amount);
            await expect(async () => {
                return await fix.contract.test__claim(epoch, account.address);
            }).to.changeEtherBalances([account, fix.contract], [ETH_ZERO, ETH_ZERO]);
        });

        it('emits NormalClaim event for loser', async function () {
            const account = accounts.frank;
            const amount = ETH_ONE;
            const epoch = 0;
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            await expect(fix.contract.test__claim(epoch, account.address))
                .to.emit(fix.contract, 'NormalClaim')
                .withArgs(epoch, account.address, amount)
                .and.to.not.emit(fix.contract, 'WinningClaim');
        });

        it('emits WinningClaim event for winner', async function () {
            const account = accounts.frank;
            const amount = ETH_ONE;
            const epoch = 0;
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            await fix.contract.rig__setRoundHighestBid(epoch, account.address, amount);
            await expect(fix.contract.test__claim(epoch, account.address))
                .to.emit(fix.contract, 'WinningClaim')
                .withArgs(epoch, account.address, amount)
                .and.to.not.emit(fix.contract, 'NormalClaim');
        });
    });

    describe('claim', async function () {
        it('hits _claimable modifier', async function () {
            await expect(fix.contract.connect(accounts.frank).claim(0)).to.be.revertedWith('AUC:REQPART:0');
        });
        it('calls _claim', async function () {
            const account = accounts.frank;
            const amount = ETH_ONE;
            const epoch = 0;
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            await advanceBlockTo(fix.blockOffset.add(fix.args.interval + 1));
            await expect(fix.contract.connect(accounts.frank).claim(epoch))
                .to.emit(fix.contract, 'NormalClaim')
                .withArgs(epoch, account.address, amount);
        });

        it('message sender is passed as user & epoch is correct', async function () {
            const account = accounts.frank;
            const epoch = 0;
            const amount = ETH_ONE;
            await fix.contract.fallback({ value: amount });
            await fix.contract.rig__setUserRoundAmount(epoch, account.address, amount);
            await advanceBlockTo(fix.blockOffset.add(fix.args.interval + 1));
            const before = await fix.contract.rig__bids(epoch, account.address);
            await fix.contract.connect(account).claim(epoch);
            const after = await fix.contract.rig__bids(epoch, account.address);
            expect(before.claimed).to.equal(false);
            expect(after.claimed).to.equal(true);
        });
    });

    describe('simulation 0', async function () {
        before('create fix loader', async function () {
            await refresh();
        });

        it('dennis cannot place bid below floor', async function () {
            await fix.bid({
                fix,
                account: accounts.dennis,
                epoch: 0,
                amount: toEth('.02'),
                revertString: 'AUC:INIT:0',
            });
        });

        it('place first bid', async function () {
            await fix.bid({
                fix,
                account: accounts.dennis,
                epoch: 0,
                amount: toEth('1'),
            });
        });

        it('mac cannot place inferior bid', async function () {
            await fix.bid({
                fix,
                account: accounts.mac,
                epoch: 0,
                amount: toEth('.9'),
                revertString: 'AUC:REQNB:0',
            });
        });

        it('mac cannot place equal bid', async function () {
            await fix.bid({
                fix,
                account: accounts.mac,
                epoch: 0,
                amount: toEth('1'),
                revertString: 'AUC:REQNB:0',
            });
        });

        it('mac cannot place bid 10% higher', async function () {
            await fix.bid({
                fix,
                account: accounts.mac,
                epoch: 0,
                amount: toEth('1.0001'),
                revertString: 'AUC:REQNB:0',
            });
        });

        it('dee takes over', async function () {
            await fix.bid({ fix, account: accounts.dee, epoch: 0, amount: toEth('9') });
        });
        it('charlie wants a piece of pie', async function () {
            await fix.bid({ fix, account: accounts.charile, epoch: 0, amount: toEth('12') });
        });
        it('dennis reclaims his slice', async function () {
            await fix.bid({ fix, account: accounts.dennis, epoch: 0, amount: toEth('15') });
        });
        it('dee kicks dennis in the man parts', async function () {
            await fix.bid({ fix, account: accounts.dee, epoch: 0, amount: toEth('10') });
        });
        it('charlie kicks dee in the lady parts', async function () {
            await fix.bid({ fix, account: accounts.charile, epoch: 0, amount: toEth('10') });
        });

        it('frank bets the house', async function () {
            await fix.bid({ fix, account: accounts.frank, epoch: 0, amount: toEth('50') });
        });

        it('frank claims too early', async function () {
            await advanceBlockTo(fix.blockOffset.add(245));
            await fix.claim({ fix, account: accounts.frank, epoch: 0, revertString: 'EPO:VEIO:0' });
        });

        it('dee claims too early', async function () {
            await fix.claim({ fix, account: accounts.dee, epoch: 0, revertString: 'EPO:VEIO:0' });
        });

        it('frank claims on time', async function () {
            await advanceBlockTo(fix.blockOffset.add(265));
            await fix.claim({ fix, account: accounts.frank, epoch: 0 });
        });

        it('dennis claims back his bounty', async function () {
            await fix.claim({ fix, account: accounts.dennis, epoch: 0 });
        });
        it('mac claims back his bounty', async function () {
            await fix.claim({ fix, account: accounts.mac, epoch: 0, revertString: 'AUC:REQPART:0' });
        });
        it('dee takews some home', async function () {
            await fix.claim({ fix, account: accounts.dee, epoch: 0 });
        });
        it('charlie wants it all back', async function () {
            await fix.claim({ fix, account: accounts.charile, epoch: 0 });
        });
    });
});
