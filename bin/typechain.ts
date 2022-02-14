import { runTypeChain, glob } from 'typechain';

async function main() {
    const cwd = process.cwd();
    // find all files matching the glob
    const allFiles = glob(cwd, [`${config.paths.artifacts}/!(build-info)/**/+([a-zA-Z0-9_]).json`]);

    const result = await runTypeChain({
        cwd,
        filesToProcess: allFiles,
        allFiles,
        outDir: 'out directory',
        target: 'target name',
    });
}

main().catch(console.error);
