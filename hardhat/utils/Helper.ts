import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { ethers } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { NamedAccounts } from '../../hardhat.config';

import { fromEth } from './conversion';

export class Helper {
    // static nuggft: NuggftV1;
    // static dotnugg: IDotnuggV1;
    // static minter: NuggftV1Minter;

    public static chainID: string;

    private static hre: HardhatRuntimeEnvironment;
    public static reversedNamedAccounts: Dictionary<string> = {};

    public static namedSigners: Record<keyof typeof NamedAccounts, SignerWithAddress>;

    static async init(hre: HardhatRuntimeEnvironment) {
        this.hre = hre;

        this.chainID = await hre.getChainId();
        // const dep = await hre.deployments.get('NuggftV1');

        // this.nuggft = await hre.ethers.getContractAt<NuggftV1>('NuggftV1', dep.address);

        // const dep2 = await hre.deployments.get('NuggftV1Minter');

        // this.minter = await hre.ethers.getContractAt<NuggftV1Minter>('NuggftV1Minter', dep2.address);

        this.namedSigners = await hre.ethers.getNamedSigners();

        Object.entries(this.namedSigners).forEach(([k, v]) => {
            this.reversedNamedAccounts[v.address] = k;
        });

        // this.dotnugg = await hre.ethers.getContractAt<IDotnuggV1>(IDotnuggV1__factory.abi, await this.nuggft.dotnuggV1());
    }

    static signer(name: string): SignerWithAddress {
        return this.namedSigners[name];
    }

    // static viewBigNumber = async (desc: string, tx: Promise<BigNumber>) => {
    //     console.log(`calling ${desc} to NuggftV1 on ${this.hre.network.name} @ ${this.nuggft.address}`);

    //     const res = await tx;

    //     console.log('raw: ', res.toString());
    //     console.log('fmt: ', fromEth(res));
    //     console.log('hex: ', res._hex);

    //     return res;
    // };

    static txcount = 0;

    static sendMany = async (desc: string, txs: [Promise<ethers.ContractTransaction>]) => {};

    static send = async (desc: string, tx: Promise<ethers.ContractTransaction>) => {
        const c = this.txcount++;
        console.log(`#################### begin tx ${c} ####################`);
        console.log(`sending ${desc} on ${this.hre.network.name}`);

        const tx2 = await tx;

        return (
            await tx.then(async (data) => {
                const named = this.reversedNamedAccounts[data.from];

                const remainingSenderEth = await this.hre.ethers.provider.getBalance(data.from);

                const host = `https://${data.chainId === 1 ? '' : this.hre.network.name + '.'}etherscan.io`;
                console.log(`tx ${c} sent on ${this.hre.network.name} to ${data.to} .. waiting to be mined... `);
                console.log('------');
                console.log('value sent: ', fromEth(data.value));
                console.log(`sender    : ${named ? '[' + named + ']' : ''} ${data.from} `);
                console.log('eth left  : ', fromEth(remainingSenderEth.sub(data.value)));
                console.log('------');
                // console.log(`from:        ${host}/address/${data.from}`);
                // console.log(`to:          ${host}/address/${data.to}`);
                console.log(`transaction: \n${host}/tx/${data.hash}`);

                return data;
            })
        )
            .wait()
            .then((data) => {
                console.log(`tx ${c} mined in block ${data.blockNumber} with ${data.gasUsed} gas`);
                console.log(`#################### end tx ${c} ####################`);
            });
    };
}
