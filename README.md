# zk-battleship (Poseidon-based, separate from zk-rps)

This adds a Battleship game using Noir circuits and Hardhat verifiers. It is self-contained in `zk-battleship/` and does not modify `zk-rps/`.

Reference: `https://github.com/BattleZips/BattleZips-Noir`

## Circuits

- `circuit/common/` shared types and helpers
- `circuit/board/` board placement proof
  - public inputs: `[commitment]`
- `circuit/shot/` per-turn shot proof
  - public inputs: `[commitment, shot_x, shot_y, hit]`

Commitment: Poseidon over deterministic occupied cells + config `(width,height,fleet[],gameId,salt)`.

### Build

```bash
cd zk-battleship/circuit
nargo compile --package zk-battleship-board
nargo compile --package zk-battleship-shot
```

### Generate verifiers

```bash
./regenerate-board-verifier.sh
./regenerate-shot-verifier.sh
```

## Contracts

- `contracts/contracts/VerifierBoard.sol` and `VerifierShot.sol` (generated)
- `contracts/contracts/Battleship.sol`
  - `createGame(configHash, commitment, boardProof, [commitment])`
  - `submitShot(gameId, sx, sy, hit, shotProof, [commitment,sx,sy,hit])`

### Compile/Deploy (local)

```bash
cd zk-battleship/contracts
npx hardhat compile
npx hardhat ignition deploy ignition/modules/Battleship.ts --network localhost
```

## Frontend

Minimal Vite skeleton in `frontend/`. Start locally:

```bash
cd zk-battleship/frontend
npx vite
```

zk-battleship (Poseidon-based Battleship)

- Circuits in `circuit/` (Noir, Poseidon commitment)
- Contracts in `contracts/` (Hardhat-style layout)
- Frontend in `frontend/` (Vite)

Do not modify `zk-rps/`. This is a separate implementation.


