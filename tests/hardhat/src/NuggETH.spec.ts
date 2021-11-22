import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers, waffle } from 'hardhat';
import { BigNumber } from 'ethers';

import { NamedAccounts } from '../../../hardhat.config';

import { Mining } from '../lib/shared/mining';
import { prepareAccounts } from '../lib/shared';
import { ETH_ONE, toEth, BINARY_128, ETH_TRILLION, fromEth } from '../lib/shared/conversion';
import { NuggFatherFix, NuggFatherFixture } from '../lib/fixtures/NuggFather.fix';
import { getHRE } from '../lib/shared/deployment';
import { Address } from 'ethereumjs-util';
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
        const hre = getHRE();

        console.log(hre.middleware);
    });

    describe('internal', async () => {
        it('should revert if shares = 0', async () => {
            await fix.xnugg.connect(accounts.dee).mint({ value: toEth('5') });
            const res = await fix.xnugg.balanceOf(accounts.dee.address);
            await fix.nuggswap.connect(accounts.mac).rightToMint(fix.mockERC721Mintable.address);

            // await fix.xnugg.connect(accounts.frank).fallback({ value: toEth('5') });
            console.log(fix.toNuggSwapTokenId(0)._hex);
            await fix.nuggswap.connect(accounts.mac).submitOfferSimple(fix.mockERC721Mintable.address, { value: toEth('2.000') });

            await fix.nuggswap
                .connect(accounts.dee)
                .submitOffer(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 0, { value: toEth('3.000') });

            // console.log(res.toString());

            await Mining.advanceBlockTo(50);
            await fix.nuggswap.connect(accounts.dee).submitClaim(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 0);
            // await fix.mockERC721Mintable.connect(accounts.dee).approve(fix.nuggswap.address, 0);
            await fix.nuggswap.connect(accounts.mac).submitClaim(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 0);

            await fix.nuggswap
                .connect(accounts.dee)
                .submitSwap(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 1, 5, toEth('.02000'), false);

            const positionDee0 = await fix.xnugg.balanceOf(accounts.dee.address);
            const positionMac0 = await fix.xnugg.balanceOf(accounts.mac.address);
            const ownershipMac0 = await fix.xnugg.ownershipOf(accounts.mac.address);
            const ownershipDee0 = await fix.xnugg.ownershipOf(accounts.dee.address);
            const positionDennis0 = await fix.xnugg.balanceOf(accounts.dennis.address);
            const positionFrank0 = await fix.xnugg.balanceOf(accounts.frank.address);
            const ownershipFrank0 = await fix.xnugg.ownershipOf(accounts.frank.address);
            const ownershipDennis0 = await fix.xnugg.ownershipOf(accounts.dennis.address);
            const positionCharlie0 = await fix.xnugg.balanceOf(accounts.charile.address);
            const ownershipCharlie0 = await fix.xnugg.ownershipOf(accounts.charile.address);
            await fix.xnugg.connect(accounts.mac).mint({ value: toEth('40') });
            await fix.xnugg.connect(accounts.charile).mint({ value: toEth('1.696969696969696') });
            await fix.xnugg.connect(accounts.mac).transfer(accounts.frank.address, toEth('1.69'));
            await fix.xnugg.connect(accounts.mac).transfer(accounts.frank.address, toEth('1.566'));

            // const res2 = await fix.xnugg.balanceOf(accounts.charile.address);
            // console.log(res2.toString());

            const positionDee1 = await fix.xnugg.balanceOf(accounts.dee.address);
            const positionMac1 = await fix.xnugg.balanceOf(accounts.mac.address);
            const ownershipMac1 = await fix.xnugg.ownershipOf(accounts.mac.address);
            const ownershipDee1 = await fix.xnugg.ownershipOf(accounts.dee.address);
            const positionDennis1 = await fix.xnugg.balanceOf(accounts.dennis.address);
            const positionFrank1 = await fix.xnugg.balanceOf(accounts.frank.address);
            const ownershipFrank1 = await fix.xnugg.ownershipOf(accounts.frank.address);
            const ownershipDennis1 = await fix.xnugg.ownershipOf(accounts.dennis.address);
            const positionCharlie1 = await fix.xnugg.balanceOf(accounts.charile.address);
            const ownershipCharlie1 = await fix.xnugg.ownershipOf(accounts.charile.address);

            await fix.xnugg.connect(accounts.dennis).mint({ value: toEth('13') });
            await fix.xnugg.connect(accounts.frank).mint({ value: toEth('1') });

            await fix.nuggswap
                .connect(accounts.frank)
                .submitOffer(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 1, { value: toEth('20.000') });
            await fix.nuggswap
                .connect(accounts.dennis)
                .submitOffer(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 1, { value: toEth('22.000') });
            await fix.nuggswap
                .connect(accounts.frank)
                .submitOffer(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 1, { value: toEth('3.000') });
            await fix.nuggswap
                .connect(accounts.dennis)
                .submitOffer(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 1, { value: toEth('2.000') });
            await fix.nuggswap
                .connect(accounts.dennis)
                .submitOffer(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 1, { value: toEth('2.000') });
            await fix.nuggswap
                .connect(accounts.frank)
                .submitOffer(fix.mockERC721Mintable.address, fix.toNuggSwapTokenId(0), 1, { value: toEth('33.000') });

            await fix.xnugg.connect(accounts.frank).mint({ value: toEth('1') });
            // console.log('NOPE');

            // console.log('yououououoi');
            const res99 = await fix.nuggswap['getSwap(address,uint256,uint256)'](fix.mockERC721Mintable.address, 0, 0);

            // console.log({ res99 });

            const positionDee2 = await fix.xnugg.balanceOf(accounts.dee.address);
            const positionMac2 = await fix.xnugg.balanceOf(accounts.mac.address);
            const ownershipMac2 = await fix.xnugg.ownershipOf(accounts.mac.address);
            const ownershipDee2 = await fix.xnugg.ownershipOf(accounts.dee.address);
            const positionDennis2 = await fix.xnugg.balanceOf(accounts.dennis.address);
            const positionFrank2 = await fix.xnugg.balanceOf(accounts.frank.address);
            const ownershipFrank2 = await fix.xnugg.ownershipOf(accounts.frank.address);
            const ownershipDennis2 = await fix.xnugg.ownershipOf(accounts.dennis.address);
            const positionCharlie2 = await fix.xnugg.balanceOf(accounts.charile.address);
            const ownershipCharlie2 = await fix.xnugg.ownershipOf(accounts.charile.address);
            const res3 = await fix.xnugg.balanceOf(accounts.charile.address);
            console.log(res3.toString());

            // await fix.seller.connect(accounts.frank).submitOffer(BigNumber.from(1), toEth('2'), 0, { value: toEth('2.000') });
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('1.696969696970000'));
            await fix.xnugg.connect(accounts.dennis).burn(toEth('5'));
            // await fix.seller.connect(accounts.frank).submitOffer(BigNumber.from(1), toEth('2'), 0, { value: toEth('2.000') });
            await Mining.advanceBlockTo(250);
            await Mining.advanceBlock();
            // const epoch = await fix.nuggswap.currentEpochId();

            // console.log({ epoch }, fix.hre.ethers.provider.blockNumber);

            await fix.nuggswap.connect(accounts.frank).rightToMint(fix.mockERC721Mintable.address);

            await Mining.advanceBlockTo(350);

            await fix.nuggswap.connect(accounts.frank).submitClaimSimple(fix.mockERC721Mintable.address, 10);

            // await fix.xnugg.connect(accounts.dee).burn(toEth('41'));

            // await Mining.advanceBlockTo(100);
            // await fix.seller.connect(accounts.dee).submitClaimSale(1, 2);

            const res4 = await fix.xnugg.balanceOf(accounts.dee.address);
            const positionDee3 = await fix.xnugg.balanceOf(accounts.dee.address);
            const ownershipMac3 = await fix.xnugg.ownershipOf(accounts.mac.address);
            const ownershipDee3 = await fix.xnugg.ownershipOf(accounts.dee.address);
            const positionMac3 = await fix.xnugg.balanceOf(accounts.mac.address);
            const positionDennis3 = await fix.xnugg.balanceOf(accounts.dennis.address);
            const positionFrank3 = await fix.xnugg.balanceOf(accounts.frank.address);
            const ownershipFrank3 = await fix.xnugg.ownershipOf(accounts.frank.address);
            const ownershipDennis3 = await fix.xnugg.ownershipOf(accounts.dennis.address);
            const positionCharlie3 = await fix.xnugg.balanceOf(accounts.charile.address);
            const ownershipCharlie3 = await fix.xnugg.ownershipOf(accounts.charile.address);

            console.log('positionDee0: ', fromEth(positionDee0));
            console.log('positionDee1: ', fromEth(positionDee1));
            console.log('positionDee2: ', fromEth(positionDee2));
            console.log('positionDee3: ', fromEth(positionDee3));
            console.log('ownershipDee0: ', fromEth(ownershipDee0.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipDee1: ', fromEth(ownershipDee1.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipDee2: ', fromEth(ownershipDee2.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipDee3: ', fromEth(ownershipDee3.mul(ETH_ONE).div(BINARY_128)));

            console.log('positionMac0: ', fromEth(positionMac0));
            console.log('positionMac1: ', fromEth(positionMac1));
            console.log('positionMac2: ', fromEth(positionMac2));
            console.log('positionMac3: ', fromEth(positionMac3));
            console.log('ownershipMac0: ', fromEth(ownershipMac0.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipMac1: ', fromEth(ownershipMac1.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipMac2: ', fromEth(ownershipMac2.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipMac3: ', fromEth(ownershipMac3.mul(ETH_ONE).div(BINARY_128)));

            console.log('positionDennis0: ', fromEth(positionDennis0));
            console.log('positionDennis1: ', fromEth(positionDennis1));
            console.log('positionDennis2: ', fromEth(positionDennis2));
            console.log('positionDennis3: ', fromEth(positionDennis3));
            console.log('ownershipDennis0: ', fromEth(ownershipDennis0.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipDennis1: ', fromEth(ownershipDennis1.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipDennis2: ', fromEth(ownershipDennis2.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipDennis3: ', fromEth(ownershipDennis3.mul(ETH_ONE).div(BINARY_128)));

            console.log('positionFrank0: ', fromEth(positionFrank0));
            console.log('positionFrank1: ', fromEth(positionFrank1));
            console.log('positionFrank2: ', fromEth(positionFrank2));
            console.log('positionFrank3: ', fromEth(positionFrank3));
            console.log('ownershipFrank0: ', fromEth(ownershipFrank0.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipFrank1: ', fromEth(ownershipFrank1.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipFrank2: ', fromEth(ownershipFrank2.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipFrank3: ', fromEth(ownershipFrank3.mul(ETH_ONE).div(BINARY_128)));

            console.log('positionCharlie0: ', fromEth(positionCharlie0));
            console.log('positionCharlie1: ', fromEth(positionCharlie1));
            console.log('positionCharlie2: ', fromEth(positionCharlie2));
            console.log('positionCharlie3: ', fromEth(positionCharlie3));
            console.log('ownershipCharlie0: ', fromEth(ownershipCharlie0.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipCharlie1: ', fromEth(ownershipCharlie1.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipCharlie2: ', fromEth(ownershipCharlie2.mul(ETH_ONE).div(BINARY_128)));
            console.log('ownershipCharlie3: ', fromEth(ownershipCharlie3.mul(ETH_ONE).div(BINARY_128)));

            const ownershipCharlie = ownershipCharlie3;
            const ownershipFrank = ownershipFrank3;
            const ownershipDee = ownershipDee3;
            const ownershipMac = ownershipMac3;
            const ownershipDennis = ownershipDennis3;

            const positionCharlie = positionCharlie3;
            const positionFrank = positionFrank3;
            const positionDee = positionDee3;
            const positionMac = positionMac3;
            const positionDennis = positionDennis3;

            console.log(
                '(expe) supply:',
                fromEth(positionCharlie.add(positionFrank).add(positionDee).add(positionMac).add(positionDennis)),
            );
            console.log('(real) supply:', fromEth(await fix.xnugg.totalSupply()));
            console.log('(tummy) supply:', fromEth((await fix.hre.ethers.provider.getBalance(fix.tummy)).sub(fix.tummyStartBal)));

            console.log(
                '(expe) owners:',
                fromEth(
                    ownershipCharlie
                        .add(ownershipFrank)
                        .add(ownershipDee)
                        .add(ownershipMac)
                        .add(ownershipDennis)
                        .mul(ETH_TRILLION)
                        .div(BINARY_128),
                ),
            );
            console.log('(real) owners:', fromEth(ETH_TRILLION));

            console.log('tokenURI', await fix.mockERC721Mintable['tokenURI(uint256)'](0));

            // await fix.xnugg.connect(accounts.dee).approve(fix.minter.address, toEth('40'));

            // // await fix.xnugg.connect(accounts.dee).approve(fix.minter.address, toEth('40'));

            // await fix.minter.connect(accounts.frank).submitOffer(BigNumber.from(0), toEth('20.0001'), 0, { value: toEth('20.0001') });
            // const res4 = await fix.xnugg.balanceOf(accounts.frank.address);
            // console.log(res4.toString());

            // await fix.weth.connect(accounts.frank).mint({ value: toEth('20') });
            // await fix.weth.connect(accounts.frank).approve(fix.relay.address, toEth('20'));
            // await fix.relay.connect(accounts.frank).mintWETH(toEth('20'));

            // // await fix.relay.connect(accounts.dee).mintWETH();
            // const res2 = await fix.xnugg.balanceOf(accounts.dee.address);
            // const res3 = await fix.xnugg.totalSupply();

            // await fix.xnugg.connect(accounts.mac).mint({ value: toEth('40') });
            // const res5 = await fix.xnugg.balanceOf(accounts.mac.address);
            // console.log(res5.toString());

            // let earnings = await fix.xnugg.earningsOf(accounts.dee.address);
            // let position = await fix.xnugg.positionOf(accounts.dee.address);
            // console.log({
            //     PRECOMPOUND: {
            //         calc: earnings.toString(),
            //         rOwned: position.rOwned.toString(),
            //     },
            // });

            // await fix.xnugg.connect(accounts.dee).compound();
            // let res6 = await fix.xnugg.balanceOf(accounts.dee.address);
            // console.log(res6.toString());

            // earnings = await fix.xnugg.earningsOf(accounts.dee.address);
            // position = await fix.xnugg.positionOf(accounts.dee.address);
            // console.log({
            //     AFTERCOMPOUND: {
            //         calc: earnings.toString(),
            //         rOwned: position.rOwned.toString(),
            //         sudo: MockStakeMath.convertSharesToEarnings(
            //             {
            //                 epsX128: await fix.xnugg.epsX128(),
            //                 shares: await fix.xnugg.totalShares(),
            //             },
            //             earnings,
            //         ).toString(),
            //     },
            // });
            // await fix.xnugg.connect(accounts.dee).burn(toEth('1'));
            // const res9 = await fix.xnugg.balanceOf(accounts.dee.address);
            // console.log('test burn', res9.toString());

            // console.log(res2.toString(), res3.toString());

            // await Mining.advanceBlockTo(BigNumber.from(fix.blockOffset).add(100));

            // await fix.minter.connect(accounts.frank).submitClaim(0, 0);

            // await fix.mockERC721Mintable.connect(accounts.frank).approve(fix.seller.address, 0);

            // // const res7 = await fix.minter.getOffer(0, accounts.frank.address);
            // await fix.seller.connect(accounts.frank).startSale(0, 10, toEth('1'));

            // await fix.seller.connect(accounts.dee).submitOffer(0, toEth('3'), 0, {
            //     value: toEth('3'),
            // });

            // await Mining.advanceBlockTo(BigNumber.fromawait  getHRE().ethers.provider.getBlockNumber()).add(15));

            // await fix.seller.connect(accounts.dee).submitClaim(0, 0);

            // await fix.seller.connect(accounts.frank).submitClaimSale(0, 0);

            // await fix.mockERC721Mintable.connect(accounts.dee).approve(fix.seller.address, 0);

            // // const res7 = await fix.minter.getOffer(0, accounts.frank.address);
            // await fix.seller.connect(accounts.dee).startSale(0, 10, toEth('1'));

            // await fix.seller.connect(accounts.mac).submitOffer(1, toEth('3'), 0, {
            //     value: toEth('3'),
            // });

            // await Mining.advanceBlockTo(BigNumber.fromawait  getHRE().ethers.provider.getBlockNumber()).add(15));

            // await fix.seller.connect(accounts.mac).submitClaim(1, 0);

            // await fix.seller.connect(accounts.dee).submitClaimSale(1, 0);

            // await fix.xnugg.connect(accounts.dee).submitClaimSale(1, 0);
            // await fix.mockERC721Mintable.connect(accounts.mac).transferFrom(accounts.mac.address, accounts.dee.address, 0);

            // await fix.auction.connect(accounts.dee).movePendingReward();
            // // const res6 = await fix.xnugg.balanceOf(accounts.dee.address);
            // // console.log(res6.toString());
        });
    });
});
