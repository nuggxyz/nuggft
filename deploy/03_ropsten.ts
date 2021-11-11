import { ethers } from 'hardhat';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

import { NamedAccounts } from '../hardhat.config';
import {
    fromEth,
    toEth,
} from '../tests/shared/conversion';
import {
    ensureERC1820,
    ensureWETH,
} from '../tests/shared/deployment';
import {
    DotNugg,
    DotNuggNuggIn,
    NuggETHRelay,
    NuggSeller,
    SvgNuggIn,
} from '../types';
import { NuggETH } from '../types/NuggETH';
import { NuggFT } from '../types/NuggFT.d';
import { NuggMinter } from '../types/NuggMinter.d';

const deployment = async (hre: HardhatRuntimeEnvironment) => {
    const chainID = await hre.getChainId();
    if (chainID === '3' || chainID === '31337') {
        const accounts = (await hre.getNamedAccounts()) as Record<keyof typeof NamedAccounts, string>;
        await ensureERC1820();
        const weth = await ensureWETH();

        const eoaDeployer = accounts.deployer;
        hre.deployments.log('EOA deployer: ', accounts.deployer);
        // const args = new ethers.utils.AbiCoder().encode(
        //     ['bytes32', 'bytes32', 'bytes32', 'bytes32', 'bytes32', 'address'],
        //     [
        //         '0x0000000000000000000000000000000000000000000000000000000000201a14',
        //         '0x000000000000000000000000000000000000000000000000000000000056c2ef',
        //         '0x0000000000000000000000000000000000000000000000000000000001def3a9',
        //         '0x0000000000000000000000000000000000000000000000000000000001dc6eaf',
        //         '0x0000000000000000000000000000000000000000000000000000000000c965d4',
        //         weth.address,
        //     ],
        // );

        const salts = [
            '0x0000000000000000000000000000000000000000000000000000000000b7d0eb',
            '0x00000000000000000000000000000000000000000000000000000000021facbb',
            '0x00000000000000000000000000000000000000000000000000000000000303f0',
            '0x000000000000000000000000000000000000000000000000000000000010b412',
            '0x0000000000000000000000000000000000000000000000000000000000329ee9',
            '0x0000000000000000000000000000000000000000000000000000000003971356',
            '0x0000000000000000000000000000000000000000000000000000000003971356',
        ];

        const nuggethDeployement = await hre.deployments.deploy('NuggETH', {
            from: eoaDeployer,
            log: true,
            args: [],
            deterministicDeployment: salts[0],
        });

        const relayDeployment = await hre.deployments.deploy('NuggETHRelay', {
            from: eoaDeployer,
            log: true,
            args: [],
            deterministicDeployment: salts[1],
        });

        const dotnuggDeployment = await hre.deployments.deploy('DotNugg', {
            from: eoaDeployer,
            log: true,
            args: [],
            deterministicDeployment: salts[2],
        });

        const nuggFTDeployement = await hre.deployments.deploy('NuggFT', {
            from: eoaDeployer,
            log: true,
            args: [],
            deterministicDeployment: salts[3],
        });

        const minterDeployment = await hre.deployments.deploy('NuggMinter', {
            from: eoaDeployer,
            log: true,
            args: [],
            deterministicDeployment: salts[4],
        });

        const sellerDeployment = await hre.deployments.deploy('NuggSeller', {
            from: eoaDeployer,
            log: true,
            args: [],
            deterministicDeployment: salts[5],
        });

        const nugginDeployment = await hre.deployments.deploy('SvgNuggIn', {
            from: eoaDeployer,
            log: true,
            args: [],
            deterministicDeployment: salts[6],
        });

        const testNuggInDeployment = await hre.deployments.deploy('DotNuggNuggIn', {
            from: eoaDeployer,
            log: true,
            args: [],
            deterministicDeployment: salts[6],
        });

        hre.deployments.log('NuggFT Deployment Complete at address: ', nuggFTDeployement.address);
        hre.deployments.log('NuggETH Deployment Complete at address: ', nuggethDeployement.address);
        hre.deployments.log('NuggMinter Deployment Complete at address: ', minterDeployment.address);
        hre.deployments.log('NuggSeller Deployment Complete at address: ', sellerDeployment.address);
        hre.deployments.log('NuggETHRelay Deployment Complete at address: ', relayDeployment.address);
        hre.deployments.log('DotNugg Deployment Complete at address: ', dotnuggDeployment.address);
        hre.deployments.log('NuggIn Deployment Complete at address: ', nugginDeployment.address);
        hre.deployments.log('NuggIn Deployment Complete at address: ', testNuggInDeployment.address);

        // const father = await hre.ethers.getContractAt<NuggFather>('NuggFather', fatherDeployment.address);
        //
        const nuggft = await hre.ethers.getContractAt<NuggFT>('NuggFT', nuggFTDeployement.address);
        //

        const nuggeth = await hre.ethers.getContractAt<NuggETH>('NuggETH', nuggethDeployement.address);
        //

        const dotnugg = await hre.ethers.getContractAt<DotNugg>('DotNugg', dotnuggDeployment.address);
        const nuggin = await hre.ethers.getContractAt<SvgNuggIn>('SvgNuggIn', nugginDeployment.address);
        const testNuggin = await hre.ethers.getContractAt<DotNuggNuggIn>('DotNuggNuggIn', testNuggInDeployment.address);

        //

        const minter = await hre.ethers.getContractAt<NuggMinter>('NuggMinter', minterDeployment.address);
        //

        const seller = await hre.ethers.getContractAt<NuggSeller>('NuggSeller', sellerDeployment.address);
        //

        const relay = await hre.ethers.getContractAt<NuggETHRelay>('NuggETHRelay', relayDeployment.address);

        const tx1args = new ethers.utils.AbiCoder().encode(
            ['bytes', 'bytes[]', 'bytes[]'],
            [
                '0x6e756767000607000301020202030204030502',
                [
                    '0x6e75676701080d063dc17320200001ffffffff0101a84b1eff0201c96619ff0301f9b042ff0401f49f35ff0501f19325ff0601eb8a12ff0701000000ff000f07050502020001010b0b000400000001020f1101010000000103080a000000000001040f0b020200000001050f050404010100012e202e202e202e202e202e0a010c2e0a2e080102030104040303060301022e092e080101030104070302060301012e092e080101030204060303060201012e092e080101030204060304060201012e082e07010203010003040405010003030201012e082e070101030200010701000104040301000107010001030201012e082e0701010302000304050003030201012e082e07010103050405030501012e082e0701010302050203010406030401012e082e070101030504060501030301012e082e070101030604050502030201012e082e070101030507050402030301012e082e07010103050409030101012e082e0701010306040901012e082e08010103030502040901012e082e08010103050501040701022e082e080101030505020402060401012e092e0801010201030404010501060601012e092e08010102010601030304030604020101012e092e08010102020601030204030604020101012e092e0801030601030204020603020201012e0a2e0a010b2e0b2e202e202e202e20',
                    '0x6e75676701080d063dc17320200001ffffffff0101a84b1eff0201c96619ff0301f9b042ff0401f49f35ff0501f19325ff0601eb8a12ff0701000000ff000f07050502020001010b0b000400000001020f1101010000000103080a000000000001040f0b020200000001050f050404010100012e202e202e202e202e202e0a010c2e0a2e080102030104040303060301022e092e080101030104070302060301012e092e080101030204060303060201012e092e080101030204060304060201012e082e07010203010003040405010003030201012e082e070101030200010701000104040301000107010001030201012e082e0701010302000304050003030201012e082e07010103050405030501012e082e0701010302050203010406030401012e082e070101030504060501030301012e082e070101030604050502030201012e082e070101030507050402030301012e082e07010103050409030101012e082e0701010306040901012e082e08010103030502040901012e082e08010103050501040701022e082e080101030505020402060401012e092e0801010201030404010501060601012e092e08010102010601030304030604020101012e092e08010102020601030204030604020101012e092e0801030601030204020603020201012e0a2e0a010b2e0b2e202e202e202e20',
                    '0x6e75676701080d063dc17320200001ffffffff0101a84b1eff0201c96619ff0301f9b042ff0401f49f35ff0501f19325ff0601eb8a12ff0701000000ff000f07050502020001010b0b000400000001020f1101010000000103080a000000000001040f0b020200000001050f050404010100012e202e202e202e202e202e0a010c2e0a2e080102030104040303060301022e092e080101030104070302060301012e092e080101030204060303060201012e092e080101030204060304060201012e082e07010203010003040405010003030201012e082e070101030200010701000104040301000107010001030201012e082e0701010302000304050003030201012e082e07010103050405030501012e082e0701010302050203010406030401012e082e070101030504060501030301012e082e070101030604050502030201012e082e070101030507050402030301012e082e07010103050409030101012e082e0701010306040901012e082e08010103030502040901012e082e08010103050501040701022e082e080101030505020402060401012e092e0801010201030404010501060601012e092e08010102010601030304030604020101012e092e08010102020601030204030604020101012e092e0801030601030204020603020201012e0a2e0a010b2e0b2e202e202e202e20',
                ],
                [
                    '0x6e756767020210021c22200e050503000003b261dc550103444444ff52014c012e0201024c010101520101022e052e0101034c0101015201000101022e0401044c01010152010101000101012e0401044c010101520101062e0101044c01010152010107',
                    '0x6e756767020210041c232413050903000003555555ff0103b261dc5552006c0172014c002e0600024c010001520100022e062e05000201016c0101017201010100022e0500022e0300034c010101520100032e03000200084c0101015201000800084c01000152010008',
                    '0x6e75676702011004162b1e08070402050002000000ff722e4c0052006c2e2e0200016c010001720100012e012e0200016c010001720100012e012e0100024c0100015201000200034c0100015201000200022e016c012e0172012e0200022e016c012e0172012e0200012e026c012e0172012e02',
                    '0x6e756767020210041c4d240b0b0705050002000000ff0102000000ff4c0052006c2e722e2e02010100034c012e01720100012e012e010001010200024c010001520100022e010001010100034c0100015201010100012e01000401014c010001520101012e0100064c0100015201000200064c01000152010002000201010001010100014c010001520100012e0100066c012e0172012e022e0100056c012e0172012e022e0100056c012e0172012e022e0400012e016c012e0172012e02',
                    '0x6e75676702011004161d1e08050400050002000000ff722e4c0052006c2e2e0100024c0100015201000200034c0100015201000200022e016c012e0172012e0200022e016c012e0172012e0200012e026c012e0172012e02',
                    '0x6e756767020210001c121c0b040501020002855114440102000000ff2e0200072e0200012e010001010500012e01000100032e0200012e0200032e0500012e05',
                    '0x6e756767020210001c0e1c07060301020002855114440102000000ff000700010105000100072e0100052e012e0200032e022e0300012e03',
                    '0x6e756767020210041c29240e050702040003000000ff0103855114444c0052006c2e722e2e0100056c012e01720100052e010001010300016c012e0172010001010300010002010300014c01000152010001010300012e010001010300016c012e0172010001010300012e0100056c012e0172010005',
                    '0x6e7567670201100216051a05010200020002f87303ff4c00520000014c01000152010001',
                    '0x6e756767020310022237260d070403010002fb1a06ff0102f85c0fff0202ffdb3cff5201722e2e0400012e0172012e0100012e042e0400012e0172012e0100012e042e0300010101000172010001010100012e030001010302010101520101010201010300012e0300010101000172010001010100012e032e0400012e0172012e0100012e042e0400012e0172012e0100012e04',
                ],
            ],
        );

        if (!(await nuggft.launched())) {
            hre.deployments.log('Launching NuggFT...');
            let ltx = await nuggft
                //

                .connect(await hre.ethers.getNamedSigner('deployer'))
                .launch(
                    new hre.ethers.utils.AbiCoder().encode(
                        ['address', 'address', 'address', 'address', 'address'],
                        [nuggeth.address, dotnugg.address, minter.address, seller.address, nuggin.address],
                    ),
                );
            await ltx.wait();

            let tx1 = await nuggft
                //

                .connect(await hre.ethers.getNamedSigner('deployer'))
                .tx1(tx1args);
            await tx1.wait();
        }
        hre.deployments.log('NuggFT launch status: ', await nuggft.launched());

        if (!(await nuggft.launched())) {
            hre.deployments.log('Launching NuggFT...');
            let ltx = await nuggft
                //

                .connect(await hre.ethers.getNamedSigner('deployer'))
                .launch(
                    new hre.ethers.utils.AbiCoder().encode(
                        ['address', 'address', 'address', 'address', 'address'],
                        [nuggeth.address, dotnugg.address, minter.address, seller.address, nuggin.address],
                    ),
                );
            await ltx.wait();
        }
        hre.deployments.log('NuggFT launch status: ', await nuggft.launched());
        if (!(await nuggeth.launched())) {
            hre.deployments.log('Launching NuggETH...');
            const ltx = await nuggeth
                //

                .connect(await ethers.getNamedSigner('deployer'))
                .launch(new hre.ethers.utils.AbiCoder().encode(['address', 'address'], [relay.address, weth.address]));
            await ltx.wait();
        }
        hre.deployments.log('NuggETH launch status: ', await nuggeth.launched());

        if (!(await minter.launched())) {
            hre.deployments.log('Launching NuggMinter...');
            const ltx = await minter
                //

                .connect(await hre.ethers.getNamedSigner('deployer'))
                .launch(
                    new ethers.utils.AbiCoder().encode(['address', 'address', 'address'], [nuggft.address, nuggeth.address, weth.address]),
                );
            await ltx.wait();
        }
        hre.deployments.log('NuggMinter launch status: ', await minter.launched());

        if (!(await seller.launched())) {
            hre.deployments.log('Launching NuggSeller...');
            const ltx = await seller
                //

                .connect(await hre.ethers.getNamedSigner('deployer'))
                .launch(
                    new ethers.utils.AbiCoder().encode(['address', 'address', 'address'], [nuggft.address, nuggeth.address, weth.address]),
                );
            await ltx.wait();
        }
        hre.deployments.log('NuggSeller launch status: ', await seller.launched());

        if (!(await relay.launched())) {
            hre.deployments.log('Launching NuggETHRelay...');
            const ltx = await relay

                .connect(await hre.ethers.getNamedSigner('deployer'))
                .launch(new ethers.utils.AbiCoder().encode(['address', 'address'], [nuggeth.address, weth.address]));
            await ltx.wait();
        }
        hre.deployments.log('NuggETHRelay launch status: ', await relay.launched());

        hre.deployments.log('Dev depositing value into NuggETH... ');
        hre.deployments.log('Total supply before: ', fromEth(await nuggeth.totalSupply()));

        const tx0 = await nuggeth.connect(await hre.ethers.getNamedSigner('dev')).deposit({ value: toEth('.001') });
        hre.deployments.log('tx sent... waiting to be mined... ', tx0.hash);
        await tx0.wait();
        hre.deployments.log('Total supply after: ', fromEth(await nuggeth.totalSupply()));
        hre.deployments.log('Dev balance after:', fromEth(await nuggeth.balanceOf(accounts.dev)));

        hre.deployments.log('Dee placing a bid... ');

        const tx = await minter.connect(await hre.ethers.getNamedSigner('dee')).placeBid(0, toEth('.002'), 0, { value: toEth('.002') });
        hre.deployments.log('tx sent... waiting to be mined... ', tx.hash);
        await tx.wait();
        hre.deployments.log('Total supply after: ', fromEth(await nuggeth.totalSupply()));
        hre.deployments.log('Dev balance after:  ', fromEth(await nuggeth.balanceOf(accounts.dev)));

        // if (res) {
        var start = new Date();
        var hrstart = process.hrtime();

        hre.deployments.log('Getting pending token uri...');
        // const test = await nuggft['tokenURI(uint256,address)'](0, testNuggInDeployment.address);

        // if (test) {
        //     var end = new Date().getTime() - start.getTime(),
        //         hrend = process.hrtime(hrstart);

        //     console.info('Execution time: %dms', end);
        //     console.info('Execution time (hr): %ds %dms', hrend[0], hrend[1] / 1000000);
        //     hre.deployments.log(test);
        //     // hre.deployments.log(DecodeDotNuggBase64ToPngBase64(DecodeBase64ToJSON(uri).image, 10));
        // }
        const uri = await nuggft['tokenURI(uint256)'](0);
        if (uri) {
            var end = new Date().getTime() - start.getTime(),
                hrend = process.hrtime(hrstart);

            console.info('Execution time: %dms', end);
            console.info('Execution time (hr): %ds %dms', hrend[0], hrend[1] / 1000000);
            hre.deployments.log(uri);
            // hre.deployments.log(DecodeDotNuggBase64ToPngBase64(DecodeBase64ToJSON(uri).image, 10));
        }
    }
};

