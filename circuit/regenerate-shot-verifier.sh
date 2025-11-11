#!/bin/bash
set -e
cd "$(dirname "$0")"

PKG=shot
echo "Building $PKG..."
nargo compile --package zk_battleship_shot

echo "Writing verification key..."
bb write_vk -b ./shot/target/circuit.json -o ./shot/target --oracle_hash keccak

OUT="../contracts/contracts/VerifierShot.sol"
echo "Generating Solidity verifier to $OUT ..."
bb write_solidity_verifier -k ./shot/target/vk -o "$OUT"

echo "✅ Shot verifier regenerated at $OUT"

