import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BattleshipModule", (m) => {
  // The generated verifier contracts are named "HonkVerifier" in both files
  // We need to use fully qualified names to disambiguate them
  const boardVerifier = m.contract(
    "contracts/VerifierBoard.sol:HonkVerifier",
    [],
    {
      id: "VerifierBoard",
    }
  );

  const shotVerifier = m.contract(
    "contracts/VerifierShot.sol:HonkVerifier",
    [],
    {
      id: "VerifierShot",
    }
  );

  const battleship = m.contract("Battleship", [boardVerifier, shotVerifier]);
  return { boardVerifier, shotVerifier, battleship };
});
