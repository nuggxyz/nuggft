import { Fixture, MockProvider } from 'ethereum-waffle';
import { ethers } from 'hardhat';
import { BigNumber, Wallet, Contract, BigNumberish } from 'ethers';

import { ensureWETH, getHRE } from '../shared/deployment';
import { NuggSwap } from '../../../../typechain/NuggSwap';
import { XNUGG as xNUGG, XNUGG__factory as xNUGG__factory, NuggSwap__factory, MockERC721Royalties__factory } from '../../../../typechain';
import { deployContractWithSalt } from '../shared';
import { toEth } from '../shared/conversion';
import { MockDotNugg } from '../../../../typechain/MockDotNugg';
import { MockFileResolver } from '../../../../typechain/MockFileResolver';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import {} from '../../../../typechain/MockERC721Nuggable';
import { MockERC721Royalties } from '../../../../typechain/MockERC721Royalties';
import { MockERC721__factory } from '../../../../typechain/factories/MocKERC721__factory';
import { MockERC721 } from '../../../../typechain/MocKERC721';
import { MockERC721Ownable__factory } from '../../../../typechain/factories/MockERC721Ownable__factory';
import { MockERC721Ownable } from '../../../../typechain/MockERC721Ownable';
import { MockERC721Mintable } from '../../../../typechain/MockERC721Mintable';
import { MockERC721Mintable__factory } from '../../../../typechain/factories/MockERC721Mintable__factory';

type Mock721s = {
    normal: MockERC721[];
    royalties: MockERC721Royalties[];
    nuggable: [];
    named: { [_: string]: MockERC721 };
};

export interface NuggFatherFixture {
    nuggswap: NuggSwap;
    xnugg: xNUGG;
    mockERC721: MockERC721;
    mockERC721Royalties: MockERC721Royalties;
    mockERC721Ownable: MockERC721Ownable;
    mockERC721Mintable: MockERC721Mintable;
    owner: string;
    ownerStartBal: BigNumber;
    hre: HardhatRuntimeEnvironment;
    blockOffset: BigNumber;
    toNuggSwapTokenId(b: BigNumberish): BigNumber;
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

    const mockERC721Ownable = await deployContractWithSalt<MockERC721Ownable__factory>({
        factory: 'MockERC721Ownable',
        from: eoaDeployer,
        args: [],
    });

    const mockERC721Mintable = await deployContractWithSalt<MockERC721Mintable__factory>({
        factory: 'MockERC721Mintable',
        from: eoaDeployer,
        args: [eoaOwner.address, nuggswap.address],
    });

    hre.tracer.nameTags[mockERC721.address] = `mockERC721`;
    hre.tracer.nameTags[mockERC721Royalties.address] = `mockERC721Royalties`;
    hre.tracer.nameTags[mockERC721Ownable.address] = `mockERC721Ownable`;
    hre.tracer.nameTags[mockERC721Mintable.address] = `mockERC721Mintable`;

    const blockOffset = BigNumber.from(await hre.ethers.provider.getBlockNumber());

    const owner = eoaDeployer.address;

    hre.tracer.nameTags[xnugg.address] = 'xNUGG';
    hre.tracer.nameTags[nuggswap.address] = 'NuggSwap';
    hre.tracer.nameTags[owner] = 'Owner';

    function toNuggSwapTokenId(epoch: BigNumberish): BigNumber {
        return ethers.BigNumber.from(nuggswap.address).shl(96).add(epoch);
    }

    return {
        toNuggSwapTokenId,
        mockERC721,
        mockERC721Royalties,
        mockERC721Ownable,
        mockERC721Mintable,
        xnugg,
        blockOffset,
        owner,
        nuggswap,
        hre: getHRE(),
        ownerStartBal: await getHRE().ethers.provider.getBalance(owner),
    };
};
