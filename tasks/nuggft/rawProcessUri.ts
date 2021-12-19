import { task } from 'hardhat/config';

task('rawProcessUri', 'runs rawProcessUri')
    .addParam('id', 'the token to get')
    .setAction(async (args, hre) => {
        // const nuggft = await hre.ethers.getContractAt('NuggFT', '0x726d53FD72Fc16DcF4C62CE098e4A94705f1EC5F');
        // const start = new Date();
        // const hrstart = process.hrtime();
        // hre.deployments.log('Getting pending token uri...');
        // const uri = await nuggft.rawProcessURI(args.id);
        // if (uri) {
        //     const end = new Date().getTime() - start.getTime(),
        //         hrend = process.hrtime(hrstart);
        //     console.info('Execution time: %dms', end);
        //     console.info('Execution time (hr): %ds %dms', hrend[0], hrend[1] / 1000000);
        //     // hre.deployments.log(uri);
        //     // hre.deployments.log(DecodeDotNuggBase64ToPngBase64(DecodeBase64ToJSON(uri).image, 10));
        // }
        // dotnugg.log.Console.drawConsole(uri);
        // dotnugg.log.Console.drawSvg(uri, 10);
    });
