#!/bin/sh
set -e

# compile basic witness
node zk/basic_js/generate_witness.js zk/basic_js/basic.wasm zk/input.json zk/basic.wtns

# create proof
yarn snarkjs groth16 prove zk/zkey/basic_final.zkey zk/basic.wtns zk/proof/proof.json zk/proof/public.json

#verify proof locally
yarn snarkjs groth16 verify zk/verification_key.json zk/proof/public.json zk/proof/proof.json