import { task } from 'hardhat/config';

import { TaskHelper } from '..';

// import { IDotnuggV1Processor, NuggftV1 } from '../../typechain';

task('raw', 'runs raw')
    .addParam('tokenid', 'the token to get')
    .setAction(async (args, hre) => {
        // const dn = (await hre.ethers.getContractAt(
        //     'IDotnuggV1Processor',
        //     '0xed544dcDA2d612FcEC0Ca4c15569e3dC0b05626E',
        // )) as IDotnuggV1Processor;
        await TaskHelper.init(hre);

        const start = new Date();
        const hrstart = process.hrtime();
        hre.deployments.log('Getting pending token uri...');
        // const { res } = await dn.dotnuggToUri(
        //     '0xb19ae2d44f25cbbbae625310f367ab9fb49cde92',
        //     args.id,
        //     '0xed544dcDA2d612FcEC0Ca4c15569e3dC0b05626E',
        //     63,
        //     10,
        // );
        const res = await TaskHelper.dotnugg.img(
            TaskHelper.nuggft.address,
            args.tokenid,
            hre.ethers.constants.AddressZero,
            false,
            false,
            false,
            false,
            '0x00',
        );

        // fix.processor.img(fix.implementer.address, 69, constants.AddressZero, false, false, false, false, '0x00')
        if (res) {
            console.log(res);
            const end = new Date().getTime() - start.getTime(),
                hrend = process.hrtime(hrstart);
            console.info('Execution time: %dms', end);
            console.info('Execution time (hr): %ds %dms', hrend[0], hrend[1] / 1000000);
            // hre.deployments.log(res);
            // hre.deployments.log(DecodeDotNuggBase64ToPngBase64(DecodeBase64ToJSON(res).image, 10));
        }
        // console.log(res);
        // // dotnugg.log.Console.drawConsole(res);
        // // dotnugg.log.Console.drawSvg(res, 10);
    });