export const tags = ['Haff'];

export default deployment;

// hre.deployments.log('Dev depositing value into NuggETH... ');
// hre.deployments.log('Total supply before: ', fromEth(await nuggeth.totalSupply()));
// const tx3 = await nuggeth.connect(await hre.ethers.getNamedSigner('frank')).deposit({ value: toEth('200.255445554778') });
// hre.deployments.log('tx sent... waiting to be mined... ', tx0.hash);
// tx3.wait();
// hre.deployments.log('Total supply after: ', fromEth(await nuggeth.totalSupply()));
// hre.deployments.log('Dev balance after:', fromEth(await nuggeth.balanceOf(accounts.dev)));

// hre.deployments.log('Dee placing a bid... ');
// const tx4 = await auction.connect(await hre.ethers.getNamedSigner('dee')).placeBid(0, { value: toEth('100.876876875685') });
// hre.deployments.log('tx sent... waiting to be mined... ', tx.hash);
// await tx4.wait();
// hre.deployments.log('Total supply after: ', fromEth(await nuggeth.totalSupply()));
// hre.deployments.log('Dev balance after:  ', fromEth(await nuggeth.balanceOf(accounts.dev)));

// hre.deployments.log('Dee placing a bid... ');
// const tx2 = await auction.connect(await hre.ethers.getNamedSigner('mac')).placeBid(0, { value: toEth('450.876876875686') });
// hre.deployments.log('tx sent... waiting to be mined... ', tx.hash);
// await tx2.wait();
// hre.deployments.log('Total supply after: ', fromEth(await nuggeth.totalSupply()));
// hre.deployments.log('Dev balance after:  ', fromEth(await nuggeth.balanceOf(accounts.dev)));
// hre.deployments.log('Frank balance after:  ', fromEth(await nuggeth.balanceOf(accounts.frank)));
// hre.deployments.log(
//     'Dev + Frank balance after:  ',
//     fromEth((await nuggeth.balanceOf(accounts.dev)).add(await nuggeth.balanceOf(accounts.frank))),
// );
