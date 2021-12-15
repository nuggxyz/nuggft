import { task } from 'hardhat/config';

task('accounts', 'Prints the list of accounts', async (args, hre) => {
    //@ts-ignore
    const accounts = await hre.ethers.getSigners();
    // const wallet = hre.ethers.Wallet.fromMnemonic(
    //     '',
    //     "m/44'/60'/0'/0/1",
    // );

    // console.log(wallet.privateKey);
    // console.log(wallet.publicKey);
    // console.log(wallet.address);

    // for (const account of accounts) {
    //     console.log(account);
    //     console.log(wallet.privateKey);
    // }
});
