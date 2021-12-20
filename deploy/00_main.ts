import { HardhatRuntimeEnvironment } from 'hardhat/types';

// import { NamedAccounts } from '../hardhat.config';
// import { fromEth, toEth } from '../tests/shared/conversion';
// import { ensureERC1820, ensureWETH } from '../tests/shared/deployment';
// import { DotNugg, NuggETHRelay } from '../typechain';
// import { NuggAuction } from '../typechain/NuggAuction.d';
// import { NuggETH } from '../typechain/NuggETH';
// import { NuggFather } from '../typechain/NuggFather';
// import { NuggFT } from '../typechain/NuggFT.d';

const deployment = async (hre: HardhatRuntimeEnvironment) => {
    // const chainID = await hre.getChainId();
    // if (chainID !== '3' && chainID !== '31337') {
    //     const accounts = (await hre.getNamedAccounts()) as Record<keyof typeof NamedAccounts, string>;
    //     await ensureERC1820();
    //     const weth = await ensureWETH();
    //     const eoaDeployer = accounts.deployer;
    //     hre.deployments.log('EOA deployer: ', accounts.deployer);
    //     const args = new ethers.utils.AbiCoder().encode(
    //         ['bytes32', 'bytes32', 'bytes32', 'bytes32', 'bytes32', 'address'],
    //         [
    //             '0x0000000000000000000000000000000000000000000000000000000000201a14',
    //             '0x000000000000000000000000000000000000000000000000000000000056c2ef',
    //             '0x0000000000000000000000000000000000000000000000000000000001def3a9',
    //             '0x0000000000000000000000000000000000000000000000000000000001dc6eaf',
    //             '0x0000000000000000000000000000000000000000000000000000000000c965d4',
    //             weth.address,
    //         ],
    //     );
    // const nuggft = await hre.ethers.getContractAt<NuggFT>('NuggFT', '0x726d53FD72Fc16DcF4C62CE098e4A94705f1EC5F');
    // const activeEpoch = await nuggft.epoch();
    // hre.deployments.log('active epoch is..', activeEpoch.toString());
    // const tx4 = await nuggft.connect(await hre.ethers.getNamedSigner('dee')).delegate(activeEpoch, { value: toEth('.69') });
    // hre.deployments.log('tx4 sent... waiting to be mined... ', tx4.hash);
    // await tx4.wait();
    //     const fatherDeployment = await hre.deployments.deploy('NuggFather', {
    //         from: eoaDeployer,
    //         log: true,
    //         args: [args],
    //     });
    //     hre.deployments.log('NuggFather Deployment Complete at address: ', fatherDeployment.address);
    //     const father = await hre.ethers.getContractAt<NuggFather>('NuggFather', fatherDeployment.address);
    //     const nuggft = await hre.ethers.getContractAt<NuggFT>('NuggFT', await father.NUGGFT());
    //     const nuggeth = await hre.ethers.getContractAt<NuggETH>('NuggETH', await father.NUGGETH());
    //     const dotnugg = await hre.ethers.getContractAt<DotNugg>('DotNugg', await father.DOTNUGG());
    //     const auction = await hre.ethers.getContractAt<NuggAuction>('NuggAuction', await father.NUGGAUCTION());
    //     const nuggethrelay = await hre.ethers.getContractAt<NuggETHRelay>('NuggETHRelay', await nuggeth.relay());
    //     // const nuggswap = await hre.ethers.getContractAt<NuggSwap>('NuggSwap', await father.NUGGSWAP());
    //     console.log('nuggeth:      ', nuggeth.address);
    //     console.log('nuggethrelay: ', nuggethrelay.address);
    //     console.log('dotnugg:      ', dotnugg.address);
    //     console.log('nuggft:       ', nuggft.address);
    //     console.log('auction:      ', auction.address);
    //     // await nuggft.connect(await hre.ethers.getNamedSigner('deployer')).launch(new ethers.utils.AbiCoder().encode([], []));
    //     const tx0 = await nuggeth.connect(await hre.ethers.getNamedSigner('dev')).deposit({ value: toEth('.001') });
    //     const tx = await auction
    //         .connect(await hre.ethers.getNamedSigner('deployer'))
    //         .placeBid(0, toEth('.001'), 0, { value: toEth('.001') });
    //     const res = await tx.wait();
    //     const res2 = await tx0.wait();
    //     const res3 = await nuggeth.balanceOf(accounts.dev);
    //     const res4 = await nuggeth.totalSupply();
    //     console.log('dev has a balance of NuggETH:', fromEth(res3));
    //     console.log('total supply of SuggETH', fromEth(res4));
    //     // if (res) {
    //     const start = new Date();
    //     const hrstart = process.hrtime();
    //     const uri = await nuggft.pendingTokenURI();
    //     if (uri) {
    //         const end = new Date().getTime() - start.getTime(),
    //             hrend = process.hrtime(hrstart);
    //         console.info('Execution time: %dms', end);
    //         console.info('Execution time (hr): %ds %dms', hrend[0], hrend[1] / 1000000);
    //         console.log(uri);
    //         // console.log(DecodeDotNuggBase64ToPngBase64(DecodeBase64ToJSON(uri).image, 10));
    //     }
    //     // }
    // }
};

export const tags = ['Haff'];

export default deployment;
