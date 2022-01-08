import { ethers } from 'ethers';

export class TxSender {
    static txcount = 0;

    static send = async (tx: Promise<ethers.ContractTransaction>) => {
        const c = this.txcount++;
        return (
            await tx.then((data) => {
                console.log(`tx${c} sent.. waiting to be mined... `, data.hash);
                return data;
            })
        )
            .wait()
            .then((data) => {
                console.log(`tx${c} mined in block `, data.blockNumber);
            });
    };
}
