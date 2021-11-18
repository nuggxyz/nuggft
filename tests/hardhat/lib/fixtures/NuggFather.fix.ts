import { Fixture, MockProvider } from 'ethereum-waffle';
import { ethers } from 'hardhat';
import { BigNumber, Wallet, Contract } from 'ethers';

import { ensureWETH, getHRE } from '../shared/deployment';
import { NuggSwap } from '../../../../typechain/NuggSwap';
import {
    XNUGG as xNUGG,
    XNUGG__factory as xNUGG__factory,
    NuggSwap__factory,
    MockERC721Nuggable__factory,
    MockERC721Royalties__factory,
} from '../../../../typechain';
import { deployContractWithSalt } from '../shared';
import { toEth } from '../shared/conversion';
import { MockDotNugg } from '../../../../typechain/MockDotNugg';
import { MockFileResolver } from '../../../../typechain/MockFileResolver';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { MockERC721Nuggable } from '../../../../typechain/MockERC721Nuggable';
import { MockERC721Royalties } from '../../../../typechain/MockERC721Royalties';
import { MockERC721__factory } from '../../../../typechain/factories/MocKERC721__factory';
import { MockERC721 } from '../../../../typechain/MocKERC721';

type Mock721s = {
    normal: MockERC721[];
    royalties: MockERC721Royalties[];
    nuggable: MockERC721Nuggable[];
    named: { [_: string]: MockERC721 };
};

export interface NuggFatherFixture {
    nuggswap: NuggSwap;
    xnugg: xNUGG;
    mockERC721: MockERC721;
    mockERC721Royalties: MockERC721Royalties;
    mockERC721Nuggable: MockERC721Nuggable;
    tummy: string;
    tummyStartBal: BigNumber;
    hre: HardhatRuntimeEnvironment;
    blockOffset: BigNumber;
}

export const NuggFatherFix: Fixture<NuggFatherFixture> = async function (
    wallets: Wallet[],
    provider: MockProvider,
): Promise<NuggFatherFixture> {
    const hre = getHRE();

    const eoaDeployer = provider.getWallets()[16];
    const eoaOwner = provider.getWallets()[17];

    const xnugg = await deployContractWithSalt<xNUGG__factory>({
        factory: 'xNUGG',
        from: eoaDeployer,
        args: [],
    });

    const nuggswap = await deployContractWithSalt<NuggSwap__factory>({
        factory: 'NuggSwap',
        from: eoaDeployer,
        args: [xnugg.address],
    });

    const mockERC721 = await deployContractWithSalt<MockERC721__factory>({
        factory: 'MockERC721',
        from: eoaDeployer,
        args: [],
    });

    const mockERC721Royalties = await deployContractWithSalt<MockERC721Royalties__factory>({
        factory: 'MockERC721Royalties',
        from: eoaDeployer,
        args: [eoaOwner.address],
    });

    const mockERC721Nuggable = await deployContractWithSalt<MockERC721Nuggable__factory>({
        factory: 'MockERC721Nuggable',
        from: eoaDeployer,
        args: [eoaOwner.address, nuggswap.address],
    });

    hre.tracer.nameTags[mockERC721.address] = `mockERC721`;
    hre.tracer.nameTags[mockERC721Royalties.address] = `mockERC721Royalties`;
    hre.tracer.nameTags[mockERC721Nuggable.address] = `mockERC721Nuggable`;

    const blockOffset = BigNumber.from(await hre.ethers.provider.getBlockNumber());

    const tummy = await xnugg.tummy();

    hre.tracer.nameTags[xnugg.address] = 'xNUGG';
    hre.tracer.nameTags[nuggswap.address] = 'NuggSwap';
    hre.tracer.nameTags[tummy] = 'Tummy';

    return {
        mockERC721,
        mockERC721Royalties,
        mockERC721Nuggable,
        xnugg,
        blockOffset,
        tummy,
        nuggswap,
        hre: getHRE(),
        tummyStartBal: await getHRE().ethers.provider.getBalance(tummy),
    };
};
