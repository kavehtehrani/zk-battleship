# zk-battleship (Poseidon-based, separate from zk-rps)

This adds a Battleship game using Noir circuits and Hardhat verifiers. It is self-contained in `zk-battleship/` and does not modify `zk-rps/`.

Reference: `https://github.com/BattleZips/BattleZips-Noir`

## Prerequisites

- **Node.js** 18+ and npm
- **Noir** ([install instructions](https://noir-lang.org/docs/getting_started/nargo_installation))
- **Barretenberg CLI** (`bb`) - usually comes with Noir installation
- **MetaMask** (for wallet connection)

## Running Locally - Step by Step

### 1. Install Dependencies

```bash
# Contracts
cd zk-battleship/contracts
npm install

# Frontend
cd ../frontend
npm install
```

### 2. Compile Circuits

```bash
# Compile board circuit
cd zk-battleship/circuit/board
nargo compile

# Compile shot circuit
cd ../shot
nargo compile
```

This generates:

- `board/target/circuit.json`
- `shot/target/circuit.json`

### 3. Generate Verifier Contracts

```bash
# Still in zk-battleship/circuit/
./regenerate-board-verifier.sh
./regenerate-shot-verifier.sh
```

This generates:

- `../contracts/contracts/VerifierBoard.sol`
- `../contracts/contracts/VerifierShot.sol`

### 4. Start Hardhat Local Node

In a new terminal:

```bash
cd zk-battleship/contracts
npx hardhat node
```

This starts a local Ethereum node at `http://127.0.0.1:8545` with Chain ID `31337`.

### 5. Deploy Contracts

In another terminal:

```bash
cd zk-battleship/contracts
npx hardhat compile
npx hardhat ignition deploy ignition/modules/Battleship.ts --network localhost
```

Copy the deployed contract addresses from the output (e.g., `Battleship: 0x5FbDB2315678afecb367f032d93F642f64180aa3`).

### 6. Setup Frontend Artifacts

```bash
cd zk-battleship/frontend

# Copy compiled circuits
mkdir -p target
cp ../circuit/board/target/circuit.json target/board-circuit.json
cp ../circuit/shot/target/circuit.json target/shot-circuit.json

# Copy contract artifacts (after compilation)
mkdir -p public
cp ../contracts/artifacts/contracts/Battleship.sol/Battleship.json public/contract-artifact.json
```

### 7. Configure Frontend

Update `frontend/main.js` with the deployed contract address:

```javascript
const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Replace with your address
```

### 8. Start Frontend Dev Server

```bash
cd zk-battleship/frontend
npm run dev
```

Visit `http://localhost:5173`

### 9. Fund Your Wallet

Hardhat node creates 20 accounts with 10,000 ETH each. Choose one:

**Option A: Import Hardhat Account to MetaMask**

- Copy a private key from the Hardhat node output
- In MetaMask: Account icon → Import Account → Paste private key

**Option B: Configure MetaMask Network**

- Network Name: `Hardhat Local`
- RPC URL: `http://127.0.0.1:8545`
- Chain ID: `31337`
- Currency Symbol: `ETH`

## Circuit Details

- `circuit/common/` shared types and helpers
- `circuit/board/` board placement proof
  - public inputs: `[commitment]`
- `circuit/shot/` per-turn shot proof
  - public inputs: `[commitment, shot_x, shot_y, hit]`

Commitment: Poseidon over deterministic occupied cells + config `(width,height,fleet[],gameId,salt)`.

## Contract Details

- `contracts/contracts/VerifierBoard.sol` and `VerifierShot.sol` (generated)
- `contracts/contracts/Battleship.sol`
  - `createGame(configHash, commitment, boardProof, [commitment])`
  - `submitShot(gameId, sx, sy, hit, shotProof, [commitment,sx,sy,hit])`

## Project Structure

```
zk-battleship/
├── circuit/
│   ├── common/          # Shared types and helpers
│   ├── board/           # Board placement circuit
│   ├── shot/            # Shot verification circuit
│   └── regenerate-*.sh # Verifier generation scripts
├── contracts/
│   ├── contracts/       # Solidity contracts
│   └── ignition/        # Deployment modules
└── frontend/            # Vite frontend
```

Do not modify `zk-rps/`. This is a separate implementation.
