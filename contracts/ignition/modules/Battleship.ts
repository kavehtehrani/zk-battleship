import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const BattleshipModule = buildModule("BattleshipModule", (m) => {
	const boardVerifier = m.contract("VerifierBoard");
	const shotVerifier = m.contract("VerifierShot");
	const battleship = m.contract("Battleship", [boardVerifier, shotVerifier]);
	return { boardVerifier, shotVerifier, battleship };
});

export default BattleshipModule;

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const BattleshipModule = buildModule("BattleshipModule", (m) => {
  const boardVerifier = m.contract("VerifierBoard");
  const shotVerifier = m.contract("VerifierShot");
  const battleship = m.contract("Battleship", [boardVerifier, shotVerifier]);
  return { boardVerifier, shotVerifier, battleship };
});

export default BattleshipModule;


