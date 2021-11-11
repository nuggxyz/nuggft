import { BigNumber } from 'ethers';
import { expect } from 'chai';

import { EpochMathTest } from '../../types';

export enum MockEpochMathStatus {
    'OVER' = 0,
    'ACTIVE' = 1,
    'PENDING' = 2,
}

export type MockEpochMathState = {
    interval: BigNumber;
    genesisBlock: BigNumber;
};

export type MockEpochMathEpoch = {
    id: BigNumber;
    startblock: BigNumber;
    endblock: BigNumber;
    status: MockEpochMathStatus;
};

export class MockEpochMath {
    public static getEpoch = (state: MockEpochMathState, id: BigNumber, blocknum: BigNumber): MockEpochMathEpoch => {
        return {
            id,
            startblock: this.getStartBlockFromId(state, id),
            endblock: this.getEndBlockFromId(state, id),
            status: this.getStatus(state, id, blocknum),
        };
    };

    public static getStatus = (state: MockEpochMathState, id: BigNumber, blocknum: BigNumber): MockEpochMathStatus => {
        if (this.getIdFromBlocknum(state, blocknum).eq(id)) return MockEpochMathStatus.ACTIVE;
        else if (this.getEndBlockFromId(state, id).lt(blocknum)) return MockEpochMathStatus.OVER;
        return MockEpochMathStatus.PENDING;
    };

    public static getStartBlockFromId = (state: MockEpochMathState, id: BigNumber): BigNumber => {
        return id.mul(state.interval).add(state.genesisBlock);
    };

    public static getEndBlockFromId = (state: MockEpochMathState, id: BigNumber): BigNumber => {
        return this.getStartBlockFromId(state, id.add(1)).sub(1);
    };

    public static getIdFromBlocknum = (state: MockEpochMathState, blocknum: BigNumber): BigNumber => {
        return blocknum.sub(state.genesisBlock).div(state.interval);
    };
}

export class MockEpochMathTests {
    public static getEpoch = async (
        contract: EpochMathTest,
        state: MockEpochMathState,
        id: BigNumber,
        blocknum: BigNumber,
    ): Promise<Chai.Assertion> => {
        return expect(await contract.getEpoch(state, id, blocknum)).to.be.deep.equal(
            Object.values(MockEpochMath.getEpoch(state, id, blocknum)),
        );
    };

    public static getStatus = async (
        contract: EpochMathTest,
        state: MockEpochMathState,
        id: BigNumber,
        blocknum: BigNumber,
    ): Promise<Chai.Assertion> => {
        const res = await contract.getStatus(state, id, blocknum);
        return expect(res).to.be.equal(MockEpochMath.getStatus(state, id, blocknum));
    };

    public static getStartBlockFromId = async (
        contract: EpochMathTest,
        state: MockEpochMathState,
        id: BigNumber,
    ): Promise<Chai.Assertion> => {
        return expect(await contract.getStartBlockFromId(state, id)).to.be.equal(MockEpochMath.getStartBlockFromId(state, id));
    };

    public static getEndBlockFromId = async (
        contract: EpochMathTest,
        state: MockEpochMathState,
        id: BigNumber,
    ): Promise<Chai.Assertion> => {
        return expect(await contract.getEndBlockFromId(state, id)).to.be.equal(MockEpochMath.getEndBlockFromId(state, id));
    };

    public static getIdFromBlocknum = async (
        contract: EpochMathTest,
        state: MockEpochMathState,
        blocknum: BigNumber,
    ): Promise<Chai.Assertion> => {
        const res = await contract.getIdFromBlocknum(state, blocknum);
        const res2 = MockEpochMath.getIdFromBlocknum(state, blocknum);
        return expect(res).to.equal(res2);
    };
}
