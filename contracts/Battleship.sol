// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface INoirVerifier {
    function verify(bytes calldata proof, bytes32[] calldata publicInputs) external view returns (bool);
}

contract Battleship {
    struct Game {
        address player;
        uint256 commitment; // Poseidon commitment
        bytes32 configHash; // hash of (width,height,fleet...) for quick checks
        bool exists;
    }

    INoirVerifier public boardVerifier;
    INoirVerifier public shotVerifier;
    uint256 public nextGameId = 1;
    mapping(uint256 => Game) public games;

    event GameCreated(uint256 indexed gameId, address indexed player, uint256 commitment, bytes32 configHash);
    event ShotVerified(uint256 indexed gameId, address indexed player, uint256 sx, uint256 sy, bool hit);

    constructor(address _boardVerifier, address _shotVerifier) {
        boardVerifier = INoirVerifier(_boardVerifier);
        shotVerifier = INoirVerifier(_shotVerifier);
    }

    function createGame(
        uint256 commitment,
        bytes32 configHash,
        bytes calldata proof,
        bytes32[] calldata publicInputs
    ) external returns (uint256 gameId) {
        require(boardVerifier.verify(proof, publicInputs), "invalid board proof");
        gameId = nextGameId++;
        games[gameId] = Game({
            player: msg.sender,
            commitment: commitment,
            configHash: configHash,
            exists: true
        });
        emit GameCreated(gameId, msg.sender, commitment, configHash);
    }

    function submitShot(
        uint256 gameId,
        uint256 sx,
        uint256 sy,
        bool declaredHit,
        bytes calldata proof,
        bytes32[] calldata publicInputs
    ) external {
        Game memory g = games[gameId];
        require(g.exists, "game not found");
        require(shotVerifier.verify(proof, publicInputs), "invalid shot proof");
        emit ShotVerified(gameId, msg.sender, sx, sy, declaredHit);
    }
}


