import { Fixture, MockProvider } from 'ethereum-waffle';
import { ethers } from 'hardhat';
import { BigNumber, Wallet, Contract } from 'ethers';

import { ensureWETH, getHRE } from '../shared/deployment';
import { NuggSwap } from '../../../../typechain/NuggSwap';
import {
    NuggFT,
    NuggETH,
    Escrow,
    NuggETH__factory,
    NuggFT__factory,
    Escrow__factory,
    NuggSwap__factory,
    MockFileResolver__factory,
    MockDotNugg__factory,
} from '../../../../typechain';
import { deployContractWithSalt } from '../shared';
import { toEth } from '../shared/conversion';
import { MockDotNugg } from '../../../../typechain/MockDotNugg';
import { MockFileResolver } from '../../../../typechain/MockFileResolver';

export interface NuggFatherFixture {
    nuggft: NuggFT;
    nuggswap: NuggSwap;
    nuggeth: NuggETH;
    dotnugg: MockDotNugg;
    tummy: Escrow;
    nuggin: MockFileResolver;

    blockOffset: BigNumber;
}

export const NuggFatherFix: Fixture<NuggFatherFixture> = async function (
    wallets: Wallet[],
    provider: MockProvider,
): Promise<NuggFatherFixture> {
    const hre = getHRE();

    const eoaDeployer = provider.getWallets()[16];

    const nuggeth = await deployContractWithSalt<NuggETH__factory>({
        factory: 'NuggETH',
        from: eoaDeployer,
        args: [],
    });

    const nuggswap = await deployContractWithSalt<NuggSwap__factory>({
        factory: 'NuggSwap',
        from: eoaDeployer,
        args: [nuggeth.address],
    });

    const nuggin = await deployContractWithSalt<MockFileResolver__factory>({
        factory: 'MockFileResolver',
        from: eoaDeployer,
        args: [],
    });

    const dotnugg = await deployContractWithSalt<MockDotNugg__factory>({
        factory: 'MockDotNugg',
        from: eoaDeployer,
        args: [],
    });

    const nuggft = await deployContractWithSalt<NuggFT__factory>({
        factory: 'NuggFT',
        from: eoaDeployer,
        args: [nuggeth.address, nuggswap.address, dotnugg.address, nuggin.address],
    });

    const blockOffset = BigNumber.from(await hre.ethers.provider.getBlockNumber());

    const tummy = new Contract(await nuggeth.tummy(), Escrow__factory.abi, provider.getSigner(0)) as Escrow;

    hre.tracer.nameTags[nuggft.address] = 'NuggFT';
    hre.tracer.nameTags[dotnugg.address] = 'DotNugg';
    hre.tracer.nameTags[nuggeth.address] = 'NuggETH';
    hre.tracer.nameTags[nuggswap.address] = 'NuggSwap';
    hre.tracer.nameTags[tummy.address] = 'Tummy';
    hre.tracer.nameTags[nuggin.address] = 'NuggIn';

    return { nuggft, dotnugg, nuggeth, blockOffset, tummy, nuggin, nuggswap };
};
