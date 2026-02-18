# TIP Protocol (Task Interoperability Protocol)

![Tests](https://github.com/ITIPDEV/TIP-Protocol/actions/workflows/test.yml/badge.svg)
![Network](https://img.shields.io/badge/Network-BSC_Mainnet-gold)
![Status](https://img.shields.io/badge/Status-Live-brightgreen)
![License](https://img.shields.io/badge/License-MIT-blue)
![Solidity](https://img.shields.io/badge/Solidity-0.8.20-lightgrey)

**TIP Protocol** is a standard decentralized state machine for task lifecycle management on the BNB Smart Chain. It provides a universal interface (`ITIP1`) for creating, tracking, and updating task states on-chain, ensuring interoperability between different dApps and worker platforms.

---

## ⚡ Quick Demonstration

Experience the protocol in 60 seconds. This command installs dependencies and runs a full deployment/workflow simulation in a local environment:

```bash
# 1. Install dependencies
forge install foundry-rs/forge-std

# 2. Run the Magic Button Demo
forge script script/Deploy.s.sol
```

---

## 🚀 Deployment Addresses

| Network | Type | Address | Description |
| :--- | :--- | :--- | :--- |
| **BSC Mainnet** | **Official Production** | **`0x9FE10e09539b533BA23e59AaF9Fddc65268e6be2`** | **The Final V1.0 Protocol.** Validated, audited, and immutable. Use this for production integration. |
| **BSC Testnet** | **Stable Mirror** | `0xde38D7191bbAcC4Fcd1c4e10f8b941b3799eBf37` | **Mainnet-Aligned.** Deployed with the exact same logic and bytecode as Mainnet. Use this for standard integration testing. |
| **BSC Testnet** | **Test Logic** | `0x9FE10e09539b533BA23e59AaF9Fddc65268e6be2` | **Experimental/Dev Logic.** Shares the same address as Mainnet but contains experimental logic features. Used for internal logic verification. |

> **Note on Address Collision:** The Mainnet address and the Testnet "Test Logic" address are identical (`0x9FE...6be2`) due to the deployment nonce sequence. However, they run **different logic versions**. Developers should choose the Testnet address based on their specific testing needs.

---

## 🛠 Integration Guide (ITIP1 Standard)

Any contract or dApp can interact with the protocol using the `ITIP1` interface.

### 1. The Interface (`ITIP1`)

Copy this interface into your project to interact with the TIP Protocol:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITIP1 {
    /**
     * @dev Emitted when a task's state changes.
     * @param id The unique task ID.
     * @param oldState The previous state.
     * @param newState The new state after update.
     */
    event Updated(uint256 indexed id, uint8 indexed oldState, uint8 indexed newState);

    /**
     * @dev Updates the state of a task. 
     * Can only be called by the task's controller.
     * @param id The unique task ID.
     * @param newState The target state (0-6).
     */
    function update(uint256 id, uint8 newState) external;

    /**
     * @dev Fetches task details.
     * @param id The unique task ID.
     * @return controller The address with authority to update the task.
     * @return state The current state of the task.
     */
    function fetch(uint256 id) external view returns (address controller, uint8 state);
}

```

---

### 2. State Machine Reference

The protocol enforces a strict state transition flow. Inputs for `newState` must correspond to:

| ID | State Name | Description |
| :--- | :--- | :--- |
| **0** | `Open` | Initial state. Task is created and waiting for a worker. |
| **1** | `Taken` | Accepted by a worker. |
| **2** | `Submitted` | Work has been uploaded/delivered. |
| **3** | `Completed` | Final success state (Terminal). |
| **4** | `Disputed` | Conflict resolution in progress. |
| **5** | `Cancelled` | Task revoked by creator (Terminal). |
| **6** | `Failed` | Unsuccessful attempt (Terminal). |

---

### 3. Protocol Extensibility & Turing Completeness

The `TIP_Protocol` contract deployed on Mainnet serves as a **canonical reference implementation** of the ITIP standard. It demonstrates a linear, 7-state lifecycle optimized for general-purpose task management.

However, the ITIP interface (`ITIP1`) is designed to be **agnostic to the underlying state logic**. Since the Ethereum Virtual Machine (EVM) is Turing-complete, developers are not limited to the standard state flow.

* **Arbitrary State Definitions**: You can define custom state machines with any number of states (e.g., `Verified`, `Arbitrating`, `Timeout`).
* **Complex Transition Logic**: Implement conditional branching, multi-signature approvals, or time-locked transitions within the `update` function.
* **Interoperability**: As long as your contract implements the `ITIP1` interface (emitting standard events and allowing state fetches), it remains fully compatible with the TIP ecosystem indexers and frontends.

> **Note:** While `TIP_Protocol` enforces a strict standard flow for consistency, the protocol itself supports infinite extensibility for specialized use cases.

---

## 🛡️ Mainnet Verification & Stress Testing

To ensure the robustness and security of the TIP Protocol, a comprehensive **Logic Verification** and **Error Attack Simulation** has been executed directly on the **BSC Mainnet**.

* **Verification Contract**: `0xa5173b193d1c5a8ff5884561aad4e2b4fb02a14a`
* **Status**: ✅ **Passed (100% Coverage)**

We have validated all critical business logic and security boundaries, including:
1.  **Happy Paths**: Verified standard task lifecycles (Completion, Cancellation, Dispute Resolution, and Redo flows).
2.  **Error Paths**: Confirmed that all invalid state transitions (e.g., reverting a completed task) are correctly blocked by the contract.
3.  **Attack Vectors**: Simulated and blocked unauthorized access, input overflows, and replay attacks.

This live-fire testing confirms that the protocol behaves exactly as designed under real-world conditions.

---

## 🔒 Security Features (Mainnet & Stable)

The production contract (`0x9FE...` on Mainnet) includes the following security enhancements:

* **Existence Check**: Prevents interaction with non-existent task IDs (`NotFound` error).
* **Access Control**: Only the registered `controller` can update a task (`Auth` error).
* **Input Validation**: Strict bounds checking on state inputs (`> 6` reverts).
* **Transition Logic**: Validates state moves against the allowed transition matrix (e.g., cannot move from `Completed` back to `Open`). Returns `InvalidTransition(from, to)` on failure.

---

## 📄 License

This project is licensed under the **MIT License**.
