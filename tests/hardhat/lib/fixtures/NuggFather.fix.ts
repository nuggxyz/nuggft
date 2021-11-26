import { Fixture, MockProvider } from 'ethereum-waffle';
import { ethers } from 'hardhat';
import { BigNumber, Wallet, Contract, BigNumberish } from 'ethers';

import { ensureWETH, getHRE } from '../shared/deployment';
import { NuggSwap } from '../../../../typechain/NuggSwap';
import {
    XNUGG as xNUGG,
    XNUGG__factory as xNUGG__factory,
    NuggSwap__factory,
    MockERC1155Breakable,
    MockERC1155Breakable__factory,
} from '../../../../typechain';
import { deployContractWithSalt } from '../shared';

import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { MockERC721Breakable } from '../../../../typechain/MockERC721Breakable';
import { MockERC721Breakable__factory } from '../../../../typechain/factories/MockERC721Breakable__factory';

export interface NuggFatherFixture {
    nuggswap: NuggSwap;
    xnugg: xNUGG;
    mockERC721: MockERC721Breakable;
    // mockERC1155: MockERC1155Breakable;

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

    //0x435ccc2eaa41633658be26d804be5A01fEcC9337
    //0x770f070388b13A597b84B557d6B8D1CD94Fc9925

    const mockERC721 = await deployContractWithSalt<MockERC721Breakable__factory>({
        factory: 'MockERC721Breakable',
        from: eoaDeployer,
        args: [xnugg.address, nuggswap.address],
    });

    // const mockERC1155 = new Contract(await mockERC721.nuggftdata(), MockERC1155Breakable__factory.abi, eoaDeployer) as MockERC1155Breakable;

    hre.tracer.nameTags[mockERC721.address] = `mockERC721`;

    const blockOffset = BigNumber.from(await hre.ethers.provider.getBlockNumber());

    const owner = eoaDeployer.address;

    hre.tracer.nameTags[xnugg.address] = 'xNUGG';
    hre.tracer.nameTags[nuggswap.address] = 'NuggSwap';
    hre.tracer.nameTags['0x0000000000000000000000000000000000000000'] = 'BLACK_HOLE';
    hre.tracer.nameTags[owner] = 'Owner';
    // hre.tracer.nameTags[mockERC1155.address] = 'mockERC1155';

    function toNuggSwapTokenId(epoch: BigNumberish): BigNumber {
        return ethers.BigNumber.from(nuggswap.address).shl(96).add(epoch);
    }

    return {
        toNuggSwapTokenId,
        // mockERC1155,
        mockERC721,
        xnugg,
        blockOffset,
        owner,
        nuggswap,
        hre: getHRE(),
        ownerStartBal: await getHRE().ethers.provider.getBalance(owner),
    };
};
