import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { expect } from 'chai';

import { DecoderTest, DecoderTest__factory } from '../types';
import { NamedAccounts } from '../hardhat.config';

import { deployContract, prepareAccounts } from './shared';

const STARTS_WITH = 'data:application/json;base64,';
const STARTS_WITH_2 = 'data:image/svg+xml;base64,';

let accounts: Record<keyof typeof NamedAccounts, SignerWithAddress>;
let decoderTest: DecoderTest;

describe('Main', async function () {
    before(async function () {
        accounts = await prepareAccounts();
        decoderTest = await deployContract<DecoderTest__factory>({
            factory: 'Decoder_Test',
            from: accounts.deployer,
            args: [],
        });
    });

    describe('_bytesToColor', async function () {
        const cases = [
            {
                // [64, [0, 0, 0, 255], 4, true];

                want: '0x4004000000ff',
                expect: Object.values({
                    id: 64,
                    rgba: Object.values({ r: 0, g: 0, b: 0, a: 255 }),
                    layer: 4,
                    exists: true,
                }),
            },
            {
                want: '0x4101050505fe',
                expect: Object.values({
                    id: 65,
                    rgba: Object.values({ r: 5, g: 5, b: 5, a: 254 }),
                    layer: 1,
                    exists: true,
                }),
            },
        ];

        for (let i = 0; i < cases.length; i++) {
            it('test ' + i, async function () {
                expect(await decoderTest.bytesToColor(cases[i].want)).to.be.deep.equal(cases[i].expect);
            });
        }
    });

    describe('_bytesToFeature', async function () {
        const cases = [
            {
                want: '0x0203',
                expect: Object.values({
                    id: 2,
                    defaultLevel: 0,
                }),
            },
            {
                want: '0x0526',
                expect: Object.values({
                    id: 5,
                    defaultLevel: 0,
                }),
            },
        ];

        for (let i = 0; i < cases.length; i++) {
            it('test ' + i, async function () {
                expect(await decoderTest.bytesToFeature(cases[i].want)).to.be.deep.equal(cases[i].expect);
            });
        }
    });

    describe('_bytesToExpander', async function () {
        const cases = [
            {
                want: '0x5840',
                expect: Object.values({
                    exists: true,
                    id: 88,
                    colorID: 64,
                }),
            },
        ];

        for (let i = 0; i < cases.length; i++) {
            it('test ' + i, async function () {
                expect(await decoderTest.bytesToExpander(cases[i].want)).to.be.deep.equal(cases[i].expect);
            });
        }
    });

    describe('_bytesToExpanderGroup', async function () {
        const cases = [
            {
                want: '0x5840',
                expect: Object.values({
                    exists: true,
                    id: 88,
                    colorID: 64,
                }),
            },
        ];

        for (let i = 0; i < cases.length; i++) {
            it('test ' + i, async function () {
                expect(await decoderTest.bytesToExpanderGroup(cases[i].want)).to.be.deep.equal(cases[i].expect);
            });
        }
    });

    describe('_bytesToGroup', async function () {
        const cases = [
            {
                want: '0x4004',
                expect: Object.values({
                    colorID: 64,
                    len: 4,
                }),
            },
        ];

        for (let i = 0; i < cases.length; i++) {
            it('test ' + i, async function () {
                expect(await decoderTest.bytesToGroup(cases[i].want)).to.be.deep.equal(cases[i].expect);
            });
        }
    });

    describe('_bytesToBaseFeature', async function () {
        const cases = [
            {
                want: '0x000000000000000000',
                expect: Object.values({
                    feature: Object.values({
                        id: 0,
                        defaultLevel: 0,
                    }),
                    anchor: Object.values({
                        x: 0,
                        y: 0,
                    }),
                    arguments: Object.values({
                        l: 0,
                        r: 0,
                        u: 0,
                        d: 0,
                        z: 0,
                        c: 0,
                    }),
                    exists: true,
                }),
            },
        ];

        for (let i = 0; i < cases.length; i++) {
            it('test ' + i, async function () {
                const res = await decoderTest.bytesToBaseFeature(cases[i].want);
                expect(res).to.be.deep.equal(cases[i].expect);
            });
        }
    });
    //
    describe('_bytesToBase', async function () {
        const cases = [
            //{
            //     in: '0x6e75676701060D06317c6718182501f6000bff2d01131313ff4001000000ff5e01a4a4a4ff6f01535353ff7e01e0e0e0ff000b0801010000000101090c010500000001020c1201010000000103060c000000000001040c0c010100000001050b050101000000012e182e182e182e182e182e0840072e092e0740017e0740012e082e0640017e0940012e072e0640017e0940012e072e0640017e0940012e072e0640017e0940012e072e0640017e026f027e036f0240012e072e0540027e0240015e017e0340015e0140012e072e0540017e0a40012e072e0540027e0940012e072e0640017e0540027e0240012e072e0640017e0940012e072e0640017e0940012e072e0640017e0340057e0140012e072e0640017e0325017e0325017e0140012e072e0140067e0840012e082e0240012d0340017e0340052e092e0340012d0240017e0340012d0240012e0a2e0440012d0140017e0340012d0140012e0b',
            //     out: Object.values({
            //         baseFeatures: [
            //             Object.values({
            //                 anchor: Object.values({ x: 11, y: 8 }),
            //                 feature: Object.values({ id: 0 }),
            //                 arguments: Object.values({ l: 1, r: 1, u: 0, d: 0, z: 0, c: 1 }),
            //             }), // A
            //             Object.values({
            //                 anchor: Object.values({ x: 9, y: 12 }),
            //                 feature: Object.values({ id: 1 }),
            //                 arguments: Object.values({ L: 1, R: 5, Z: 0, C: 1 }),
            //             }), // B
            //             Object.values({
            //                 anchor: Object.values({ x: 12, y: 18 }),
            //                 feature: Object.values({ id: 2 }),
            //                 arguments: Object.values({ L: 1, R: 1, Z: 0, C: 1 }),
            //             }), // C
            //             Object.values({
            //                 anchor: Object.values({ x: 6, y: 12 }),
            //                 feature: Object.values({ id: 3 }),
            //                 arguments: Object.values({ L: 0, R: 0, Z: 0, C: 1 }),
            //             }), // D
            //             Object.values({
            //                 anchor: Object.values({ x: 12, y: 12 }),
            //                 feature: Object.values({ id: 4 }),
            //                 arguments: Object.values({ L: 1, R: 1, Z: 0, C: 1 }),
            //             }), // E
            //             Object.values({
            //                 anchor: Object.values({ x: 11, y: 5 }),
            //                 feature: Object.values({ id: 5 }),
            //                 arguments: Object.values({ L: 1, R: 1, Z: 0, C: 1 }),
            //             }), // F
            //         ],
            //         display: Object.values({
            //             len: Object.values({ X: 24, Y: 24 }),
            //             colors: Object.values({
            //                 '%': Object.values({ id: 0, rgba: { r: 0xf6, g: 0x00, b: 0x0b, a: 0xff }, layer: 1 }),
            //                 '-': Object.values({ id: 1, rgba: { r: 0x13, g: 0x13, b: 0x13, a: 0xff }, layer: 1 }),
            //                 '@': Object.values({ id: 2, rgba: { r: 0x00, g: 0x00, b: 0x00, a: 0xff }, layer: 1 }),
            //                 '^': Object.values({ id: 3, rgba: { r: 0xa4, g: 0xa4, b: 0xa4, a: 0xff }, layer: 1 }),
            //                 o: Object.values({ id: 4, rgba: { r: 0x53, g: 0x53, b: 0x53, a: 0xff }, layer: 1 }),
            //                 '~': Object.values({ id: 5, rgba: { r: 0xe0, g: 0xe0, b: 0xe0, a: 0xff }, layer: 1 }),
            //             }),
            //         }),
            //     }),
            // },
            {
                in: '0x6e75676701060d0631866720202501f6000bff2d01131313ff4001000000ff5e01a4a4a4ff6f01535353ff7e01e0e0e0ff000b10020200000001010914000000000001020c1a010100000001030614000000000001040c14000000000001050b0d0202000000012e202e202e202e202e1a40012e052e202e202e202e202e202e202e202e202e0840072e112e0740017e0740012e102e0640017e0940012e0f2e0640017e0940012e0f2e0640017e0940012e0f2e0640017e0940012e0f2e0640017e026f027e036f0240012e0f2e0540017e0340015e017e0340015e0140012e0f2e0540017e0a40012e0f2e0540027e0940012e0f2e0640017e0540027e0240012e0f2e0640017e0940012e0f2e0640017e0940012e0f2e0640017e0340057e0140012e0f2e0640017e0325017e0325017e0140012e0f2e0140067e0840012e102e0240012d0340017e0340052e112e0340012d0240017e0340012d0240012e122e0440012d0140017e0340012d0140012e13',
                out: {},
            },
        ];

        for (let i = 0; i < cases.length; i++) {
            it('test ' + i, async function () {
                const res = await decoderTest.bytesToBase(cases[i].in);
                // console.log(res.display);
                // expect(res).to.be.deep.equal(cases[i].out);
            });
        }
    });
});
