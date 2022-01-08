import { BigNumber, BigNumberish } from 'ethers';
import { ethers } from 'hardhat';

export class Mining {
    public static async advanceBlock() {
        return await ethers.provider.send('evm_mine', []);
    }

    public static async advanceBlockTo(blockNumber: BigNumberish) {
        for (let i = await ethers.provider.getBlockNumber(); i < blockNumber; i++) {
            await Mining.advanceBlock();
        }
    }

    public static async increase(value: BigNumber) {
        await ethers.provider.send('evm_increaseTime', [value.toNumber()]);
        await Mining.advanceBlock();
    }

    public static async latest() {
        const block = await ethers.provider.getBlock('latest');
        return BigNumber.from(block.timestamp);
    }

    public static async pending() {
        const block = await ethers.provider.getBlock('pending');
        // console.log({ block });
        return BigNumber.from(block.timestamp);
    }

    public static async advanceTimeAndBlock(time: BigNumberish) {
        await Mining.advanceTime(time);
        await Mining.advanceBlock();
    }

    public static async advanceTime(time: BigNumberish) {
        await ethers.provider.send('evm_increaseTime', [time]);
    }

    public static duration = {
        seconds(val: BigNumberish) {
            return BigNumber.from(val);
        },
        minutes(val: BigNumberish) {
            return BigNumber.from(val).mul(this.seconds('60'));
        },
        hours(val: BigNumberish) {
            return BigNumber.from(val).mul(this.minutes('60'));
        },
        days(val: BigNumberish) {
            return BigNumber.from(val).mul(this.hours('24'));
        },
        weeks(val: BigNumberish) {
            return BigNumber.from(val).mul(this.days('7'));
        },
        years(val: BigNumberish) {
            return BigNumber.from(val).mul(this.days('365'));
        },
    };
}
