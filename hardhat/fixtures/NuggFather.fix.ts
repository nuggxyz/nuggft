import { Fixture, MockProvider } from 'ethereum-waffle';
import { BigNumber, Wallet } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { getHRE } from '../utils/deployment';
import { deployContractWithSalt } from '../utils';
import { NuggftV1 } from '../../typechain/NuggftV1';
import { NuggftV1__factory } from '../../typechain/factories/NuggftV1__factory';
import {
    PureDeployer__factory,
    IDotnuggV1,
    MockDotnuggV1__factory,
    MockNuggftV1Migrator,
    MockNuggftV1Migrator__factory,
} from '../../typechain';
import { IDotnuggV1__factory } from '../../typechain/factories/IDotnuggV1__factory';
import { encodeParams } from '../utils/create2';

export interface NuggFatherFixture {
    // nuggswap: NuggSwap;
    migrator: MockNuggftV1Migrator;
    nuggft: NuggftV1;
    deployer: Wallet;
    owner: string;
    ownerStartBal: BigNumber;
    hre: HardhatRuntimeEnvironment;
    blockOffset: BigNumber;
    dotnugg: IDotnuggV1;
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

    const chainId = await hre.getChainId();

    console.log(chainId, deployer.address);

    // const dotnugg = (await deployContractWithSalt<IDotnuggV1__factory>({
    //     factory: 'IDotnuggV1',
    //     from: deployer,
    //     args: [],
    // })) as unknown as IDotnuggV1;

    // const dotnugg = new Contract('0x603DED7DE6677FeDC13bf2B334C249584D263da4', IDotnuggV1__factory.abi) as IDotnuggV1;

    const dep = await deployContractWithSalt<PureDeployer__factory>({
        factory: 'PureDeployer',
        from: deployer,
        args: [],
    });

    const hello = await dep.init(
        '0xa44b57a44fc8cbe9f0d3da33ffeddf478bbc4eb1b0457cedb08573be17553aa5',
        '0xa44b57a44fc8cbe9f0d3da33ffeddf478bbc4eb1b0457cedb08573be17553aa5',
        NuggftV1__factory.bytecode,
        MockDotnuggV1__factory.bytecode,
        encodeParams(
            [hre.ethers.utils.ParamType.fromString('uint256[][][]')],
            [
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
            ],
        ),
    );

    await hello.wait();

    const nuggft = new hre.ethers.Contract(
        await dep.__nuggft(),

        NuggftV1__factory.abi,
    ) as NuggftV1;

    const dotnugg = new hre.ethers.Contract(await dep.__dotnugg(), IDotnuggV1__factory.abi) as IDotnuggV1;

    // const dotnuggV1StorageProxy = new Contract(
    //     await nuggft.dotnuggV1StorageProxy(),
    //     DotnuggV1StorageProxy__factory.abi,
    //     deployer,
    // ) as unknown as IDotnuggV1StorageProxy;

    const migrator = await deployContractWithSalt<MockNuggftV1Migrator__factory>({
        factory: 'MockNuggftV1Migrator',
        from: deployer,
        args: [],
    });

    hre.tracer.nameTags[nuggft.address] = `NuggftV1`;
    hre.tracer.nameTags[migrator.address] = `MockNuggftV1Migrator`;

    // await dotnuggV1StorageProxy.store(0, hre.dotnugg.itemsByFeatureByIdArray[0]);
    // await dotnuggV1StorageProxy.store(1, hre.dotnugg.itemsByFeatureByIdArray[1]);
    // await dotnuggV1StorageProxy.store(2, hre.dotnugg.itemsByFeatureByIdArray[2]);
    // await dotnuggV1StorageProxy.store(3, hre.dotnugg.itemsByFeatureByIdArray[3]);
    // await dotnuggV1StorageProxy.store(4, hre.dotnugg.itemsByFeatureByIdArray[4]);
    // await dotnuggV1StorageProxy.store(5, hre.dotnugg.itemsByFeatureByIdArray[5]);
    // await dotnuggV1StorageProxy.store(6, hre.dotnugg.itemsByFeatureByIdArray[6]);
    // await dotnuggV1StorageProxy.store(7, hre.dotnugg.itemsByFeatureByIdArray[7]);

    // await nuggft.connect(deployer).dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[0], 0);
    // await nuggft.connect(deployer).dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[1], 1);
    // await nuggft.connect(deployer).dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[2], 2);
    // await nuggft.connect(deployer).dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[3], 3);
    // await nuggft.connect(deployer).dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[4], 4);
    // await nuggft.connect(deployer).dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[5], 5);
    // await nuggft.connect(deployer).dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[6], 6);
    // await nuggft.connect(deployer).dotnuggV1StoreFiles(hre.dotnugg.itemsByFeatureByIdArray[7], 7);

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
        dotnugg,
        deployer,
        blockOffset,
        owner,
        // nuggswap,
        hre: getHRE(),
        ownerStartBal: await getHRE().ethers.provider.getBalance(owner),
    };
};
