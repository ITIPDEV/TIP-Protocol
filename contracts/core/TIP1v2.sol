// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TIP Protocol.

pragma solidity ^0.8.20;

import "./interfaces/ITIP1.sol";

/**
 * @title TIP1 v2 (Standard Implementation)
 * @notice The developer-friendly implementation of the TIP-1 Protocol.
 * @dev Introduces Enums for state clarity while maintaining ITIP1 interface compatibility.
 */
contract TIP1v2 is ITIP1 {
    /**
     * @notice Semantic State Definitions
     * @dev Maps raw uint8 codes to readable names for better DX (Developer Experience).
     */
    enum State { 
        Open,       // 0: Initial state
        Taken,      // 1: Task picked up
        Submitted,  // 2: Work submitted
        Completed,  // 3: Finalized (Terminal)
        Disputed,   // 4: Under dispute
        Cancelled,  // 5: Revoked (Terminal)
        Failed      // 6: Unsuccessful (Terminal)
    }

    // State Constants (Hex representation of valid transitions)
    // Same logic as v1, just wrapped for readability
    uint256 private constant _S0 = 0x22; 
    uint256 private constant _S1 = 0x54; 
    uint256 private constant _S2 = 0x1A; 
    uint256 private constant _S3 = 0x00; 
    uint256 private constant _S4 = 0x48; 

    uint256 private constant _TRANSITIONS = 
        _S0 | 
        (_S1 << 8)  | 
        (_S2 << 16) | 
        (_S3 << 24) | 
        (_S4 << 32);

    error Exists();
    error Auth();
    error Flow();

    struct Task {
        address controller;
        State state; // Internally uses Enum
    }

    mapping(uint256 => Task) private _tasks;

    event Created(uint256 indexed id, address indexed controller);

    function register(uint256 id, address controller) external {
        if (controller == address(0)) revert Auth();
        if (_tasks[id].controller != address(0)) revert Exists();
        
        _tasks[id].controller = controller;
        // Default is State.Open (0)
        emit Created(id, controller);
    }

    /**
     * @dev Implements ITIP1.update using uint8 for interface compatibility.
     * Converts to State enum internally for validation.
     */
    function update(uint256 id, uint8 newStateRaw) external {
        // Safety Check: Ensure input is within Enum range (0-6)
        if (newStateRaw > 6) revert Flow();
        
        State newState = State(newStateRaw);
        Task storage t = _tasks[id];
        State oldState = t.state;

        if (msg.sender != t.controller) revert Auth();
        if (oldState == newState) return;
        
        // Bitwise logic check
        if (((_TRANSITIONS >> (uint8(oldState) << 3)) & 0xFF) >> uint8(newState) & 1 == 0) revert Flow();

        t.state = newState;
        
        // Emits event using uint8 to match interface
        emit Updated(id, uint8(oldState), uint8(newState));
    }

    function fetch(uint256 id) external view returns (address, uint8) {
        Task storage t = _tasks[id];
        // Convert Enum back to uint8 for external interface
        return (t.controller, uint8(t.state));
    }
}
