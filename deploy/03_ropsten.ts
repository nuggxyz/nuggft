import { Contract, ethers } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { NamedAccounts } from '../hardhat.config';
import { toEth, toGwei } from '../tests/hardhat/lib/shared/conversion';
import { IDotnuggV1, IDotnuggV1__factory, NuggftV1 } from '../typechain';
// import { NuggftV1 } from '../typechain';
// import { XNUGG as xNUGG } from '../typechain/XNUGG';
// import { NuggftV1 } from '../typechain/NuggftV1.d';
// import { fromEth, toEth } from '../tests/hardhat/lib/shared/conversion';
// import { NuggSwap } from '../typechain';

const deployment = async (hre: HardhatRuntimeEnvironment) => {
    const chainID = await hre.getChainId();
    // if (chainID === '3' ) {
    const accounts = (await hre.getNamedAccounts()) as Record<keyof typeof NamedAccounts, string>;
    const eoaDeployer = await hre.ethers.getNamedSigner('deployer');
    hre.deployments.log('EOA deployer: ', accounts.deployer);
    let dotnuggV1Address: string;

    console.log('frank', accounts.frank);

    console.error();

    if (chainID === '31337') {
        const dotnuggV1Deployment = await hre.deployments.deploy('MockDotnuggV1', {
            from: eoaDeployer.address,
            log: true,
            args: [],
            // deterministicDeployment: salts[2],
        });

        dotnuggV1Address = dotnuggV1Deployment.address;
    } else if (chainID === '3') {
        dotnuggV1Address = '0xd11F88Ae7C7A35a932b23c1E684bC02747425bF9';
    }

    const dotnuggV1 = new Contract(dotnuggV1Address, IDotnuggV1__factory.abi) as IDotnuggV1;

    hre.deployments.log('using DotnuggV1 at address: ', dotnuggV1.address);

    const nuggftDeployment = await hre.deployments.deploy('NuggftV1', {
        from: eoaDeployer.address,
        log: true,
        args: [dotnuggV1.address],
        gasPrice: toGwei('20'),

        // deterministicDeployment: salts[2],
    });
    hre.deployments.log('NuggftV1 Deployment Complete at address: ', nuggftDeployment.address);

    const nuggft = await hre.ethers.getContractAt<NuggftV1>('NuggftV1', nuggftDeployment.address);

    const sendFiles = async (feature: number) => {
        return (
            await nuggft
                .connect(eoaDeployer)
                .dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[feature], feature, { gasPrice: toGwei('20') })
                .then((data) => {
                    hre.deployments.log(`tx for feature ${feature} sent... waiting to be mined... `, data.hash);
                    return data;
                })
        )
            .wait()
            .then((data) => {
                hre.deployments.log(`tx for feature ${feature} mined.`);
            });
    };

    let txcount = 0;

    const sendTx = async (tx: Promise<ethers.ContractTransaction>) => {
        const c = txcount++;
        return (
            await tx.then((data) => {
                hre.deployments.log(`tx${c} sent.. waiting to be mined... `, data.hash);
                return data;
            })
        )
            .wait()
            .then((data) => {
                hre.deployments.log(`tx${c} mined in block `, data.blockNumber);
            });
    };

    // await sendFiles(0);
    // // 0x0272be2a172ebea775fd7ed68c32b0dc1032c55d;
    // await sendFiles(1);
    // await sendFiles(2);
    // await sendFiles(3);
    // await sendFiles(4);
    // await sendFiles(5);
    // await sendFiles(6);
    // await sendFiles(7);

    const activeEpoch = await nuggft.epoch();
    const minSharePrice = await nuggft.valueForDelegate(accounts.dee, activeEpoch);

    hre.deployments.log('active epoch is...', activeEpoch.toString());
    hre.deployments.log('minSharePrice is..', minSharePrice.toString());

    // await sendTx(
    //     nuggft.connect(await hre.ethers.getNamedSigner('deployer')).trustedMint(69, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', {
    //         value: await nuggft.minSharePrice(),
    //         gasPrice: toGwei('20'),
    //         gasLimit: 1000000,
    //     }),
    // );

    // await sendTx(
    //     nuggft.connect(await hre.ethers.getNamedSigner('dee')).delegate((await hre.ethers.getNamedSigner('dee')).address, activeEpoch, {
    //         value: (await nuggft.valueForDelegate(accounts.dee, activeEpoch)).nextSwapAmount,
    //         gasPrice: toGwei('5'),
    //         gasLimit: 1000000,
    //     }),
    // );
    for (let i = 3; i < 10; i++) {
        await Promise.all([
            sendTx(
                nuggft.connect(await hre.ethers.getNamedSigner('dee')).mint(i + 600, {
                    value: (await nuggft.minSharePrice()).add(toEth('.001')),
                    gasPrice: toGwei('5'),
                    gasLimit: 1000000,
                }),
            ),
            sendTx(
                nuggft.connect(await hre.ethers.getNamedSigner('frank')).mint(i + 1700, {
                    value: (await nuggft.minSharePrice()).add(toEth('.002')),
                    gasPrice: toGwei('5'),
                    gasLimit: 1000000,
                }),
            ),
            sendTx(
                nuggft
                    .connect(await hre.ethers.getNamedSigner('deployer'))
                    .trustedMint(i + 100, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', {
                        value: (await nuggft.minSharePrice()).add(toEth('.003')),
                        gasPrice: toGwei('5'),
                        gasLimit: 1000000,
                    }),
            ),
        ]);

        // await sendTx(
        //     nuggft.connect(await hre.ethers.getNamedSigner('deployer')).trustedMint(i + 200, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', {
        //         value: await nuggft.minSharePrice(),
        //         // gasLimit: 10000000,
        //         // gasPrice: toEth('0.0000006'),
        //     }),
        // );
        // await sendTx(
        //     nuggft.connect(await hre.ethers.getNamedSigner('dee')).delegate((await hre.ethers.getNamedSigner('dee')).address, activeEpoch, {
        //         value: (await nuggft.valueForDelegate(accounts.dee, activeEpoch)).nextSwapAmount,
        //         gasPrice: toEth('0.0000006'),
        //     }),
        // );
    }

    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .delegate(activeEpoch, { value: toEth('.00005'), gasPrice: toEth('0.0000006') }),
    // );

    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .mint(1169, { value: await nuggft.minSharePrice(), gasPrice: toEth('0.00000006') }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .mint(2169, { value: await nuggft.minSharePrice(), gasPrice: toEth('0.00000006') }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .mint(2179, { value: await nuggft.minSharePrice(), gasPrice: toEth('0.00000006') }),
    // );

    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .mint(1170, { value: await nuggft.minSharePrice(), gasPrice: toEth('0.00000006') }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .mint(2170, { value: await nuggft.minSharePrice(), gasPrice: toEth('0.00000006') }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .mint(2180, { value: await nuggft.minSharePrice(), gasPrice: toEth('0.00000006') }),
    // );

    // await sendTx(
    //     nuggft.connect(await hre.ethers.getNamedSigner('dee')).approve(nuggft.address, 2179, { gasPrice: toEth('0.00000006') }),
    // );
    // await sendTx(
    //     nuggft.connect(await hre.ethers.getNamedSigner('dee')).approve(nuggft.address, 1170, { gasPrice: toEth('0.00000006') }),
    // );
    // await sendTx(
    //     nuggft.connect(await hre.ethers.getNamedSigner('dee')).approve(nuggft.address, 2170, { gasPrice: toEth('0.00000006') }),
    // );
    // // await sendTx(nuggft.connect(await hre.ethers.getNamedSigner('dee')).approve(nuggft.address, 2080));

    // await sendTx(nuggft.connect(await hre.ethers.getNamedSigner('dee')).swap(2179, toEth('.69'), { gasPrice: toEth('0.00000006') }));
    // await sendTx(nuggft.connect(await hre.ethers.getNamedSigner('dee')).swap(1170, toEth('1.69'), { gasPrice: toEth('0.00000006') }));
    // await sendTx(nuggft.connect(await hre.ethers.getNamedSigner('dee')).loan(2170, { gasPrice: toEth('0.00000006') }));

    // await sendTx(nuggft.connect(await hre.ethers.getNamedSigner('dee')).swap(2070, toEth('2.69')));
    // await sendTx(nuggft.connect(await hre.ethers.getNamedSigner('dee')).swap(2080, toEth('3.69')));

    // await sendTx(nuggft.connect(eoaDeployer).setIsTrusted(accounts.dee, true));

    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .trustedMint(69, '0x4e503501c5dedcf0607d1e1272bb4b3c1204cc71', { value: await nuggft.minSharePrice() }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .trustedMint(169, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', { value: await nuggft.minSharePrice() }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .trustedMint(269, '0x4e503501c5dedcf0607d1e1272bb4b3c1204cc71', { value: await nuggft.minSharePrice() }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .trustedMint(369, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', { value: await nuggft.minSharePrice() }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .trustedMint(469, '0x4e503501c5dedcf0607d1e1272bb4b3c1204cc71', { value: await nuggft.minSharePrice() }),
    // );
    // await sendTx(
    //     nuggft
    //         .connect(await hre.ethers.getNamedSigner('dee'))
    //         .trustedMint(420, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', { value: await nuggft.minSharePrice() }),
    // );
};
export default deployment;

// hre.deployments.log('Dev depositing value into xNUGG... ');
// hre.deployments.log('Total supply before: ', fromEth(await xnugg.totalSupply()));
// const tx3 = await xnugg.connect(await hre.ethers.getNamedSigner('frank')).deposit({ value: toEth('200.255445554778') });
// hre.deployments.log('tx sent... waiting to be mined... ', tx0.hash);
// tx3.wait();
// hre.deployments.log('Total supply after: ', fromEth(await xnugg.totalSupply()));
// hre.deployments.log('Dev balance after:', fromEth(await xnugg.balanceOf(accounts.dev)));

// hre.deployments.log('Dee placing a bid... ');
// const tx4 = await auction.connect(await hre.ethers.getNamedSigner('dee')).placeBid(0, { value: toEth('100.876876875685') });
// hre.deployments.log('tx sent... waiting to be mined... ', tx.hash);
// await tx4.wait();
// hre.deployments.log('Total supply after: ', fromEth(await xnugg.totalSupply()));
// hre.deployments.log('Dev balance after:  ', fromEth(await xnugg.balanceOf(accounts.dev)));

// hre.deployments.log('Dee placing a bid... ');
// const tx2 = await auction.connect(await hre.ethers.getNamedSigner('mac')).placeBid(0, { value: toEth('450.876876875686') });
// hre.deployments.log('tx sent... waiting to be mined... ', tx.hash);
// await tx2.wait();
// hre.deployments.log('Total supply after: ', fromEth(await xnugg.totalSupply()));
// hre.deployments.log('Dev balance after:  ', fromEth(await xnugg.balanceOf(accounts.dev)));
// hre.deployments.log('Frank balance after:  ', fromEth(await xnugg.balanceOf(accounts.frank)));
// hre.deployments.log(
//     'Dev + Frank balance after:  ',
//     fromEth((await xnugg.balanceOf(accounts.dev)).add(await xnugg.balanceOf(accounts.frank))),
// );

// hre.deployments.log('isTrusted updated to ', accounts.dee);

// // await nuggft.connect(await hre.ethers.getNamedSigner('dee')).addToFile(hre.dotnugg.items.slice(25, 50).map((x) => x.hex));

// // await nuggft.connect(await hre.ethers.getNamedSigner('dee')).addToFile(hre.dotnugg.items.slice(50, 75).map((x) => x.hex));
// // await nuggft.connect(await hre.ethers.getNamedSigner('dee')).addToFile(hre.dotnugg.items.slice(75, 100).map((x) => x.hex));

// // // console.log(res);
// // await nuggft.connect(await hre.ethers.getNamedSigner('dee')).addToFile(hre.dotnugg.items.slice(0, 50).map((x) => x.hex));

// await nuggft.connect(await hre.ethers.getNamedSigner('dee')).delegate(0, { value: toEth('0.01') });

// const res = await nuggft.rawProcessURI(0);

// console.log(res);

// const fileDotnuggDeployment = await hre.deployments.deploy('SvgFileResolver', {
//     from: eoaDeployer,
//     log: true,
//     args: [],
//     // deterministicDeployment: salts[6],
// });

// const nuggswapDeployment = await hre.deployments.deploy('NuggSwap', {
//     from: eoaDeployer,
//     log: true,
//     args: [xnuggDeployement.address],
//     // deterministicDeployment: salts[4],
// });

// const nuggFTDeployement = await hre.deployments.deploy('NuggftV1', {
//     from: eoaDeployer,
//     log: true,
//     args: [xnuggDeployement.address, nuggswapDeployment.address, nuggswapDeployment.address, nuggswapDeployment.address],
//     // deterministicDeployment: salts[3],
// });

// hre.deployments.log('NuggftV1 Deployment Complete at address: ', nuggFTDeployement.address);
// hre.deployments.log('xNUGG Deployment Complete at address: ', xnuggDeployement.address);
// hre.deployments.log('NuggSwap Deployment Complete at address: ', nuggswapDeployment.address);
// hre.deployments.log('DefaultResolver Deployment Complete at address: ', defaultDeployment.address);
// // hre.deployments.log('DotNuggFileResolver Deployment Complete at address: ', fileDotnuggDeployment.address);
// hre.deployments.log('CompressedResolver Deployment Complete at address: ', compressedDeployment.address);

// const father = await hre.ethers.getContractAt<NuggFather>('NuggFather', fatherDeployment.address);
//
// const nuggft = await hre.ethers.getContractAt<NuggftV1>('NuggftV1', nuggFTDeployement.address);
// //

// const xnugg = await hre.ethers.getContractAt<xNUGG>('xNUGG', xnuggDeployement.address);
// //

// const default = await hre.ethers.getContractAt<DotNugg>('DotNugg', defaultDeployment.address);
// const nuggin = await hre.ethers.getContractAt<SvgFileResolver>('SvgFileResolver', fileDotnugg.address);
// const testNuggin = await hre.ethers.getContractAt<DotNuggFileResolver>('DotNuggFileResolver', compressedDeployment.address);

//

// const nuggswap = await hre.ethers.getContractAt<NuggSwap>('NuggSwap', nuggswapDeployment.address);
//

// const seller = await hre.ethers.getContractAt<Nugg>('Nugg', sellerDeployment.address);
//

// hre.deployments.log('Dev depositing value into xNUGG... ');
// hre.deployments.log('Total supply before: ', fromEth(await xnugg.totalSupply()));

// const tx0 = await xnugg.connect(await hre.ethers.getNamedSigner('dev')).deposit({ value: toEth('.001') });
// hre.deployments.log('tx sent... waiting to be mined... ', tx0.hash);
// await tx0.wait();
// hre.deployments.log('Total supply after: ', fromEth(await xnugg.totalSupply()));
// hre.deployments.log('Dev balance after:', fromEth(await xnugg.balanceOf(accounts.dev)));

// hre.deployments.log('Dee placing a bid... ');

// const tx = await nuggswap.connect(await hre.ethers.getNamedSigner('dee')).submitOffer(nuggft.address, 0, { value: toEth('.002') });
// hre.deployments.log('tx sent... waiting to be mined... ', tx.hash);
// await tx.wait();
// hre.deployments.log('Total supply after: ', fromEth(await xnugg.totalSupply()));
// hre.deployments.log('Dev balance after:  ', fromEth(await xnugg.balanceOf(accounts.dev)));

// // if (res) {
// var start = new Date();
// var hrstart = process.hrtime();

// hre.deployments.log('Getting pending token uri...');

// const uri = await nuggft['tokenURI(uint256)'](0);
// if (uri) {
//     var end = new Date().getTime() - start.getTime(),
//         hrend = process.hrtime(hrstart);

//     console.info('Execution time: %dms', end);
//     console.info('Execution time (hr): %ds %dms', hrend[0], hrend[1] / 1000000);
//     hre.deployments.log(uri);
//     // hre.deployments.log(DecodeDotNuggBase64ToPngBase64(DecodeBase64ToJSON(uri).image, 10));
// }
