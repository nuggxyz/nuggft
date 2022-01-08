import { Contract, ethers } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { NamedAccounts } from '../hardhat.config';
import { toGwei } from '../tests/hardhat/lib/shared/conversion';
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
        dotnuggV1Address = '0x0857A644Aeb95685b4eeb63570Cef8a056e57D07';
    } else if (chainID === '5') {
        dotnuggV1Address = '0x6adffE28e703be151A7157D425B680E74166bC15';
    } else if (chainID === '42') {
        dotnuggV1Address = '0x6adffE28e703be151A7157D425B680E74166bC15';
    } else if (chainID === '4') {
        dotnuggV1Address = '0x6adffE28e703be151A7157D425B680E74166bC15';
    }

    const dotnuggV1 = new Contract(dotnuggV1Address, IDotnuggV1__factory.abi) as IDotnuggV1;

    hre.deployments.log('using DotnuggV1 at address: ', dotnuggV1.address);

    const nuggftDeployment = await hre.deployments.deploy('NuggftV1', {
        from: eoaDeployer.address,
        log: true,
        args: [dotnuggV1.address],
        // gasPrice: toGwei('20'),

        // deterministicDeployment: salts[2],
    });

    hre.deployments.log('NuggftV1 Deployment Complete at address: ', nuggftDeployment.address);

    const nuggft = await hre.ethers.getContractAt<NuggftV1>('NuggftV1', nuggftDeployment.address);

    const tm = await hre.deployments.deploy('NuggftV1Minter', {
        from: eoaDeployer.address,
        log: true,
        args: [],
        gasPrice: toGwei('20'),

        // deterministicDeployment: salts[2],
    });

    // const minter = await hre.ethers.getContractAt<NuggftV1Minter>('NuggftV1Minter', tm.address);

    const sendFiles = async (feature: number) => {
        return (
            await nuggft
                .connect(eoaDeployer)
                .dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[feature], feature)
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
    // await sendFiles(1);
    // await sendFiles(2);
    // await sendFiles(3);
    // await sendFiles(4);
    // await sendFiles(5);
    // await sendFiles(6);
    // await sendFiles(7);

    // await sendTx(
    //     nuggft.connect(await hre.ethers.getNamedSigner('deployer')).trustedMint(69, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', {
    //         value: toEth('.002'),
    //         gasPrice: toGwei('20'),
    //         gasLimit: 1000000,
    //     }),
    // );

    // await sendTx(
    //     nuggft.connect(await hre.ethers.getNamedSigner('deployer')).mint(770, {
    //         value: await nuggft.minSharePrice(),
    //         gasPrice: toGwei('20'),
    //         gasLimit: 1000000,
    //     }),
    // );
};
export default deployment;
