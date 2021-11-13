import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { expect } from 'chai';

import { NamedAccounts } from '../hardhat.config';
import { EncoderTest, EncoderTest__factory } from '../typechain';

import { deployContract, prepareAccounts } from './shared';

let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let encoderTest: EncoderTest;

describe('Main', async function () {
    before(async function () {
        accounts = await prepareAccounts();
        encoderTest = await deployContract<EncoderTest__factory>({
            factory: 'Encoder_Test',
            from: accounts.deployer,
            args: [],
        });
    });

    describe('Encoder checks', async function () {
        it('display to bytes', async function () {
            const val = await encoderTest._toBytesDisplay({
                len: { x: 24, y: 6 },
                groups: [
                    { len: 24, colorID: 0 },
                    { len: 24, colorID: 0 },
                    { len: 24, colorID: 0 },
                    { len: 24, colorID: 0 },
                    { len: 24, colorID: 0 },
                    { len: 8, colorID: 0 },
                    { len: 7, colorID: 1 },
                    { len: 9, colorID: 0 },
                ],
                colors: [
                    { layer: 1, id: 0, rgba: { r: 0, g: 0, b: 0, a: 0 }, exists: false },
                    { layer: 1, id: 1, rgba: { r: 19, g: 19, b: 19, a: 255 }, exists: false },
                ],
            });

            expect(val).to.be.equal('0x6e75676703020b081718060001000000000101131313ff00180018001800180018000801070009');
        });
    });
});
