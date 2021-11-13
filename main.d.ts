import 'hardhat/types/config';
import 'hardhat/types/runtime';

declare module 'hardhat/types/runtime' {
    interface HardhatRuntimeEnvironment {
        middleware: {
            test: string;
        };
    }
}

declare module 'Typechain' {
    export type TC = typeof import('./typechain');
}
