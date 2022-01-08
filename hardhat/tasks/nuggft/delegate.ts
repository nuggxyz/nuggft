import { task } from 'hardhat/config';

import { TaskHelper } from '..';

// import { NuggftV1 } from '../../typechain';

task('delegate', 'delegates .69 eth to current epoch from dee', async (args, hre) => {
    //@ts-ignore
    // const accounts = await hre.getNamedAccounts();
    // let txcount = 0;
    // const sendTx = async (tx: Promise<ethers.ContractTransaction>) => {
    //     const c = txcount++;
    //     hre.deployments.log(`tx${c} sending... `);
    //     return (
    //         await tx.then((data) => {
    //             hre.deployments.log(`tx${c} sent.. waiting to be mined... `, data.hash);
    //             return data;
    //         })
    //     )
    //         .wait()
    //         .then((data) => {
    //             hre.deployments.log(`tx${c} mined in block `, data.blockNumber);
    //         });
    // };
    // const nuggft = await hre.ethers.getContractAt<NuggftV1>('NuggftV1', '0xFde48070533C81A597B5C13bb4d15A8dF5481817');
    // const signer = await hre.ethers.getNamedSigner('dee');
    // await sendTx(
    //     nuggft.connect(await hre.ethers.getNamedSigner('deployer')).trustedMint(69, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', {
    //         value: await nuggft.minSharePrice(),
    //         gasPrice: toEth('0.0000006'),
    //     }),
    // );
    // for (let i = 0; i < 100; i++) {
    //     await sendTx(
    //         nuggft.connect(signer).delegate(accounts.dee, await nuggft.epoch(), {
    //             value: (await nuggft.valueForDelegate(accounts.dee, await nuggft.epoch())).nextSwapAmount,
    //             gasPrice: toEth('0.0000006'),
    //         }),
    //     );
    // }
    // const nuggft = await hre.ethers.getContractAt<NuggFT>('NuggFT', '0x726d53FD72Fc16DcF4C62CE098e4A94705f1EC5F');
    // const activeEpoch = await nuggft.epoch();
    // console.log('active epoch is..', activeEpoch.toString());
    // const tx4 = await nuggft.connect(await hre.ethers.getNamedSigner('dee')).delegate(activeEpoch, { value: toEth('.69') });
    // console.log('tx4 sent... waiting to be mined... ', tx4.hash);
    // await tx4.wait();
});

// task('deploy-minter', '').setAction(async (args, hre) => {
//     //@ts-ignore
//     await TaskHelper.init(hre);

//     // const nuggftDeployment = await hre.deployments.deploy('NuggftV1Minter', {
//     //     from: eoaDeployer.address,
//     //     log: true,
//     //     args: [dotnuggV1.address],
//     //     // gasPrice: toGwei('20'),

//     //     // deterministicDeployment: salts[2],
//     // });

//     const tm = new ethers.Contract(
//         '0xA922ab269B4575736FCEb46b10c12c7FC8Fd9173',
//         NuggftV1TrustedMinter__factory.abi,
//         TaskHelper.namedSigners['deployer'],
//     ) as NuggftV1TrustedMinter;

//     // await TaskHelper.send('approval', TaskHelper.nuggft.connect(TaskHelper.namedSigners['deployer']).setIsTrusted(tm.address, true));

//     // for (let i = 0; i < 200; i++) {
//     await TaskHelper.send(
//         'trustedMint',
//         TaskHelper.minter.m.mintem(TaskHelper.nuggft.address, '0x4e503501c5dedcf0607d1e1272bb4b3c1204cc71', args.start, args.amount, {
//             // value: toEth('0.'),
//             gasLimit: 8000000,
//             gasPrice: toGwei('4'),
//         }),
//     );
//     // }
// });

task('mint-a-lot', '')
    .addParam('start', '')
    .addParam('amount', '')
    .addParam('sendeth', '')
    .setAction(async (args, hre) => {
        //@ts-ignore
        await TaskHelper.init(hre);

        // for (let i = 0; i < 200; i++) {
        await TaskHelper.send(
            'trustedMint',
            TaskHelper.minter.connect(TaskHelper.namedSigners['deployer']).mint(TaskHelper.nuggft.address, args.start, args.amount, {
                // value: toEth('2'),
                gasLimit: 20000000,
                // gasPrice: toGwei('2'),
            }),
        );
        // }
    });

// task('mintandswap', '')
//     .addParam('start', '')
//     .addParam('amount', '')

//     .setAction(async (args, hre) => {
//         //@ts-ignore
//         await TaskHelper.init(hre);
//         const tm = new ethers.Contract(
//             '0xE97b42Fb6753a806DeDc318e56fCb076d0676793',
//             NuggftV1Minter__factory.abi,
//             TaskHelper.namedSigners['deployer'],
//         ) as NuggftV1Minter;

//         // await TaskHelper.send('approval', TaskHelper.nuggft.connect(TaskHelper.namedSigners['deployer']).setIsTrusted(tm.address, true));

//         // for (let i = 0; i < 200; i++) {
//         await TaskHelper.send(
//             'trustedMint',
//             tm.mintem(TaskHelper.nuggft.address, args.start, args.amount, {
//                 // value: toEth('0.25'),
//                 gasLimit: 8000000,
//                 gasPrice: toGwei('4'),
//             }),
//         );
//         // }
//     });
