import { Fixture, MockProvider } from 'ethereum-waffle';
import { BigNumber, Wallet } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { getHRE } from '../shared/deployment';
import { deployContractWithSalt } from '../shared';
import { NuggFT } from '../../../../typechain/NuggFT';
import { NuggFT__factory } from '../../../../typechain/factories/NuggFT__factory';
import { MockProcessResolver__factory } from '../../../../typechain';

export interface NuggFatherFixture {
    // nuggswap: NuggSwap;
    // xnugg: xNUGG;
    nuggft: NuggFT;
    deployer: Wallet;
    owner: string;
    ownerStartBal: BigNumber;
    hre: HardhatRuntimeEnvironment;
    blockOffset: BigNumber;

    // toNuggSwapTokenId(b: BigNumberish): BigNumber;
}

export const NuggFatherFix: Fixture<NuggFatherFixture> = async function (
    wallets: Wallet[],
    provider: MockProvider,
): Promise<NuggFatherFixture> {
    const hre = getHRE();

    const deployer = provider.getWallets()[16];
    const eoaOwner = provider.getWallets()[17];

    // const xnugg = await deployContractWithSalt<xNUGG__factory>({
    //     factory: 'xNUGG',
    //     from: deployer,
    //     args: [],
    // });

    // const nuggswap = await deployContractWithSalt<NuggSwap__factory>({
    //     factory: 'NuggSwap',
    //     from: deployer,
    //     args: [xnugg.address],
    // });

    //0x435ccc2eaa41633658be26d804be5A01fEcC9337
    //0x770f070388b13A597b84B557d6B8D1CD94Fc9925

    const processResolver = await deployContractWithSalt<MockProcessResolver__factory>({
        factory: 'MockProcessResolver',
        from: deployer,
        args: [],
    });

    const nuggft = await deployContractWithSalt<NuggFT__factory>({
        factory: 'NuggFT',
        from: deployer,
        args: [processResolver.address],
    });

    hre.tracer.nameTags[nuggft.address] = `NuggFT`;

    await nuggft.addToVault(hre.dotnugg.itemsByFeatureByIdHex);
    await nuggft.addToVault(hre.dotnugg.itemsByFeatureByIdHex);
    await nuggft.addToVault(hre.dotnugg.itemsByFeatureByIdHex);
    await nuggft.addToVault(hre.dotnugg.itemsByFeatureByIdHex);
    await nuggft.addToVault(hre.dotnugg.itemsByFeatureByIdHex);
    await nuggft.addToVault(hre.dotnugg.itemsByFeatureByIdHex);

    console.log(hre.dotnugg.itemsByFeatureByIdHex[2].length);

    // await nuggft.addToVault(hre.dotnugg.items.slice(0, 25).map((x) => x.hex));
    // await nuggft.addToVault(hre.dotnugg.items.slice(25, 50).map((x) => x.hex));

    // await nuggft.addToVault(hre.dotnugg.items.slice(50, 75).map((x) => x.hex));
    // await nuggft.addToVault(hre.dotnugg.items.slice(75, 100).map((x) => x.hex));

    const blockOffset = BigNumber.from(await hre.ethers.provider.getBlockNumber());

    const owner = deployer.address;

    // hre.tracer.nameTags[xnugg.address] = 'xNUGG';
    // hre.tracer.nameTags[nuggswap.address] = 'NuggSwap';
    hre.tracer.nameTags['0x0000000000000000000000000000000000000000'] = 'BLACK_HOLE';
    hre.tracer.nameTags[owner] = 'Owner';
    // hre.tracer.nameTags[mockERC1155.address] = 'mockERC1155';

    // function toNuggSwapTokenId(epoch: BigNumberish): BigNumber {
    //     return ethers.BigNumber.from(nuggswap.address).shl(96).add(epoch);
    // }

    return {
        // toNuggSwapTokenId,
        // mockERC1155,
        // dotnugg: hre.dotnugg,
        nuggft,
        // xnugg,
        deployer,
        blockOffset,
        owner,
        // nuggswap,
        hre: getHRE(),
        ownerStartBal: await getHRE().ethers.provider.getBalance(owner),
    };
};
