import { subtask } from 'hardhat/config';
import {
    TASK_COMPILE_GET_COMPILATION_TASKS,
    TASK_COMPILE_SOLIDITY,
    TASK_COMPILE_SOLIDITY_FILTER_COMPILATION_JOBS,
    TASK_COMPILE_SOLIDITY_GET_ARTIFACT_FROM_COMPILATION_OUTPUT,
    TASK_COMPILE_SOLIDITY_GET_DEPENDENCY_GRAPH,
    TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS,
} from 'hardhat/builtin-tasks/task-names';
import {
    ArgumentType,
    CompilerOutput,
    CompilerOutputContract,
    HardhatArguments,
    HardhatRuntimeEnvironment,
    RunSuperFunction,
    SolcBuild,
    TaskArguments,
} from 'hardhat/types';

import { DotNugg } from '../../../dotnugg-core/types';
import { TASK_DEPLOY } from 'hardhat-deploy';

subtask(TASK_COMPILE_SOLIDITY_GET_ARTIFACT_FROM_COMPILATION_OUTPUT).setAction(
    async (
        args: { sourceName: string; contractName: string; contractOutput: CompilerOutputContract; test: string },
        hre: HardhatRuntimeEnvironment,
        runSuper: RunSuperFunction<unknown>,
    ): Promise<void> => {
        // console.log(args.contractOutput.evm.bytecode.object);
        hre.middleware = { test: 'this should not work' };
        return await runSuper(args);
    },
);

// subtask(TASK_COMPILE_SOLIDITY_GET_DEPENDENCY_GRAPH).setAction(
//     async (args: any, hre: HardhatRuntimeEnvironment, runSuper: RunSuperFunction<unknown>): Promise<void> => {
//         console.log(args);

//         // hre.deployments.deploy("DotNugg", );
//         hre.middleware = { test: 'this should not work' };
//         return await runSuper(args);
//     },
// );
