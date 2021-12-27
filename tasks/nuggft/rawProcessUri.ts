import { ethers } from 'ethers';
import { task } from 'hardhat/config';

import { dotnugg } from '../../../dotnugg-sdk/src';
import { IDotnuggV1Processor } from '../../typechain';

task('dotnuggToRaw', 'runs dotnuggToRaw')
    .addParam('id', 'the token to get')
    .setAction(async (args, hre) => {
        const dn = (await hre.ethers.getContractAt(
            'IDotnuggV1Processor',
            '0x0c865E650E2B5598AFFA09fB9D505635b0b8E007',
        )) as IDotnuggV1Processor;
        const start = new Date();
        const hrstart = process.hrtime();
        hre.deployments.log('Getting pending token uri...');
        const uri = await dn.dotnuggToRaw('0x13647CAeA4243442f57D4B0f57694f554cc74987', args.id, ethers.constants.AddressZero, 63, 10);
        if (uri) {
            const end = new Date().getTime() - start.getTime(),
                hrend = process.hrtime(hrstart);
            console.info('Execution time: %dms', end);
            console.info('Execution time (hr): %ds %dms', hrend[0], hrend[1] / 1000000);
            // hre.deployments.log(uri);
            // hre.deployments.log(DecodeDotNuggBase64ToPngBase64(DecodeBase64ToJSON(uri).image, 10));
        }
        dotnugg.log.Console.drawConsole(uri);
        dotnugg.log.Console.drawSvg(uri, 10);
    });
