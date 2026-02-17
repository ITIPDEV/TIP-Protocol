// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TIP Protocol.

pragma solidity ^0.8.20;

/**
 * @title ITIP1 Interface
 * @notice The standard interface for the Task Interaction Protocol.
 */
interface ITIP1 {
    event Updated(uint256 indexed id, uint8 indexed oldState, uint8 indexed newState);

    function update(uint256 id, uint8 newState) external;

    function fetch(uint256 id) external view returns (address controller, uint8 state);
}

/**
 * @title TIP1 v2.1 (Standard Implementation)
 * @notice The standard, developer-friendly implementation of TIP-1.
 */
contract TIP1v2 is ITIP1 {
    
    // Semantic State Definitions
    enum State { 
        Open,       // 0
        Taken,      // 1
        Submitted,  // 2
        Completed,  // 3
        Disputed,   // 4
        Cancelled,  // 5
        Failed      // 6
    }

    // State Constants (Hex representation of valid transitions)
    // _S0 (Open) -> Taken(1), Cancelled(5)
    uint256 private constant _S0 = 0x22; 
    // _S1 (Taken) -> Submitted(2), Disputed(4), Failed(6)
    uint256 private constant _S1 = 0x54; 
    // _S2 (Submitted) -> Completed(3), Taken(1), Disputed(4)
    uint256 private constant _S2 = 0x1A; 
    // _S3 (Completed) is Terminal
    uint256 private constant _S3 = 0x00; 
    // _S4 (Disputed) -> Completed(3), Failed(6)
    uint256 private constant _S4 = 0x48; 
    // _S5 (Cancelled) and _S6 (Failed) are Terminal

    // Packed transition logic table
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
        State state;
    }

    mapping(uint256 => Task) private _tasks;

    event Created(uint256 indexed id, address indexed controller);

    function register(uint256 id, address controller) external {
        if (controller == address(0)) revert Auth();
        if (_tasks[id].controller != address(0)) revert Exists();
        
        _tasks[id].controller = controller;
        emit Created(id, controller);
    }

    function update(uint256 id, uint8 newStateRaw) external {
        if (newStateRaw > 6) revert Flow();
        
        State newState = State(newStateRaw);
        Task storage t = _tasks[id];
        State oldState = t.state;

        if (msg.sender != t.controller) revert Auth();
        if (oldState == newState) return;
        
        // Bitwise transition check
        if (((_TRANSITIONS >> (uint8(oldState) << 3)) & 0xFF) >> uint8(newState) & 1 == 0) revert Flow();

        t.state = newState;
        emit Updated(id, uint8(oldState), uint8(newState));
    }

    function fetch(uint256 id) external view returns (address, uint8) {
        Task storage t = _tasks[id];
        return (t.controller, uint8(t.state));
    }
}
