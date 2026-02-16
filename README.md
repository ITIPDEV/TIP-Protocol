# TIP-1 Protocol

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

**The Task Interaction Protocol (TIP)** is a minimalist, decentralized state machine designed to standardize the lifecycle of on-chain tasks. It serves as the "TCP/IP" for task coordination in the Web3 era—neutral, immutable, and permissionless.

---

## Core Philosophy

* **Decentralized ID**: TIP-1 does not generate IDs. Users generate IDs off-chain (e.g., via Keccak256 hash or UUID). The protocol only validates uniqueness.
* **Immutable Logic**: Enforces 10 strict physical transition paths based on bitwise logic. No admin keys, no upgrades, no pauses.
* **Gas Optimized**: Utilizes bitwise operations and single-slot storage packing for extreme efficiency.
* **Permissionless**: Anyone can register a task. Anyone can build a UI or AI Agent on top of it.

## Contract Addresses

| Network | Contract Address | Status | Explorer |
| :--- | :--- | :--- | :--- |
| **BSC Mainnet** | `0x9FE10e09539b533BA23e59AaF9Fddc65268e6be2` | Finish | [View on BscScan](https://bscscan.com/address/0x9fe10e09539b533ba23e59aaf9fddc65268e6be2) |
| **BSC Testnet** | `0xde38D7191bbAcC4Fcd1c4e10f8b941b3799eBf37` | Finish | [View on BscScan](https://testnet.bscscan.com/address/0xde38d7191bbacc4fcd1c4e10f8b941b3799ebf37) |

## Integration (For Developers)

To integrate TIP-1 into your dApp, AI Agent, or DAO, simply use the `ITIP1` interface. You do not need to import the full implementation.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title TIP-1 Protocol Interface
interface ITIP1 {
    // Event emitted when a task state changes
    event Updated(uint256 indexed id, uint8 indexed oldState, uint8 indexed newState);

    /**
     * @notice Updates the state of a task.
     * @dev Only the controller of the task can call this function.
     * @param id The unique identifier of the task.
     * @param newState The target state to transition to.
     */
    function update(uint256 id, uint8 newState) external;

    /**
     * @notice Reads the current status of a task.
     * @param id The unique identifier of the task.
     * @return controller The address that owns/controls the task.
     * @return state The current state code (0-6).
     */
    function fetch(uint256 id) external view returns (address controller, uint8 state);
}

```

## State Machine

TIP-1 strictly enforces the following lifecycle transitions. Any other transition attempt will revert.

1.  **Open (0)** -> Taken (1), Cancelled (5)
2.  **Taken (1)** -> Submitted (2), Disputed (4), Failed (6)
3.  **Submitted (2)** -> Completed (3), Taken (1), Disputed (4)
4.  **Disputed (4)** -> Completed (3), Failed (6)

> *Note: States 3 (Completed), 5 (Cancelled), and 6 (Failed) are **Terminal States**. Once reached, the task is locked forever.*

## License

This project is licensed under the **MIT License**.
