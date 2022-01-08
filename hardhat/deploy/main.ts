import { BigNumber } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { NuggftV1__factory } from '../../typechain';
import {
    IDotnuggV1,
    IDotnuggV1StorageProxy,
    IDotnuggV1StorageProxy__factory,
    IDotnuggV1__factory,
    NuggftV1,
    NuggftV1Minter,
    NuggftV1Minter__factory,
} from '../typechain';
import { fromEth, toEth } from '../utils/conversion';
import { Helper } from '../utils/Helper';
// import { XNUGG as xNUGG } from '../typechain/XNUGG';
// import { NuggFT } from '../typechain/NuggFT.d';
// import { fromEth, toEth } from '../tests/hardhat/lib/shared/conversion';
// import { NuggSwap } from '../typechain';

const deployment = async (hre: HardhatRuntimeEnvironment) => {
    await Helper.init(hre);

    const __trusted = Helper.namedSigners.__trusted;
    const __special = Helper.namedSigners.__special;
    const __special_2 = Helper.namedSigners.__special__dotnugg;

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
        await hre.deployments.deploy('MockDotnuggV1', {
            from: __special_2.address,
            log: true,
            args: [],
        });
    }

    const dotnuggV1 = new hre.ethers.Contract(
        hre.ethers.utils.getContractAddress({ from: __special_2.address, nonce: 0 }),
        IDotnuggV1__factory.abi,
        __trusted,
    ) as unknown as IDotnuggV1;

    const check = hre.ethers.provider.getCode(dotnuggV1.address);

    if (!check) throw new Error('DotnuggV1 not deployed at: ' + dotnuggV1.address);

    hre.deployments.log('__trusted:             ', __trusted.address);

    await breaker();

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         calculate gas - send to __special
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    const gasPrice = BigNumber.from(hre.network.config.gasPrice);

    const gasLimit = BigNumber.from(6901000);

    hre.deployments.log('estimated total tx cost:  ', fromEth(gasPrice.mul(gasLimit)));

    await breaker();

    // send the deployer all eth
    await hre.deployments.rawTx({ to: __special.address, from: __trusted.address, value: gasPrice.mul(gasLimit), log: true });

    await breaker();

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    deploy
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    const nuggft__deployment = await hre.deployments.deploy('NuggftV1', {
        from: __special.address,
        log: true,
        gasPrice,
        gasLimit,
        nonce: 0,
        args: [dotnuggV1.address],
    });

    const nuggft__contract = new hre.ethers.Contract(nuggft__deployment.address, NuggftV1__factory.abi, __trusted) as unknown as NuggftV1;

    const proxy__contract = new hre.ethers.Contract(
        await dotnuggV1.proxyOf(nuggft__contract.address),
        IDotnuggV1StorageProxy__factory.abi,
        __trusted,
    ) as unknown as IDotnuggV1StorageProxy;

    await breaker();

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                configure trust
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    await hre.deployments.execute('NuggftV1', { from: __special.address, log: true }, 'setIsTrusted', __trusted.address, true);

    await hre.deployments.execute('NuggftV1', { from: __trusted.address, log: true }, 'setIsTrusted', __special.address, false);

    await breaker();

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                deploy features
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    if (Helper.chainID !== '3') {
        await Helper.send(
            'unsafeBulkStore',
            proxy__contract.unsafeBulkStore([
                hre.dotnugg.itemsByFeatureByIdArray[0],
                hre.dotnugg.itemsByFeatureByIdArray[1],
                hre.dotnugg.itemsByFeatureByIdArray[2],
                hre.dotnugg.itemsByFeatureByIdArray[3],
                hre.dotnugg.itemsByFeatureByIdArray[4],
                hre.dotnugg.itemsByFeatureByIdArray[5],
                hre.dotnugg.itemsByFeatureByIdArray[6],
                hre.dotnugg.itemsByFeatureByIdArray[7],
            ]),
        );
    } else {
        // await Helper.send('unsafeBulkStore', proxy__contract.store(0, hre.dotnugg.itemsByFeatureByIdArray[0], { gasLimit: 800000 }));

        await Helper.send('unsafeBulkStore', proxy__contract.store(1, hre.dotnugg.itemsByFeatureByIdArray[1], { gasLimit: 8000000 }));

        await Helper.send('unsafeBulkStore', proxy__contract.store(2, hre.dotnugg.itemsByFeatureByIdArray[2], { gasLimit: 8000000 }));

        await Helper.send('unsafeBulkStore', proxy__contract.store(3, hre.dotnugg.itemsByFeatureByIdArray[3], { gasLimit: 8000000 }));

        await Helper.send('unsafeBulkStore', proxy__contract.store(4, hre.dotnugg.itemsByFeatureByIdArray[4], { gasLimit: 8000000 }));

        await Helper.send('unsafeBulkStore', proxy__contract.store(5, hre.dotnugg.itemsByFeatureByIdArray[5], { gasLimit: 8000000 }));

        await Helper.send('unsafeBulkStore', proxy__contract.store(6, hre.dotnugg.itemsByFeatureByIdArray[6], { gasLimit: 8000000 }));

        await Helper.send('unsafeBulkStore', proxy__contract.store(7, hre.dotnugg.itemsByFeatureByIdArray[7], { gasLimit: 8000000 }));
    }

    if (Helper.chainID !== '1') {
        const minter__deployment = await hre.deployments.deploy('NuggftV1Minter', {
            from: __trusted.address,
            log: true,
            gasPrice,
            gasLimit: 6000000,
            args: [],
        });

        const minter__contract = new hre.ethers.Contract(
            minter__deployment.address,
            NuggftV1Minter__factory.abi,
            __trusted,
        ) as unknown as NuggftV1Minter;

        const gasLimit = Helper.chainID === '3' ? 7750000 : 20000000;
        const amount = Helper.chainID === '3' ? 25 : 100;
        let start = 1000;

        while (start < 1500) {
            await Helper.send(
                'trustedMint',
                minter__contract.connect(__trusted).mint(nuggft__contract.address, start, amount, {
                    value: toEth('2'),
                    gasLimit,
                    // gasPrice: toGwei('2'),
                }),
            );
            start += amount;
        }
    }
};

export default deployment;
