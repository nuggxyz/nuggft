# Nugg Fungible Token V1 Smart Contracts

> **Warning**
> this code is yet to be deployed and licensed under BUSL-1.1

[![forge](https://github.com/nuggxyz/nuggft-v1-core/actions/workflows/forge.yaml/badge.svg)](https://github.com/nuggxyz/nuggft-v1-core/actions/workflows/forge.yaml)

the core logic and smart contracts for nuggft v1

-   written in solidity
-   (to be soon) deployed on ethereum

## Deployments

| network | status            | address                                      |
| ------- | ----------------- | -------------------------------------------- |
| mainnet | 🔨 pending        | `TBD`                                        |
| ropsten | 🚫 not up to date | `0x69420000e30fb9095ec2a254765ff919609c1875` |
| rinkeby | 🚫 not up to date | `0x6942000062516fab40349b13131c34346c0446e8` |
| goerli  | ✅ up to date     | `0x69420000ac2bdb9be0d3ad607dc85b1c10f653ac` |
| kovan   | 🚫 not up to date | `0x694200002e1540157c5fe987705e418ee0a9577d` |

## m1 configuration

```bash
# to install apple silicon version of solc
brew install solidity

# each shell you want to use forge in
export SOLC_PATH=/opt/homebrew/Cellar/solidity/0.8.13/bin/solc
```

## bug bounty

This repository is subject to the nuggft v1 bug bounty program, per the terms defined [here](./bug-bounty.md).

## Licensing

The primary license for NuggftV1 Core is the Business Source License 1.1 (`BUSL-1.1`), see [`LICENSE.txt`](./LICENSE.txt).

### Exceptions

-   All files in `src/_test` are unlicensed
