import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { BigNumber, ethers } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { fromEth } from '../tests/hardhat/lib/shared/conversion';
import { IDotnuggV1, IDotnuggV1__factory, NuggftV1 } from '../typechain';

export class TaskHelper {
    static nuggft: NuggftV1;
    static dotnugg: IDotnuggV1;

    private static hre: HardhatRuntimeEnvironment;
    public static reversedNamedAccounts: Dictionary<string> = {};

    public static namedSigners: Dictionary<SignerWithAddress> = {};

    static async init(hre: HardhatRuntimeEnvironment) {
        this.hre = hre;

        const dep = await hre.deployments.get('NuggftV1');

        this.nuggft = await hre.ethers.getContractAt<NuggftV1>('NuggftV1', dep.address);

        this.namedSigners = await hre.ethers.getNamedSigners();

        Object.entries(this.namedSigners).forEach(([k, v]) => {
            this.reversedNamedAccounts[v.address] = k;
        });

        this.dotnugg = await hre.ethers.getContractAt<IDotnuggV1>(IDotnuggV1__factory.abi, await this.nuggft.dotnuggV1());
    }

    static signer(name: string): SignerWithAddress {
        return this.namedSigners[name];
    }

    static viewBigNumber = async (desc: string, tx: Promise<BigNumber>) => {
        console.log(`calling ${desc} to NuggftV1 on ${this.hre.network.name} @ ${this.nuggft.address}`);

        const res = await tx;

        console.log('raw: ', res.toString());
        console.log('fmt: ', fromEth(res));
        console.log('hex: ', res._hex);

        return res;
    };

    static txcount = 0;

    static send = async (desc: string, tx: Promise<ethers.ContractTransaction>) => {
        const c = this.txcount++;
        console.log(`#################### begin tx ${c} ####################`);
        console.log(`sending ${desc} to NuggftV1 on ${this.hre.network.name} @ ${this.nuggft.address}`);
        return (
            await tx.then(async (data) => {
                const named = this.reversedNamedAccounts[data.from];

                const remainingSenderEth = await this.hre.ethers.provider.getBalance(data.from);

                const host = `https://${data.chainId === 1 ? '' : this.hre.network.name + '.'}etherscan.io`;
                console.log(`tx ${c} sent on ${this.hre.network.name} to ${data.to} .. waiting to be mined... `);
                console.log('------');
                console.log('value sent: ', fromEth(data.value));
                console.log(`sender    : ${named ? '[' + named + ']' : ''} ${data.from} `);
                console.log('eth left  : ', fromEth(remainingSenderEth));
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
