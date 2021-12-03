/// <reference types="../dotnugg-compiler-2/src/types" />

import 'hardhat/types/config';
import 'hardhat/types/runtime';

declare module 'hardhat/types/runtime' {
    interface HardhatRuntimeEnvironment {
        middleware: {
            test: string;
        };
        dotnugg: {
            feature: number;
            bits: Byter[];
            hex: import('ethers').BigNumber[];
        }[];
    }
}
