import { Fixture, MockProvider } from 'ethereum-waffle';
import { ethers } from 'hardhat';
import { BigNumber, Wallet, Contract } from 'ethers';

import { ensureWETH, getHRE } from '../shared/deployment';
import { NuggSwap } from '../../../../typechain/NuggSwap';
import {
    NuggFT,
    XNUGG as xNUGG,
    XNUGG__factory as xNUGG__factory,
    NuggFT__factory,
    NuggSwap__factory,
    MockFileResolver__factory,
    MockDotNugg__factory,
} from '../../../../typechain';
import { deployContractWithSalt } from '../shared';
import { toEth } from '../shared/conversion';
import { MockDotNugg } from '../../../../typechain/MockDotNugg';
import { MockFileResolver } from '../../../../typechain/MockFileResolver';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

export interface NuggFatherFixture {
    nuggft: NuggFT;
    nuggswap: NuggSwap;
    xnugg: xNUGG;
    dotnugg: MockDotNugg;
    tummy: string;
    tummyStartBal: BigNumber;
    nuggin: MockFileResolver;
    hre: HardhatRuntimeEnvironment;
    blockOffset: BigNumber;
}

export const NuggFatherFix: Fixture<NuggFatherFixture> = async function (
    wallets: Wallet[],
    provider: MockProvider,
): Promise<NuggFatherFixture> {
    const hre = getHRE();

    const eoaDeployer = provider.getWallets()[16];

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
        args: [xnugg.address, nuggswap.address, dotnugg.address, nuggin.address],
    });

    const blockOffset = BigNumber.from(await hre.ethers.provider.getBlockNumber());

    const tummy = await xnugg.tummy();
    hre.tracer.nameTags[nuggft.address] = 'NuggFT';
    hre.tracer.nameTags[dotnugg.address] = 'DotNugg';
    hre.tracer.nameTags[xnugg.address] = 'xNUGG';
    hre.tracer.nameTags[nuggswap.address] = 'NuggSwap';
    hre.tracer.nameTags[tummy] = 'Tummy';
    hre.tracer.nameTags[nuggin.address] = 'NuggIn';

    return {
        nuggft,
        dotnugg,
        xnugg,
        blockOffset,
        tummy,
        nuggin,
        nuggswap,
        hre: getHRE(),
        tummyStartBal: await getHRE().ethers.provider.getBalance(tummy),
    };
};
