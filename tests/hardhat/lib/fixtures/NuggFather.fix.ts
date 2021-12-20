import { Fixture, MockProvider } from 'ethereum-waffle';
import { BigNumber, Wallet } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { getHRE } from '../shared/deployment';
import { deployContractWithSalt } from '../shared';
import { NuggFT } from '../../../../typechain/NuggFT';
import { NuggFT__factory } from '../../../../typechain/factories/NuggFT__factory';
import {
    MockdotnuggV1Processor,
    MockdotnuggV1Processor__factory,
    MockNuggFTV1Migrator,
    MockNuggFTV1Migrator__factory,
} from '../../../../typechain';

export interface NuggFatherFixture {
    // nuggswap: NuggSwap;
    migrator: MockNuggFTV1Migrator;
    nuggft: NuggFT;
    deployer: Wallet;
    owner: string;
    ownerStartBal: BigNumber;
    hre: HardhatRuntimeEnvironment;
    blockOffset: BigNumber;
    processor: MockdotnuggV1Processor;
    // toNuggSwapTokenId(b: BigNumberish): BigNumber;
}

export const NuggFatherFix: Fixture<NuggFatherFixture> = async function (
    wallets: Wallet[],
    provider: MockProvider,
): Promise<NuggFatherFixture> {
    const hre = getHRE();

    const deployer = provider.getWallets()[16];
    const eoaOwner = provider.getWallets()[17];

    //0x435ccc2eaa41633658be26d804be5A01fEcC9337
    //0x770f070388b13A597b84B557d6B8D1CD94Fc9925

    const processor = await deployContractWithSalt<MockdotnuggV1Processor__factory>({
        factory: 'MockdotnuggV1Processor',
        from: deployer,
        args: [],
    });

    const nuggft = await deployContractWithSalt<NuggFT__factory>({
        factory: 'NuggFT',
        from: deployer,
        args: [processor.address],
    });

    const migrator = await deployContractWithSalt<MockNuggFTV1Migrator__factory>({
        factory: 'MockNuggFTV1Migrator',
        from: deployer,
        args: [],
    });

    hre.tracer.nameTags[nuggft.address] = `NuggFT`;
    hre.tracer.nameTags[migrator.address] = `MockNuggFTV1Migrator`;

    await nuggft.connect(deployer).storeFiles(hre.dotnugg.itemsByFeatureByIdArray[0], 0);
    await nuggft.connect(deployer).storeFiles(hre.dotnugg.itemsByFeatureByIdArray[1], 1);
    await nuggft.connect(deployer).storeFiles(hre.dotnugg.itemsByFeatureByIdArray[2], 2);
    await nuggft.connect(deployer).storeFiles(hre.dotnugg.itemsByFeatureByIdArray[3], 3);
    await nuggft.connect(deployer).storeFiles(hre.dotnugg.itemsByFeatureByIdArray[4], 4);
    await nuggft.connect(deployer).storeFiles(hre.dotnugg.itemsByFeatureByIdArray[5], 5);

    console.log(hre.dotnugg.itemsByFeatureByIdHex[2].length);

    // await nuggft.addToFile(hre.dotnugg.items.slice(0, 25).map((x) => x.hex));
    // await nuggft.addToFile(hre.dotnugg.items.slice(25, 50).map((x) => x.hex));

    // await nuggft.addToFile(hre.dotnugg.items.slice(50, 75).map((x) => x.hex));
    // await nuggft.addToFile(hre.dotnugg.items.slice(75, 100).map((x) => x.hex));

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
        migrator,
        processor,
        deployer,
        blockOffset,
        owner,
        // nuggswap,
        hre: getHRE(),
        ownerStartBal: await getHRE().ethers.provider.getBalance(owner),
    };
};
