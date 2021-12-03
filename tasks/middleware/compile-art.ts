import { EthereumProvider } from 'hardhat/types';
import { DotNuggCompiler } from '../../../dotnugg-compiler-2/src/main';

export async function compileDotnugg(provider: EthereumProvider): Promise<void> {
    const files = DotNuggCompiler.build('../nuggft-art');
    console.log({ files });
    // const code = await provider.send('eth_getCode', [ERC1820_ADDRESS, 'latest']);
    // if (code === '0x') {
    //     const [from] = await provider.send('eth_accounts');

    //     const tx = await provider.send('eth_sendTransaction', [
    //         {
    //             from,
    //             to: ERC1820_DEPLOYER,
    //             value: '0x11c37937e080000',
    //         },
    //     ]);

    //     await provider.send('eth_sendRawTransaction', [ERC1820_PAYLOAD]);

    //     console.log('ERC1820 registry successfully deployed');
}
