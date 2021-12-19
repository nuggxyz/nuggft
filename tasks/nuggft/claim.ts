import { task } from 'hardhat/config';

task('claim', 'claims epoch')
    .addParam('epoch', 'the epoch to claim for')
    .setAction(async (args, hre) => {
        //@ts-ignore
        // const nuggft = await hre.ethers.getContractAt<NuggFT>('NuggFT', '0x726d53FD72Fc16DcF4C62CE098e4A94705f1EC5F');
        // // const activeEpoch = await nuggft.epoch();
        // console.log('attempting to claim epoch', args.epoch);
        // const tx4 = await nuggft.connect(await hre.ethers.getNamedSigner('dee')).claim(args.epoch, args.epoch);
        // console.log('tx4 sent... waiting to be mined... ', tx4.hash);
        // await tx4.wait();
    });
