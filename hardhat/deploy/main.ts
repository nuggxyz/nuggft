import { BigNumber } from 'ethers';
import { ParamType } from 'ethers/lib/utils';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { NuggftV1__factory, IDotnuggV1, IDotnuggV1__factory } from '../../typechain';
import { fromEth } from '../utils/conversion';
import { buildBytecode } from '../utils/create2';
import { Helper } from '../utils/Helper';
// import { XNUGG as xNUGG } from '../typechain/XNUGG';
// import { NuggFT } from '../typechain/NuggFT.d';
// import { fromEth, toEth } from '../tests/hardhat/lib/shared/conversion';
// import { NuggSwap } from '../typechain';

const deployment = async (hre: HardhatRuntimeEnvironment) => {
    await Helper.init(hre);
    const __trusted = Helper.namedSigners.__trusted;
    const __special = Helper.namedSigners.__special;
    // const __special_2 = Helper.namedSigners.__special__dotnu
    // send the deployer all eth

    const gasPrice = BigNumber.from(hre.network.config.gasPrice);

    const gasLimit = BigNumber.from(29032686);

    await hre.deployments.rawTx({ to: __special.address, from: __trusted.address, value: gasLimit.mul(gasPrice), log: true });

    // gg;

    const breaker = async () => {
        console.log();
        console.log();
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log();

        hre.deployments.log('__trusted balance: ', fromEth(await __trusted.getBalance()));
        hre.deployments.log('__special balance: ', fromEth(await __special.getBalance()));

        console.log();
    };

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                           calculate dotnuggV1 address
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    if (Helper.chainID === '31337') {
        await hre.deployments.rawTx({ to: __special.address, from: __trusted.address, value: gasLimit.mul(gasPrice), log: true });

        await hre.deployments.deploy('MockDotnuggV1', {
            from: __special.address,
            log: true,
            args: [],
        });
    }

    const dotnuggV1 = new hre.ethers.Contract(
        hre.ethers.utils.getContractAddress({ from: __special.address, nonce: 0 }),
        IDotnuggV1__factory.abi,
        __trusted,
    ) as unknown as IDotnuggV1;

    const check = hre.ethers.provider.getCode(dotnuggV1.address);

    if (!check) throw new Error('DotnuggV1 not deployed at: ' + dotnuggV1.address);

    hre.deployments.log('__trusted:             ', __trusted.address);
    hre.deployments.log('__special:             ', __special.address);

    await breaker();

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         calculate gas - send to __special
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    hre.deployments.log('estimated total tx cost:  ', fromEth(gasPrice.mul(gasLimit)));

    await breaker();

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    deploy
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // const salt = '0xaa764ce4c1120c26bae56f063d772168c3c59460146aca4c748c410200000000';
    const salt = '0x27b6e7032f3800389d963ddba80ceb6f7815a4fc6447889d90fdd500e5000000';

    // 0xaa764ce4c1120c26bae56f063d772168c3c59460e7a6ab60f4bbd10300000000 => 0x42069000C20061Da697bd10a655c5DE8548B1960 => 0 (0 / 2)
    const deployerAddress = hre.ethers.utils.getContractAddress({ from: __special.address, nonce: 1 });

    const initCodeHash = hre.ethers.utils.keccak256(
        buildBytecode(
            [ParamType.fromString('address[]'), ParamType.fromString('address')],
            [[__trusted.address, deployerAddress], dotnuggV1.address],
            NuggftV1__factory.bytecode,
        ),
    );

    console.log({ initCodeHash });
    const nuggftAddress = hre.ethers.utils.getCreate2Address(deployerAddress, salt, initCodeHash);

    console.log(__trusted.address);

    // const dep = await hre.deployments.deploy('NuggftV1Deployer', {
    //     from: __special.address,
    //     log: true,
    //     args: [
    //         salt,
    //         [__trusted.address, deployerAddress],
    //         dotnuggV1.address,
    //         [
    //             hre.dotnugg.itemsByFeatureByIdArray[0],
    //             hre.dotnugg.itemsByFeatureByIdArray[1],
    //             hre.dotnugg.itemsByFeatureByIdArray[2],
    //             hre.dotnugg.itemsByFeatureByIdArray[3],
    //             hre.dotnugg.itemsByFeatureByIdArray[4],
    //             hre.dotnugg.itemsByFeatureByIdArray[5],
    //             hre.dotnugg.itemsByFeatureByIdArray[6],
    //             hre.dotnugg.itemsByFeatureByIdArray[7],
    //         ],
    //     ],
    // });
    // const nuggftDeployer = await new NuggftV1Deployer__factory(__special).deploy(
    //     salt,
    //     [
    //         __trusted.address,
    //         hre.ethers.utils.getContractAddress({
    //             from: __special.address,
    //             nonce: 1,
    //         }),
    //     ],
    //     dotnuggV1.address,
    //     [
    //         hre.dotnugg.itemsByFeatureByIdArray[0],
    //         hre.dotnugg.itemsByFeatureByIdArray[1],
    //         hre.dotnugg.itemsByFeatureByIdArray[2],
    //         hre.dotnugg.itemsByFeatureByIdArray[3],
    //         hre.dotnugg.itemsByFeatureByIdArray[4],
    //         hre.dotnugg.itemsByFeatureByIdArray[5],
    //         hre.dotnugg.itemsByFeatureByIdArray[6],
    //         hre.dotnugg.itemsByFeatureByIdArray[7],
    //     ],
    //     // {
    //     //     gasLimit: 25645200,
    //     // },
    // );
    // console.log(nuggftDeployer.deployTransaction.hash);
    // console.log(await hre.ethers.getDefaultProvider().getTransaction(dep.transactionHash));
    // const nuggftDepl = new Contract(nuggftDeployer.address, NuggftV1Deployer__factory.abi, __trusted) as unknown as NuggftV1Deployer;

    // const nuggft = new Contract(await nuggftDepl.nuggft(), NuggftV1__factory.abi, __trusted) as unknown as NuggftV1;

    // console.log({ nuggftAddress, nuggft: nuggft.address });

    // console.log({ nuggftDepl: (await nuggftDepl._deployed()).deployTransaction.data });

    // const deployementTx = await nuggftDeployer.deployTransaction.wait();

    // console.log(deployementTx.gasUsed.toString());
    // console.log(deployementTx.gasUsed.toString());

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                configure trust
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                deploy features
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // if (Helper.chainID !== '3') {
    //     await Helper.send(
    //         'unsafeBulkStore',
    //         proxy__contract.unsafeBulkStore([
    //             hre.dotnugg.itemsByFeatureByIdArray[0],
    //             hre.dotnugg.itemsByFeatureByIdArray[1],
    //             hre.dotnugg.itemsByFeatureByIdArray[2],
    //             hre.dotnugg.itemsByFeatureByIdArray[3],
    //             hre.dotnugg.itemsByFeatureByIdArray[4],
    //             hre.dotnugg.itemsByFeatureByIdArray[5],
    //             hre.dotnugg.itemsByFeatureByIdArray[6],
    //             hre.dotnugg.itemsByFeatureByIdArray[7],
    //         ]),
    //     );
    // } else {
    //     await Helper.send('unsafeBulkStore', proxy__contract.store(0, hre.dotnugg.itemsByFeatureByIdArray[0], { gasLimit: 800000 }));

    //     await Helper.send('unsafeBulkStore', proxy__contract.store(1, hre.dotnugg.itemsByFeatureByIdArray[1], { gasLimit: 8000000 }));

    //     await Helper.send('unsafeBulkStore', proxy__contract.store(2, hre.dotnugg.itemsByFeatureByIdArray[2], { gasLimit: 8000000 }));

    //     await Helper.send('unsafeBulkStore', proxy__contract.store(3, hre.dotnugg.itemsByFeatureByIdArray[3], { gasLimit: 8000000 }));

    //     await Helper.send('unsafeBulkStore', proxy__contract.store(4, hre.dotnugg.itemsByFeatureByIdArray[4], { gasLimit: 8000000 }));

    //     await Helper.send('unsafeBulkStore', proxy__contract.store(5, hre.dotnugg.itemsByFeatureByIdArray[5], { gasLimit: 8000000 }));

    //     await Helper.send('unsafeBulkStore', proxy__contract.store(6, hre.dotnugg.itemsByFeatureByIdArray[6], { gasLimit: 8000000 }));

    //     await Helper.send('unsafeBulkStore', proxy__contract.store(7, hre.dotnugg.itemsByFeatureByIdArray[7], { gasLimit: 8000000 }));
    // }

    // if (Helper.chainID !== '1') {
    //     const minter__deployment = await hre.deployments.deploy('NuggftV1Minter', {
    //         from: __trusted.address,
    //         log: true,
    //         gasPrice,
    //         gasLimit: 6000000,
    //         args: [],
    //     });

    //     const minter__contract = new hre.ethers.Contract(
    //         minter__deployment.address,
    //         NuggftV1Minter__factory.abi,
    //         __trusted,
    //     ) as unknown as NuggftV1Minter;

    //     const gasLimit = Helper.chainID === '3' ? 7750000 : 20000000;
    //     const amount = Helper.chainID === '3' ? 25 : 100;
    //     let start = 1000;

    //     while (start < 1500) {
    //         await Helper.send(
    //             'trustedMint',
    //             minter__contract.connect(__trusted).mint(nuggft__contract.address, start, amount, {
    //                 value: toEth('2'),
    //                 gasLimit,
    //                 // gasPrice: toGwei('2'),
    //             }),
    //         );
    //         start += amount;
    //     }
    // }
};

export default deployment;
