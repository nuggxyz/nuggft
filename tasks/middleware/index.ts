import { subtask } from 'hardhat/config';
import { TASK_COMPILE_SOLIDITY_GET_ARTIFACT_FROM_COMPILATION_OUTPUT } from 'hardhat/builtin-tasks/task-names';
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

subtask(TASK_COMPILE_SOLIDITY_GET_ARTIFACT_FROM_COMPILATION_OUTPUT).setAction(
    async (
        args: { sourceName: string; contractName: string; contractOutput: CompilerOutputContract; test: string },
        hre: HardhatRuntimeEnvironment,
        runSuper: RunSuperFunction<unknown>,
    ): Promise<void> => {
        console.log(args.contractOutput.evm.bytecode.object);
        hre.middleware = { test: 'this should not work' };
        return await runSuper(args);
    },
);
