import { subtask } from 'hardhat/config';
import { TASK_COMPILE_SOLIDITY_GET_ARTIFACT_FROM_COMPILATION_OUTPUT } from 'hardhat/builtin-tasks/task-names';

subtask(TASK_COMPILE_SOLIDITY_GET_ARTIFACT_FROM_COMPILATION_OUTPUT).setAction(async (args: any, hre: any, runSuper: any): Promise<void> => {
    console.log({ args });
});
