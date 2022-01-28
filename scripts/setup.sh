#!/bin/sh
set -e

# --------------------------------------------------------------------------------
# Phase 2
# ... circuit-specific stuff

# Compile circuits
circom zk/circuits/basic.circom -o zk/ --r1cs --wasm --sym
node zk/basic_js/generate_witness.js zk/basic_js/basic.wasm zk/input.json zk/basic.wtns

#Setup
yarn snarkjs groth16 setup zk/basic.r1cs zk/ptau/pot12_final.ptau zk/zkey/basic_final.zkey

# # Generate reference zkey
yarn snarkjs zkey new zk/basic.r1cs zk/ptau/pot12_final.ptau zk/zkey/basic_0000.zkey

# # Ceremony just like before but for zkey this time
yarn snarkjs zkey contribute zk/zkey/basic_0000.zkey zk/zkey/basic_0001.zkey \
    --name="First basic contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

yarn snarkjs zkey contribute zk/zkey/basic_0001.zkey zk/zkey/basic_0002.zkey \
    --name="Second basic contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

yarn snarkjs zkey contribute zk/zkey/basic_0002.zkey zk/zkey/basic_0003.zkey \
    --name="Third basic contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

# #  Verify zkey
yarn snarkjs zkey verify zk/basic.r1cs zk/ptau/pot12_final.ptau zk/zkey/basic_0003.zkey

# # Apply random beacon as before
yarn snarkjs zkey beacon zk/zkey/basic_0003.zkey zk/zkey/basic_final.zkey \
    0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="basic Final Beacon phase2"

# # Optional: verify final zkey
yarn snarkjs zkey verify zk/basic.r1cs zk/ptau/pot12_final.ptau zk/zkey/basic_final.zkey

# # Export verification key
yarn snarkjs zkey export verificationkey zk/zkey/basic_final.zkey zk/verification_key.json

#verify
yarn snarkjs groth16 prove zk/zkey/basic_final.zkey zk/basic.wtns zk/proof/public.json zk/proof/proof.json
yarn snarkjs groth16 verify zk/verification_key.json zk/proof/public.json zk/proof/proof.json

# Export verifier smart contracts
snarkjs zkey export solidityverifier zk/zkey/basic_final.zkey contracts/Verifier.sol