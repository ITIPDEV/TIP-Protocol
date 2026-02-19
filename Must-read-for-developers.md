# TIP Protocol Integration & Deployment Guide

> **Important:** This document outlines the standard procedures for deploying new TIP-compatible contracts and interacting with the deployed TIP1 ecosystem. Developers should strictly choose the appropriate interface strategy based on their specific integration requirements.

---

## 1. For Protocol Developers (New Contract Deployment)

If you are developing a new iteration of the protocol (e.g., `TIP2`, `TIP3`) or a custom implementation, strict adherence to the **Standard Interface** is required to ensure ecosystem compatibility.

* **Objective**: To ensure all TIP-compliant contracts share a common "Lowest Common Denominator" for state management and querying.
* **Recommended Interface**: `ITIP1` (Standard / Lean Version)
* **Implementation Strategy**: Your contract should inherit from `ITIP1` and implement the core logic for `update` and `fetch`.

> **Note on Creation Logic:** You are free to implement your own creation logic (e.g., `register`, `mint`, or `create`). The standard interface intentionally does not enforce a specific creation signature to allow for future evolution (e.g., internal counters vs. external ID injection).

---

## 2. For Integrators & DApp Developers (Interaction)

When building Applications, Agents, or External Contracts that interact with the TIP Protocol, choose your interface based on your specific use case.

### Option A: TIP1 Dedicated Integration (Recommended for Current Business)

* **Use Case**: You are building a DApp or Agent specifically designed to work with the **current live TIP1 Contract**. You require full control over the task lifecycle, including creation.
* **Interface**: `ITIP1 Customized` (Full-Feature Version)
* **Description**: This interface is strictly typed to match the deployed TIP1 contract. It explicitly includes the `register` function and `Created` event.
* **Advantage**: Provides "Out-of-the-Box" access to all contract functions (Register, Update, Fetch).
* **⚠️ Constraint**: **Tightly coupled with TIP1.** May not be compatible with future TIP versions if the registration logic changes.

### Option B: Universal Compatibility (Recommended for Generic Tools)

* **Use Case**: You are building a generic tool (e.g., a multi-protocol dashboard, wallet, or arbitrator) that needs to support TIP1, TIP2, and future versions simultaneously.
* **Interface**: `ITIP1` (Standard / Lean Version)
* **Description**: Contains only the intersection of all TIP protocols: `update` and `fetch`.
* **Advantage**: **Maximum Compatibility**. Prevents transaction reverts caused by function signature mismatches in the creation phase.
* **Requirement**: To create tasks, you must implement a "Self-Supplemented" logic in your contract (e.g., manually encoding the ABI for `register` or implementing a custom adapter) to handle the specific creation method of the target contract.

---

## 3. Interface Selection Matrix

Please refer to the table below to select the appropriate interface for your development needs:

| Feature | ITIP1 (Standard) | ITIP1 Customized (Full) |
| :--- | :--- | :--- |
| **Primary Audience** | **Protocol Creators** & **Generic Integrators** | **TIP1 Business Developers** |
| **File Path** | `src/interfaces/ITIP1.sol` | `src/interfaces/ITIP1_Customized.sol` |
| **Contains `register`** | No | **Yes** |
| **Contains `Created` Event** | No | **Yes** |
| **Capability** | Read & Update Only | **Create**, Read & Update |
| **Coupling** | **Loose** (High Flexibility) | **Tight** (Optimized for TIP1) |
| **Forward Compatibility** | **High** (Safe for TIP2/TIP3) | **Low** (Risk of ABI mismatch) |
| **Dev Effort** | High (Requires manual supplementary code for creation) | **Low** (Plug and Play) |

---

*For specific implementation details, please refer to the source code within the repository.*
