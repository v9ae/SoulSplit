// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SoulSplit: A blockchain-based guessing game contract
contract SoulSplit {
    // State Variables
    address public owner; // Contract deployer
    uint256 public constant MIN_BET = 0.004 ether; // Minimum bet amount
    uint256 public constant MAX_BET = 1 ether; // Maximum bet amount
    uint256 private seed; // Seed for pseudo-randomness

    // Player Data
    struct Player {
        uint256 highestLevel; // Player's highest achieved level
    }
    mapping(address => Player) public players; // Map player addresses to their data
    address[] public playerAddresses; // List of player addresses

    // Events
    event GameResult(
        address indexed player,
        uint256 level,
        uint256 boxIndex,
        bool isWin,
        uint256 payout
    );

    // Constructor
    constructor() {
        owner = msg.sender;
        seed = uint256(blockhash(block.number - 1));
    }

    // Play a game round
    function play(uint256 _betAmount, uint256 _boxIndex) public payable {
        require(msg.value == _betAmount, "Sent value must equal bet amount");
        require(_betAmount >= MIN_BET && _betAmount <= MAX_BET, "Bet amount out of range");
        require(_boxIndex < 5, "Invalid box index");

        // Generate two distinct bomb indices
        seed = uint256(keccak256(abi.encodePacked(seed, block.timestamp, msg.sender)));
        uint256 bomb1 = seed % 5;
        seed = uint256(keccak256(abi.encodePacked(seed)));
        uint256 bomb2 = seed % 5;
        while (bomb2 == bomb1) {
            seed = uint256(keccak256(abi.encodePacked(seed)));
            bomb2 = seed % 5;
        }

        // Determine game outcome
        bool isWin = (_boxIndex != bomb1 && _boxIndex != bomb2);
        uint256 payout = 0;

        if (isWin) {
            uint256 multiplier = getMultiplier(getCurrentLevel(msg.sender));
            payout = (_betAmount * multiplier) / 10;
            require(address(this).balance >= payout, "Insufficient contract balance");
            payable(msg.sender).transfer(payout);
        }

        // Update player data
        if (players[msg.sender].highestLevel == 0) {
            playerAddresses.push(msg.sender);
        }
        if (getCurrentLevel(msg.sender) > players[msg.sender].highestLevel) {
            players[msg.sender].highestLevel = getCurrentLevel(msg.sender);
        }

        emit GameResult(msg.sender, getCurrentLevel(msg.sender), _boxIndex, isWin, payout);
    }

    // Get player's current level
    function getCurrentLevel(address _player) public view returns (uint256) {
        return players[_player].highestLevel + 1;
    }

    // Get top 5 players for leaderboard
    function getLeaderboard() public view returns (address[] memory, uint256[] memory) {
        uint256 length = playerAddresses.length > 5 ? 5 : playerAddresses.length;
        address[] memory topPlayers = new address[](length);
        uint256[] memory topLevels = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            topPlayers[i] = address(0);
            topLevels[i] = 0;
        }

        for (uint256 i = 0; i < playerAddresses.length; i++) {
            address player = playerAddresses[i];
            uint256 level = players[player].highestLevel;

            for (uint256 j = 0; j < length; j++) {
                if (level > topLevels[j]) {
                    for (uint256 k = length - 1; k > j; k--) {
                        topPlayers[k] = topPlayers[k - 1];
                        topLevels[k] = topLevels[k - 1];
                    }
                    topPlayers[j] = player;
                    topLevels[j] = level;
                    break;
                }
            }
        }

        return (topPlayers, topLevels);
    }

    // Get multiplier for a given level
    function getMultiplier(uint256 _level) private pure returns (uint256) {
        uint256[20] memory multipliers = [
            uint256(1), uint256(3), uint256(6), uint256(10), uint256(15),
            uint256(22), uint256(31), uint256(42), uint256(55), uint256(70),
            uint256(88), uint256(109), uint256(132), uint256(158), uint256(187),
            uint256(220), uint256(260), uint256(300), uint256(350), uint256(400)
        ];
        return multipliers[_level - 1];
    }

    // Fund the contract (owner only)
    function fundContract() public payable {
        require(msg.sender == owner, "Only owner can fund");
    }

    // Receive Ether
    receive() external payable {}
}