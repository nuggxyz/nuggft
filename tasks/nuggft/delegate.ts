import { task } from 'hardhat/config';

import { toEth } from '../../tests/hardhat/lib/shared/conversion';

task('delegate', 'delegates .69 eth to current epoch from dee', async (args, hre) => {
    //@ts-ignore
    const nuggft = await hre.ethers.getContractAt<NuggFT>('NuggFT', '0x726d53FD72Fc16DcF4C62CE098e4A94705f1EC5F');

    const activeEpoch = await nuggft.epoch();
    console.log('active epoch is..', activeEpoch.toString());

    const tx4 = await nuggft.connect(await hre.ethers.getNamedSigner('dee')).delegate(activeEpoch, { value: toEth('.69') });

    console.log('tx4 sent... waiting to be mined... ', tx4.hash);
    await tx4.wait();
});
