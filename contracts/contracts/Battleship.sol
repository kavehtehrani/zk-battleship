// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IVerifier {
	function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool);
}

contract Battleship {
	struct GameConfig {
		bytes32 hash; // hash of (width,height,fleet[],gameId,salt) as used in circuit commitment
	}

	struct Game {
		address player;
		bytes32 commitment; // Poseidon commitment of board + config + salt + gameId
		GameConfig config;
		bool exists;
	}

	event GameCreated(uint256 indexed gameId, address indexed player, bytes32 commitment, bytes32 configHash);
	event ShotPlayed(uint256 indexed gameId, uint256 sx, uint256 sy, bool hit);

	IVerifier public boardVerifier;
	IVerifier public shotVerifier;

	mapping(uint256 => Game) public games;
	uint256 public nextGameId = 1;

	constructor(IVerifier _boardVerifier, IVerifier _shotVerifier) {
		boardVerifier = _boardVerifier;
		shotVerifier = _shotVerifier;
	}

	function setVerifiers(IVerifier _boardVerifier, IVerifier _shotVerifier) external {
		boardVerifier = _boardVerifier;
		shotVerifier = _shotVerifier;
	}

	// Board public inputs: [commitment]
	function createGame(bytes32 configHash, bytes32 commitment, bytes calldata proof, bytes32[] calldata publicInputs) external returns (uint256 gameId) {
		require(publicInputs.length == 1, "bad inputs");
		require(publicInputs[0] == commitment, "C mismatch");
		require(boardVerifier.verify(proof, publicInputs), "board verify failed");

		gameId = nextGameId++;
		games[gameId] = Game({
			player: msg.sender,
			commitment: commitment,
			config: GameConfig({hash: configHash}),
			exists: true
		});
		emit GameCreated(gameId, msg.sender, commitment, configHash);
	}

	// Shot public inputs: [commitment, sx, sy, hit]
	function submitShot(uint256 gameId, uint256 sx, uint256 sy, bool hit, bytes calldata proof, bytes32[] calldata publicInputs) external {
		Game storage g = games[gameId];
		require(g.exists, "no game");
		require(publicInputs.length == 4, "bad inputs");
		require(publicInputs[0] == g.commitment, "C mismatch");
		require(publicInputs[1] == bytes32(sx), "sx mismatch");
		require(publicInputs[2] == bytes32(sy), "sy mismatch");
		require(publicInputs[3] == bytes32(uint256(hit ? 1 : 0)), "hit mismatch");

		require(shotVerifier.verify(proof, publicInputs), "shot verify failed");

		emit ShotPlayed(gameId, sx, sy, hit);
	}
}


