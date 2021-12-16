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
import './tasks/nuggft/delegate';
import './tasks/nuggft/claim';
import './tasks/nuggft/rawProcessUri';

import { resolve } from 'path';

import { config as dotenvConfig } from 'dotenv';
import { utils } from 'ethers';
import { removeConsoleLog } from 'hardhat-preprocessor';
import { HardhatUserConfig, NetworksUserConfig, NetworkUserConfig } from 'hardhat/types';

dotenvConfig({ path: resolve(__dirname, '.env') });

export const GAS_PRICE = utils.parseUnits('5', 'gwei');

export const NamedAccounts = {
    main: { default: 0 },
    dev: { default: 1 },
    charile: { default: 2 },
    frank: { default: 3 },
    mac: { default: 4 },
    dee: { default: 5 },
    dennis: { default: 6 },
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
    accounts: {
        mnemonic: process.env.UNSAFE_PRIVATE_MNEMONIC,
    },
};

const DefaultLocalNetworkConfig = {
    live: false,
    saveDeployments: true,
    accounts: {
        mnemonic: 'many dark suns glow like gods fury when they eats that nugg',
        accountsBalance: '990000000000000000000',
    },
};

const DefaultStageNetworkConfig = {
    ...DefaultNetworkConfig,
    gasMultiplier: 2,
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
        forking: {
            enabled: false,
            url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}` || '',
        },
        loggingEnabled: false,
        gas: 10000000000,
        blockGasLimit: 10000000000,
        gasPrice: parseInt(GAS_PRICE.toString(), 10),
        saveDeployments: false,
    },
};

const StagingNetworks: NetworksUserConfig = {
    ropsten: {
        ...DefaultStageNetworkConfig,
        url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 3,
    },
    rinkeby: {
        ...DefaultStageNetworkConfig,
        url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 4,
    },
    goerli: {
        ...DefaultStageNetworkConfig,
        url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 5,
    },
    kovan: {
        ...DefaultStageNetworkConfig,
        url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 42,
    },
    'moonbase-alphanet': {
        ...DefaultStageNetworkConfig,
        url: 'https://rpc.testnet.moonbeam.network',
        chainId: 1287,
    },

    'poloygon-mumbia': {
        ...DefaultStageNetworkConfig,
        url: `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 80001,
    },
    chapel: {
        ...DefaultStageNetworkConfig,
        url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
        chainId: 97,
    },
    'arbitrum-testnet': {
        ...DefaultStageNetworkConfig,
        url: 'https://kovan3.arbitrum.io/rpc',
        chainId: 79377087078960,
    },
    'heco-testnet': {
        ...DefaultStageNetworkConfig,
        url: 'https://http-testnet.hecochain.com',
        chainId: 256,
    },
    fuji: {
        ...DefaultStageNetworkConfig,
        url: 'https://api.avax-test.network/ext/bc/C/rpc',
        chainId: 43113,
    },
    'harmony-testnet': {
        ...DefaultStageNetworkConfig,
        url: 'https://api.s0.b.hmny.io',
        chainId: 1666700000,
    },
    'okex-testnet': {
        ...DefaultStageNetworkConfig,
        url: 'https://exchaintestrpc.okex.org',
        chainId: 65,
    },
    'fantom-testnet': {
        ...DefaultStageNetworkConfig,
        url: 'https://rpc.testnet.fantom.network',
        chainId: 4002,
    },
};

const ProductionNetworks: NetworksUserConfig = {
    mainnet: {
        ...DefaultProductionNetworkConfig,
        url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
        gasPrice: 120 * 1000000000,
        chainId: 1,
    },
    bsc: {
        ...DefaultProductionNetworkConfig,
        url: process.env.BSC_NODE ? process.env.BSC_NODE : `https://bsc-dataseed.binance.org:443`,
        chainId: 56,
    },
    polygon: {
        ...DefaultProductionNetworkConfig,
        url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
        chainId: 137,
    },
    fantom: {
        ...DefaultProductionNetworkConfig,
        url: 'https://rpcapi.fantom.network',
        chainId: 250,
    },
    xdai: {
        ...DefaultProductionNetworkConfig,
        url: 'https://rpc.xdaichain.com',
        chainId: 100,
    },
    heco: {
        ...DefaultProductionNetworkConfig,
        url: 'https://http-mainnet.hecochain.com',
        chainId: 128,
    },
    avalanche: {
        ...DefaultProductionNetworkConfig,
        url: 'https://api.avax.network/ext/bc/C/rpc',
        chainId: 43114,
        gasPrice: 470000000000,
    },
    harmony: {
        ...DefaultProductionNetworkConfig,
        url: 'https://api.s0.t.hmny.io',
        chainId: 1666600000,
    },
    okex: {
        ...DefaultProductionNetworkConfig,
        url: 'https://exchainrpc.okex.org',
        chainId: 66,
    },
    arbitrum: {
        ...DefaultProductionNetworkConfig,
        url: 'https://arb1.arbitrum.io/rpc',
        chainId: 42161,
        blockGasLimit: 700000,
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
        artifacts: 'artifacts',
        cache: 'cache',
        sources: 'src',
        tests: 'tests',
    },
    solidity: {
        compilers: [
            {
                version: '0.8.9',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 100000,
                    },
                },
            },
            {
                version: '0.6.12',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: '0.6.8',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: '0.7.6',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 800,
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
    preprocess: {
        eachLine: removeConsoleLog((bre) => bre.network.name !== 'hardhat' && bre.network.name !== 'localhost'),
    },
    abiExporter: {
        path: './abis',
        clear: true,
        flat: true,
        only: [],
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
    spdxLicenseIdentifier: {
        overwrite: true,
        runOnCompile: true,
    },
    dotnugg: {
        art: '../nuggft-art',
    },
};

export default HardhatConfig;
