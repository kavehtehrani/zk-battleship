#!/bin/bash
# Regenerate Solidity verifier for zk-battleship (Poseidon commitment)
# Mirrors zk-rps flow

set -e

echo "Writing verification key..."
bb write_vk -b ./target/circuit.json -o ./target --oracle_hash keccak

OUT="../contracts/contracts/Verifier.sol"
echo "Generating Solidity verifier to $OUT ..."
bb write_solidity_verifier -k ./target/vk -o "$OUT"

echo "✅ Verifier regenerated at $OUT"
echo ""
echo "Next steps:"
echo "1. Compile: cd ../contracts && npx hardhat compile"
echo "2. Deploy locally: npx hardhat ignition deploy ignition/modules/Battleship.ts --network localhost"

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Compile and generate verifier for both circuits
if ! command -v nargo >/dev/null 2>&1; then
  echo "nargo not found. Please install Noir toolchain."
  exit 1
fi

# Build
nargo compile board
nargo compile shot

# Generate Solidity verifiers into ../contracts
OUT_DIR="../contracts"
mkdir -p "$OUT_DIR"
nargo codegen-verifier board --solidity "$OUT_DIR/VerifierBoard.sol"
nargo codegen-verifier shot --solidity "$OUT_DIR/VerifierShot.sol"

echo "Verifiers written to $OUT_DIR"


