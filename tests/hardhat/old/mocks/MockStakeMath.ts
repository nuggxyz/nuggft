import { BigNumber } from 'ethers';

import { fromEth, BINARY_128 } from '../shared/conversion';
import { v2 } from '../shared/general';
import { StakeMathTest } from '../../types';
import { expect } from '../shared/expect';

import { MockQuadMath } from './MockQuadMath';

export type MockStakeMath2Position = {
    rOwned: BigNumber;
};

export type MockStakeMath2State = {
    tSupply: BigNumber;
    rSupply: BigNumber;
};

export class MockStakeMath2 {
    private static _safeRtoT = (state: MockStakeMath2State, rAmount: BigNumber): BigNumber => {
        // console.log('JS r->t:', fromEth(rAmount), fromEth(state.tSupply), fromEth(state.rSupply));

        return MockQuadMath.mulDiv(rAmount, state.tSupply, state.rSupply);
    };

    private static _safeTtoR = (state: MockStakeMath2State, tAmount: BigNumber): BigNumber => {
        // console.log('JS t->r:', fromEth(tAmount), fromEth(state.tSupply), fromEth(state.rSupply));

        return MockQuadMath.mulDiv(tAmount, state.rSupply, state.tSupply);
    };

    private static _safeTtoRRoundingUp = (state: MockStakeMath2State, tAmount: BigNumber): BigNumber => {
        // console.log('JS t->r:', fromEth(tAmount), fromEth(state.tSupply), fromEth(state.rSupply));

        return MockQuadMath.mulDivRoundingUp(tAmount, state.rSupply, state.tSupply);
    };

    private static _safeRtoTRoundingUp = (state: MockStakeMath2State, rAmount: BigNumber): BigNumber => {
        return MockQuadMath.mulDivRoundingUp(rAmount, state.tSupply, state.rSupply);
    };

    public static getBalance = (state: MockStakeMath2State, pos: MockStakeMath2Position): BigNumber => {
        return this._safeRtoTRoundingUp(state, pos.rOwned);
    };

    public static getOwnershipX128 = (state: MockStakeMath2State, pos: MockStakeMath2Position): BigNumber => {
        return MockQuadMath.mulDivRoundingUp(pos.rOwned, BINARY_128, state.rSupply);
    };

    public static applyShareIncrease = (
        state: MockStakeMath2State,
        pos: MockStakeMath2Position,
        tAmount: BigNumber,
    ): [MockStakeMath2State, MockStakeMath2Position] => {
        console.log('JS BEFORE', fromEth(tAmount), fromEth(state.tSupply), fromEth(state.rSupply));

        // invariant(tAmount.gt(0), 'STAKE:SI:0');
        const amountR = this._safeTtoRRoundingUp(state, tAmount);
        pos.rOwned = pos.rOwned.add(amountR);
        state.rSupply = state.rSupply.add(amountR);
        state.tSupply = state.tSupply.add(tAmount);
        return [state, pos];
    };

    public static applyShareDecrease = (
        state: MockStakeMath2State,
        pos: MockStakeMath2Position,
        tAmount: BigNumber,
    ): [MockStakeMath2State, MockStakeMath2Position] => {
        const amountR = this._safeTtoR(state, tAmount);
        pos.rOwned = pos.rOwned.sub(amountR);
        state.rSupply = state.rSupply.sub(amountR);
        state.tSupply = state.tSupply.sub(tAmount);
        return [state, pos];
    };

    public static applyRewardIncrease = (state: MockStakeMath2State, amount: BigNumber): MockStakeMath2State => {
        state.tSupply = state.tSupply.add(amount);
        return state;
    };
}

export class MockStakeMathTests {
    public errorChecks: number;
    public successChecks: number;

    constructor() {
        this.errorChecks = 0;
        this.successChecks = 0;
    }

    public getBalance = async (
        contract: StakeMathTest,
        state: MockStakeMath2State,
        position: MockStakeMath2Position,
    ): Promise<Chai.AsyncAssertion> => {
        let mock, con;

        try {
            con = contract.getBalance({ ...state }, { ...position });
            mock = MockStakeMath2.getBalance({ ...state }, { ...position });
        } catch (e: any) {
            this.errorChecks++;
            return expect(con).to.be.revertedWith(e.message.replace('Invariant failed: ', ''));
        }
        return expect(await con).to.deep.equal(mock) as Chai.AsyncAssertion;
    };

    public getOwnershipX128 = async (
        contract: StakeMathTest,
        state: MockStakeMath2State,
        position: MockStakeMath2Position,
    ): Promise<Chai.AsyncAssertion> => {
        let mock, con;

        try {
            con = contract.getOwnershipX128({ ...state }, { ...position });
            mock = MockStakeMath2.getOwnershipX128({ ...state }, { ...position });
        } catch (e: any) {
            this.errorChecks++;
            return expect(con).to.be.revertedWith(e.message.replace('Invariant failed: ', ''));
        }
        return expect(await con).to.deep.equal(mock) as Chai.AsyncAssertion;
    };

    public applyShareIncrease = async (
        contract: StakeMathTest,
        state: MockStakeMath2State,
        position: MockStakeMath2Position,
        amount: BigNumber,
    ): Promise<Chai.AsyncAssertion> => {
        let mock, con;
        try {
            con = contract.applyShareIncrease({ ...state }, { ...position }, amount);
            mock = MockStakeMath2.applyShareIncrease({ ...state }, { ...position }, amount);
        } catch (e: any) {
            this.errorChecks++;
            return expect(con).to.be.revertedWith(e.message.replace('Invariant failed: ', ''));
        }
        return expect(await con).to.deep.equal(v2(mock)) as Chai.AsyncAssertion;
    };

    public applyShareDecrease = async (
        contract: StakeMathTest,
        state: MockStakeMath2State,
        position: MockStakeMath2Position,
        amount: BigNumber,
    ): Promise<Chai.AsyncAssertion> => {
        let mock, con;
        try {
            con = contract.applyShareDecrease({ ...state }, { ...position }, amount);
            mock = MockStakeMath2.applyShareDecrease({ ...state }, { ...position }, amount);
            // console.log('decrease', { mock });
        } catch (e: any) {
            this.errorChecks++;
            return expect(con).to.be.revertedWith(e.message.replace('Invariant failed: ', ''));
        }
        return expect(await con).to.deep.equal(v2(mock)) as Chai.AsyncAssertion;
    };

    public applyRewardIncrease = async (
        contract: StakeMathTest,
        state: MockStakeMath2State,
        amount: BigNumber,
    ): Promise<Chai.AsyncAssertion> => {
        let mock, con;

        try {
            con = contract.applyRewardIncrease({ ...state }, amount);
            mock = MockStakeMath2.applyRewardIncrease({ ...state }, amount);
        } catch (e: any) {
            this.errorChecks++;
            return expect(con).to.be.revertedWith(e.message.replace('Invariant failed: ', ''));
        }
        return expect(await con).to.deep.equal(v2([mock])[0]) as Chai.AsyncAssertion;
    };
}
