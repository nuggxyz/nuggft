import { task } from 'hardhat/config';

import { fromEth } from '../../utils/conversion';
import { NuggftV1 } from '../../../typechain';

task('minSharePrice', 'gets min share price').setAction(async (args, hre) => {
    //@ts-ignore

    const dep = await hre.deployments.get('NuggftV1');

    const nuggft = await hre.ethers.getContractAt<NuggftV1>('NuggftV1', dep.address);

    console.log(`calling nuggft.minSharePrice() on ${hre.network.name} @ ${nuggft.address}`);

    const res = await nuggft.minSharePrice();

    console.log('raw: ', res.toString());
    console.log('fmt: ', fromEth(res));
    console.log('hex: ', res._hex);

    // // const activeEpoch = await nuggft.epoch();
    // console.log('attempting to claim epoch', args.epoch);
    // const tx4 = await nuggft.connect(await hre.ethers.getNamedSigner('dee')).claim(args.epoch, args.epoch);
    // console.log('tx4 sent... waiting to be mined... ', tx4.hash);
    // await tx4.wait();
});
