// HARDHAT IMPORTS
import 'dotenv/config';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-solhint';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-deploy';
import 'hardhat-gas-reporter';
import 'solidity-coverage';
import '@typechain/hardhat';
import 'hardhat-erc1820';
import 'hardhat-abi-exporter';
import 'hardhat-contract-sizer';
import '@atixlabs/hardhat-time-n-mine';
import 'hardhat-storage-layout';
// NORMAL IMPORTS
import 'hardhat-tracer';
import 'hardhat-spdx-license-identifier';
import '../dotnugg-hardhat/src';
import './hardhat/tasks/main';
import { resolve } from 'path';

import { config as dotenvConfig } from 'dotenv';
import { utils } from 'ethers';
import { HardhatUserConfig, NetworksUserConfig, NetworkUserConfig } from 'hardhat/types';

import { toGwei } from './hardhat/utils/conversion';

dotenvConfig({ path: resolve(__dirname, '.env') });

export const GAS_PRICE = utils.parseUnits('15', 'gwei');

export const NamedAccounts = {
    __trusted: { default: 0 },
    __special: { default: 1 },
    __special__dotnugg: { default: 2 },
    frank: { default: 3 },
    mac: { default: 4 },
    dee: { default: 5 },
    dennis: { default: 6 },
    charile: { default: 7 },
    deployer: { default: 16 },
    predeployer: { default: 19 }, // used to deploy stuff that will already exist on chain
};

export const NetworkTags = {
    LOCAL: 'LOCAL',
    DEVELOPMENT: 'DEVELOPMENT',
    STAGING: 'STAGING',
    PRODUCTION: 'PRODUCTION',
};

const DefaultNetworkConfig: NetworkUserConfig = {
    accounts: [process.env.TRUSTED_PRIV_KEY, process.env.SPECIAL_PRIV_KEY, process.env.SPECIAL_PRIV_KEY_2],
};

const DefaultLocalNetworkConfig = {
    live: false,
    saveDeployments: true,
    accounts: {
        mnemonic: 'many dark suns glow like gods fury when they eats that nugg',
        accountsBalance: '990000000000000000000',
    },
    // accounts: [
    //     {
    //         privateKey: process.env.TRUSTED_PRIV_KEY,
    //         balance: '990000000000000000000',
    //     },
    //     {
    //         privateKey: process.env.SPECIAL_PRIV_KEY,
    //         balance: '990000000000000000000',
    //     },
    // ],
};

const DefaultStageNetworkConfig = {
    ...DefaultNetworkConfig,
    gasMultiplier: 25,
    tags: [NetworkTags.STAGING],
};

const DefaultProductionNetworkConfig = {
    ...DefaultNetworkConfig,
    tags: [NetworkTags.PRODUCTION],
};
const LocalNetworks: NetworksUserConfig = {
    localhost: {
        ...DefaultLocalNetworkConfig,
    },
    hardhat: {
        ...DefaultLocalNetworkConfig,
        allowUnlimitedContractSize: true,
        // forking: {
        //     enabled: false,
        //     url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}` || '',
        // },
        // loggingEnabled: true,

        gas: 10000000000,
        blockGasLimit: 10000000000000,
        gasPrice: parseInt(GAS_PRICE.toString(), 10),
        saveDeployments: true,
        accounts: [
            {
                privateKey: process.env.TRUSTED_PRIV_KEY,
                balance: '990000000000000000000',
            },
            {
                privateKey: process.env.SPECIAL_PRIV_KEY,
                balance: '0',
            },
            {
                privateKey: process.env.SPECIAL_PRIV_KEY_2,
                balance: '990000000000000000000',
            },
        ],
    },
};

const StagingNetworks: NetworksUserConfig = {
    ropsten: {
        ...DefaultStageNetworkConfig,
        url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 3,
        gasPrice: toGwei('4.9').toNumber(),
    },
    rinkeby: {
        ...DefaultStageNetworkConfig,
        url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 4,
        gasPrice: toGwei('4.9').toNumber(),
    },
    goerli: {
        ...DefaultStageNetworkConfig,
        url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 5,
        gasPrice: toGwei('4.9').toNumber(),
    },
    kovan: {
        ...DefaultStageNetworkConfig,
        url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 42,
        gasPrice: toGwei('4.9').toNumber(),
    },
};

const ProductionNetworks: NetworksUserConfig = {
    mainnet: {
        ...DefaultProductionNetworkConfig,
        url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
        gasPrice: toGwei('40').toNumber(),
        chainId: 1,
    },
};
const HardhatConfig: HardhatUserConfig = {
    defaultNetwork: 'hardhat',
    namedAccounts: NamedAccounts,
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
    },
    typechain: {
        outDir: 'typechain',
        target: 'ethers-v5',
    },
    mocha: {
        timeout: 20000 * 6,
    },

    paths: {
        artifacts: './hardhat/artifacts',
        cache: './hardhat/cache',
        sources: 'src',
        tests: './hardhat/tests',
        deploy: './hardhat/deploy',
        deployments: './hardhat/deployments',
    },
    solidity: {
        compilers: [
            {
                version: '0.8.9',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 10000,
                    },
                },
            },
        ],
    },
    gasReporter: {
        coinmarketcap: process.env.COINMARKETCAP_API_KEY,
        currency: 'USD',
        enabled: true,
        // excludeContracts: ['contracts/libraries/'],
    },
    networks: {
        // ...ProductionNetworks,
        ...StagingNetworks,
        ...LocalNetworks,
    },
    // preprocess: {
    //     eachLine: removeConsoleLog((bre) => bre.network.name !== 'hardhat' && bre.network.name !== 'localhost'),
    // },
    abiExporter: {
        path: './hardhat/abis',
        clear: true,
        flat: true,
        only: ['NuggftV1', 'DotnuggV1'],
        spacing: 2,
    },
    contractSizer: {
        alphaSort: true,
        runOnCompile: true,
        disambiguatePaths: false,
    },
    // docgen: {
    //     path: './docs',
    //     clear: true,
    //     runOnCompile: true,
    // },
    // spdxLicenseIdentifier: {
    //     overwrite: true,
    //     runOnCompile: true,
    // },
    dotnugg: {
        art: '../nuggft-art',
    },
};

export default HardhatConfig;
