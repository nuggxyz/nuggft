import { ethers } from 'ethers';
import { TransactionReceipt } from '@ethersproject/providers';
import { Interface } from 'ethers/lib/utils';

export const buildBytecode = (constructorTypes: ethers.utils.ParamType[], constructorArgs: any[], contractBytecode: string) =>
    `${contractBytecode}${encodeParams(constructorTypes, constructorArgs).slice(2)}`;

export const buildCreate2Address = (
    address: string,
    saltHex: string,
    byteCode: string,
    dataTypes: ethers.utils.ParamType[],
    data: any[],
) => {
    return ethers.utils.getCreate2Address(
        address,
        saltHex,
        ethers.utils.keccak256([byteCode, ethers.utils.defaultAbiCoder.encode(dataTypes, data)].map((x) => x.replace('0x', '')).join('')),
    );
};

export const numberToUint256 = (value: number) => {
    const hex = value.toString(16);
    return `0x${'0'.repeat(64 - hex.length)}${hex}`;
};

export const saltToHex = (salt: string | number) => ethers.utils.id(salt.toString());

export const encodeParam = (dataType: any, data: any) => {
    const abiCoder = ethers.utils.defaultAbiCoder;
    return abiCoder.encode([dataType], [data]);
};

export const encodeParams = (dataTypes: ethers.utils.ParamType[], data: any[]) => {
    const abiCoder = ethers.utils.defaultAbiCoder;
    return abiCoder.encode(dataTypes, data);
};

// export const isContract = async (address: string, provider: ethers.Provider) => {
//     const code = await provider.getCode(address);
//     return code.slice(2).length > 0;
// };

export const parseEvents = (receipt: TransactionReceipt, contractInterface: Interface, eventName: string) => {
    return receipt.logs.map((log) => contractInterface.parseLog(log)).filter((log) => log.name === eventName);
};
