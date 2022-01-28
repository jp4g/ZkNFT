const { ethers } = require('hardhat')
const fs = require('fs')
const path = require('path')
const snarkjs = require('snarkjs')
const builder = require('../zk/basic_js/witness_calculator')

describe('ZK Proof to Mint NFT', async () => {
    let instance, signers
    before(async () => {
        signers = await ethers.getSigners()
        let factory = await ethers.getContractFactory("NFT")
        instance = await factory.deploy()
    })
    it('Submit proof and mint', async () => {
        await genWitness(
            { "a": 11, "b": 3},
            'zk/basic_js/basic.wasm',
            'zk/witness.wtns'
        )
        const { proof, publicSignals } = await snarkjs.groth16.prove(
            'zk/zkey/basic_final.zkey',
            'zk/witness.wtns'
        )
        await snarkjs.groth16.verify(
            require('../zk/verification_key.json'),
            publicSignals,
            proof
        )
        const args = buildContractCallArgs(proof, publicSignals)
        const tx = await (await instance.connect(signers[0]).mint(...args)).wait()
        console.log('tx', tx)
    })
})

const genWitness = async (input, wasmFilePath, witnessFileName) => {
    const buffer = fs.readFileSync(wasmFilePath);

    return new Promise((resolve, reject) => {
        builder(buffer)
            .then(async (witnessCalculator) => {
                const buff = await witnessCalculator.calculateWTNSBin(input, 0);
                fs.writeFileSync(witnessFileName, buff);
                resolve(witnessFileName);
            })
            .catch((error) => {
                reject(error);
            });
    });
};

//https://github.com/JofArnold/zkp-learning-in-public/blob/main/%40projects/04-simple-circom-v2.0/src/utils.js
function buildContractCallArgs(proof, publicSignals) {
    // the object returned by genZKSnarkProof needs to be massaged into a set of parameters the verifying contract
    // will accept
    return [
      proof.pi_a.slice(0, 2), // pi_a
      // genZKSnarkProof reverses values in the inner arrays of pi_b
      [
        proof.pi_b[0].slice(0).reverse(),
        proof.pi_b[1].slice(0).reverse(),
      ], // pi_b
      proof.pi_c.slice(0, 2), // pi_c
      publicSignals, // input
    ];
  }