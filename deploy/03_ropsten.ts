import { ethers } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { NamedAccounts } from '../hardhat.config';
import { XNUGG as xNUGG } from '../typechain/XNUGG';
import { NuggFT } from '../typechain/NuggFT.d';
import { fromEth, toEth } from '../tests/hardhat/lib/shared/conversion';
import { NuggSwap } from '../typechain';

const deployment = async (hre: HardhatRuntimeEnvironment) => {
    const chainID = await hre.getChainId();
    if (chainID === '3' || chainID === '31337') {
        const accounts = (await hre.getNamedAccounts()) as Record<keyof typeof NamedAccounts, string>;

        const eoaDeployer = accounts.deployer;
        hre.deployments.log('EOA deployer: ', accounts.deployer);
        // const args = new ethers.utils.AbiCoder().encode(
        //     ['bytes32', 'bytes32', 'bytes32', 'bytes32', 'bytes32', 'address'],
        //     [
        //         '0x0000000000000000000000000000000000000000000000000000000000201a14',
        //         '0x000000000000000000000000000000000000000000000000000000000056c2ef',
        //         '0x0000000000000000000000000000000000000000000000000000000001def3a9',
        //         '0x0000000000000000000000000000000000000000000000000000000001dc6eaf',
        //         '0x0000000000000000000000000000000000000000000000000000000000c965d4',
        //         weth.address,
        //     ],
        // );

        // const salts = [
        //     '0x0000000000000000000000000000000000000000000000000000000000b7d0eb',
        //     '0x00000000000000000000000000000000000000000000000000000000021facbb',
        //     '0x00000000000000000000000000000000000000000000000000000000000303f0',
        //     '0x000000000000000000000000000000000000000000000000000000000010b412',
        //     '0x0000000000000000000000000000000000000000000000000000000000329ee9',
        //     '0x0000000000000000000000000000000000000000000000000000000003971356',
        //     '0x0000000000000000000000000000000000000000000000000000000003971356',
        // ];

        const xnuggDeployement = await hre.deployments.deploy('xNUGG', {
            from: eoaDeployer,
            log: true,
            args: [],
            // deterministicDeployment: salts[0],
        });

        // const relayDeployment = await hre.deployments.deploy('XNUGGRelay', {
        //     from: eoaDeployer,
        //     log: true,
        //     args: [],
        //     // deterministicDeployment: salts[1],
        // });

        // const dotnuggDeployment = await hre.deployments.deploy('DotNugg', {
        //     from: eoaDeployer,
        //     log: true,
        //     args: [],
        //     // deterministicDeployment: salts[2],
        // });

        // const svgnugginDeployment = await hre.deployments.deploy('DotNuggNuggIn', {
        //     from: eoaDeployer,
        //     log: true,
        //     args: [],
        //     // deterministicDeployment: salts[6],
        // });

        // const nugginDeployment = await hre.deployments.deploy('SvgNuggIn', {
        //     from: eoaDeployer,
        //     log: true,
        //     args: [],
        //     // deterministicDeployment: salts[6],
        // });

        const nuggswapDeployment = await hre.deployments.deploy('NuggSwap', {
            from: eoaDeployer,
            log: true,
            args: [xnuggDeployement.address],
            // deterministicDeployment: salts[4],
        });

        const nuggFTDeployement = await hre.deployments.deploy('NuggFT', {
            from: eoaDeployer,
            log: true,
            args: [xnuggDeployement.address, nuggswapDeployment.address, nuggswapDeployment.address, nuggswapDeployment.address],
            // deterministicDeployment: salts[3],
        });

        hre.deployments.log('NuggFT Deployment Complete at address: ', nuggFTDeployement.address);
        hre.deployments.log('xNUGG Deployment Complete at address: ', xnuggDeployement.address);
        hre.deployments.log('NuggSwap Deployment Complete at address: ', nuggswapDeployment.address);
        // hre.deployments.log('DotNugg Deployment Complete at address: ', dotnuggDeployment.address);
        // hre.deployments.log('NuggIn Deployment Complete at address: ', nugginDeployment.address);
        // hre.deployments.log('NuggIn Deployment Complete at address: ', svgnugginDeployment.address);

        // const father = await hre.ethers.getContractAt<NuggFather>('NuggFather', fatherDeployment.address);
        //
        const nuggft = await hre.ethers.getContractAt<NuggFT>('NuggFT', nuggFTDeployement.address);
        //

        const xnugg = await hre.ethers.getContractAt<xNUGG>('xNUGG', xnuggDeployement.address);
        //

        // const dotnugg = await hre.ethers.getContractAt<DotNugg>('DotNugg', dotnuggDeployment.address);
        // const nuggin = await hre.ethers.getContractAt<>('', nugginDeployment.address);
        // const testNuggin = await hre.ethers.getContractAt<DotNuggNuggIn>('DotNuggNuggIn', svgnugginDeployment.address);

        //

        const nuggswap = await hre.ethers.getContractAt<NuggSwap>('NuggSwap', nuggswapDeployment.address);
        //

        // const seller = await hre.ethers.getContractAt<Nugg>('Nugg', sellerDeployment.address);
        //

        hre.deployments.log('Dev depositing value into xNUGG... ');
        hre.deployments.log('Total supply before: ', fromEth(await xnugg.totalSupply()));

        const tx0 = await xnugg.connect(await hre.ethers.getNamedSigner('dev')).deposit({ value: toEth('.001') });
        hre.deployments.log('tx sent... waiting to be mined... ', tx0.hash);
        await tx0.wait();
        hre.deployments.log('Total supply after: ', fromEth(await xnugg.totalSupply()));
        hre.deployments.log('Dev balance after:', fromEth(await xnugg.balanceOf(accounts.dev)));

        hre.deployments.log('Dee placing a bid... ');

        const tx = await nuggswap.connect(await hre.ethers.getNamedSigner('dee')).submitOffer(nuggft.address, 0, { value: toEth('.002') });
        hre.deployments.log('tx sent... waiting to be mined... ', tx.hash);
        await tx.wait();
        hre.deployments.log('Total supply after: ', fromEth(await xnugg.totalSupply()));
        hre.deployments.log('Dev balance after:  ', fromEth(await xnugg.balanceOf(accounts.dev)));

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
    }
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
