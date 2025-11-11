#!/bin/bash
set -e
cd "$(dirname "$0")"

PKG=board
echo "Building $PKG..."
cd board
nargo compile
cd ..

echo "Writing verification key..."
bb write_vk -b ./board/target/zk_battleship_board.json -o ./board/target --oracle_hash keccak

OUT="../contracts/contracts/VerifierBoard.sol"
echo "Generating Solidity verifier to $OUT ..."
bb write_solidity_verifier -k ./board/target/vk -o "$OUT"

echo "✅ Board verifier regenerated at $OUT"

