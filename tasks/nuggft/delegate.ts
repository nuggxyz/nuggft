import { ethers } from 'ethers';
import { task } from 'hardhat/config';

import { toEth } from '../../tests/hardhat/lib/shared/conversion';
import { NuggftV1 } from '../../typechain';

task('delegate', 'delegates .69 eth to current epoch from dee', async (args, hre) => {
    //@ts-ignore

    const accounts = await hre.getNamedAccounts();

    let txcount = 0;

    const sendTx = async (tx: Promise<ethers.ContractTransaction>) => {
        const c = txcount++;
        hre.deployments.log(`tx${c} sending... `);

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

    const nuggft = await hre.ethers.getContractAt<NuggftV1>('NuggftV1', '0xFde48070533C81A597B5C13bb4d15A8dF5481817');

    const signer = await hre.ethers.getNamedSigner('dee');

    await sendTx(
        nuggft.connect(await hre.ethers.getNamedSigner('deployer')).trustedMint(69, '0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77', {
            value: await nuggft.minSharePrice(),
            gasPrice: toEth('0.0000006'),
        }),
    );

    for (let i = 0; i < 100; i++) {
        await sendTx(
            nuggft.connect(signer).delegate(accounts.dee, await nuggft.epoch(), {
                value: (await nuggft.valueForDelegate(accounts.dee, await nuggft.epoch())).nextSwapAmount,
                gasPrice: toEth('0.0000006'),
            }),
        );
    }

    // const nuggft = await hre.ethers.getContractAt<NuggFT>('NuggFT', '0x726d53FD72Fc16DcF4C62CE098e4A94705f1EC5F');
    // const activeEpoch = await nuggft.epoch();
    // console.log('active epoch is..', activeEpoch.toString());
    // const tx4 = await nuggft.connect(await hre.ethers.getNamedSigner('dee')).delegate(activeEpoch, { value: toEth('.69') });
    // console.log('tx4 sent... waiting to be mined... ', tx4.hash);
    // await tx4.wait();
});
