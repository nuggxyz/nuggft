import { ParamType } from 'ethers/lib/utils';
import { task } from 'hardhat/config';

import { NuggftV1Deployer__factory, NuggftV1__factory } from '../../typechain';
import { toEth } from '../utils/conversion';
import { buildBytecode } from '../utils/create2';
import { Helper, OnchainHelper } from '../utils/Helper';

task('build-txs', '')
    .addOptionalParam('salt', '')
    .setAction(async (args: { salt: string }, hre) => {
        await Helper.init(hre);

        const __trusted = Helper.namedSigners.__trusted;
        const __special = Helper.namedSigners.__special;

        const dotnuggAddress = hre.ethers.utils.getContractAddress({ from: __special.address, nonce: 0 });

        const deployerAddress = hre.ethers.utils.getContractAddress({ from: __special.address, nonce: 1 });

        const unsigned = new NuggftV1Deployer__factory(__special).getDeployTransaction(
            args.salt,
            [__trusted.address, deployerAddress],
            dotnuggAddress,
            [
                hre.dotnugg.itemsByFeatureByIdArray[0],
                hre.dotnugg.itemsByFeatureByIdArray[1],
                hre.dotnugg.itemsByFeatureByIdArray[2],
                hre.dotnugg.itemsByFeatureByIdArray[3],
                hre.dotnugg.itemsByFeatureByIdArray[4],
                hre.dotnugg.itemsByFeatureByIdArray[5],
                hre.dotnugg.itemsByFeatureByIdArray[6],
                hre.dotnugg.itemsByFeatureByIdArray[7],
            ],
        );

        console.log(unsigned.data);
    });

task('get-args', '').setAction(async (args, hre) => {
    const wallet = hre.ethers.Wallet.createRandom();

    const dotnuggAddress = hre.ethers.utils.getContractAddress({ from: wallet.address, nonce: 0 });

    const deployerAddress = hre.ethers.utils.getContractAddress({ from: wallet.address, nonce: 1 });

    const initCodeHash = hre.ethers.utils.keccak256(
        buildBytecode(
            [ParamType.fromString('address[]'), ParamType.fromString('address')],
            [['0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', deployerAddress], dotnuggAddress],
            NuggftV1__factory.bytecode,
        ),
    );

    console.log(`export FACTORY="${deployerAddress}"`);
    console.log(`export CALLER="${wallet.address}"`);
    console.log(`export INIT_CODE_HASH="${initCodeHash}"`);

    console.log('deployer private key: ', wallet.privateKey);

    // console.log('deployerAddress: ', deployerAddress);

    // console.log('deployerAddress: ', deployerAddress);
});

task('get-args-2', '').setAction(async (args, hre) => {
    const wallet = hre.ethers.Wallet.createRandom();

    const deployerAddress = hre.ethers.utils.getContractAddress({ from: wallet.address, nonce: 1 });

    const dotnuggAddress = hre.ethers.utils.getContractAddress({ from: deployerAddress, nonce: 1 });

    const initCodeHash = hre.ethers.utils.keccak256(
        buildBytecode(
            [ParamType.fromString('address[]'), ParamType.fromString('address')],
            [['0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', deployerAddress], dotnuggAddress],
            NuggftV1__factory.bytecode,
        ),
    );

    console.log(`export FACTORY="${deployerAddress}"`);
    console.log(`export CALLER="${wallet.address}"`);
    console.log(`export INIT_CODE_HASH="${initCodeHash}"`);

    console.log('deployer private key: ', wallet.privateKey);

    // console.log('deployerAddress: ', deployerAddress);

    // console.log('deployerAddress: ', deployerAddress);
});

task('mint-a-lot', '').setAction(async (args, hre) => {
    //@ts-ignore
    await OnchainHelper.init(hre);

    let start = 1500;
    while (start < 2000) {
        await OnchainHelper.send(
            'trustedMint',
            OnchainHelper.minter.mint(OnchainHelper.nuggft.address, start, 100, {
                value: toEth('2'),
                gasLimit: 20000000,
                // gasPrice: toGwei('2'),
            }),
        );
        start += 100;
    }
    // }
});

task('trusted-mint-a-lot', '').setAction(async (args, hre) => {
    //@ts-ignore
    await OnchainHelper.init(hre);

    await OnchainHelper.send('trust', OnchainHelper.nuggft.setIsTrusted(OnchainHelper.minter.address, true));

    let start = 100;
    while (start < 200) {
        await OnchainHelper.send(
            'trustedMint',
            OnchainHelper.minter.trustMint(OnchainHelper.nuggft.address, '0x4e503501c5dedcf0607d1e1272bb4b3c1204cc71', start, 100, {
                value: toEth('2'),
                gasLimit: 20000000,
                // gasPrice: toGwei('2'),
            }),
        );
        start += 100;
    }
    // }
});

task('view-lengthof', '').setAction(async (args, hre) => {
    //@ts-ignore
    await OnchainHelper.init(hre);

    console.log(await OnchainHelper.nuggft.lengthOf(1));
    console.log(await OnchainHelper.nuggft.lengthOf(1));
    console.log(await OnchainHelper.nuggft.lengthOf(1));
    console.log(await OnchainHelper.nuggft.lengthOf(1));
    console.log(await OnchainHelper.nuggft.lengthOf(1));

    // }
});

task('claim-a-lot', '').setAction(async (args, hre) => {
    //@ts-ignore
    await OnchainHelper.init(hre);

    let start = 100;
    while (start < 200) {
        await OnchainHelper.send('trustedMint', OnchainHelper.minter.claimSelf(OnchainHelper.nuggft.address, 5));
        start += 5;
    }
    // }
});

// [
//     ParamType {
//       name: null,
//       type: 'address[]',
//       indexed: null,
//       components: null,
//       arrayLength: -1,
//       arrayChildren: ParamType {
//         name: null,
//         type: 'address',
//         indexed: null,
//         components: null,
//         arrayLength: null,
//         arrayChildren: null,
//         baseType: 'address',
//         _isParamType: true
//       },
//       baseType: 'array',
//       _isParamType: true
//     },
//     ParamType {
//       name: null,
//       type: 'address',
//       indexed: null,
//       components: null,
//       arrayLength: null,
//       arrayChildren: null,
//       baseType: 'address',
//       _isParamType: true
//     }
//   ] [
//     [
//       '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77',
//       '0x3aB011497A68408c972204f43F148d3206D851E2'
//     ],
//     '0x4DE964A4dC83D06FA04EAD32C504c2CA0E4d2084'

//     [
//         ParamType {
//           name: null,
//           type: 'address[]',
//           indexed: null,
//           components: null,
//           arrayLength: -1,
//           arrayChildren: ParamType {
//             name: null,
//             type: 'address',
//             indexed: null,
//             components: null,
//             arrayLength: null,
//             arrayChildren: null,
//             baseType: 'address',
//             _isParamType: true
//           },
//           baseType: 'array',
//           _isParamType: true
//         },
//         ParamType {
//           name: null,
//           type: 'address',
//           indexed: null,
//           components: null,
//           arrayLength: null,
//           arrayChildren: null,
//           baseType: 'address',
//           _isParamType: true
//         }
//       ] [
//         [
//           '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77',
//           '0x3aB011497A68408c972204f43F148d3206D851E2'
//         ],
//         '0x4DE964A4dC83D06FA04EAD32C504c2CA0E4d2084'
