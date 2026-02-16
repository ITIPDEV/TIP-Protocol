// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TIP Protocol.

pragma solidity ^0.8.20;

interface ITIP1 {
    event Updated(uint256 indexed id, uint8 indexed oldState, uint8 indexed newState);
    function update(uint256 id, uint8 newState) external;
    function fetch(uint256 id) external view returns (address controller, uint8 state);
}

contract TIP_Protocol is ITIP1 {
    // Standard State Definitions for ITIP1
    enum State { 
        Open,       // 0: Initialized
        Taken,      // 1: Accepted by worker
        Submitted,  // 2: Work uploaded
        Completed,  // 3: Finalized (Terminal)
        Disputed,   // 4: Conflict resolution
        Cancelled,  // 5: Revoked (Terminal)
        Failed      // 6: Unsuccessful (Terminal)
    }

    uint256 private constant _S0 = 0x22; 
    uint256 private constant _S1 = 0x54; 
    uint256 private constant _S2 = 0x1A; 
    uint256 private constant _S3 = 0x00; 
    uint256 private constant _S4 = 0x48; 

    uint256 private constant _TRANSITIONS = _S0 | (_S1 << 8) | (_S2 << 16) | (_S3 << 24) | (_S4 << 32);

    error Exists();
    error Auth();
    error NotFound();
    error InvalidTransition(uint8 from, uint8 to); 

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
        if (newStateRaw > 6) revert InvalidTransition(uint8(_tasks[id].state), newStateRaw);

        Task storage t = _tasks[id];
        if (t.controller == address(0)) revert NotFound();
        if (msg.sender != t.controller) revert Auth();

        State newState = State(newStateRaw);
        State oldState = t.state;
        if (oldState == newState) return;
        
        if (((_TRANSITIONS >> (uint8(oldState) << 3)) & 0xFF) >> uint8(newState) & 1 == 0) {
            revert InvalidTransition(uint8(oldState), uint8(newState));
        }

        t.state = newState;
        emit Updated(id, uint8(oldState), uint8(newState));
    }

    function fetch(uint256 id) external view returns (address, uint8) {
        Task storage t = _tasks[id];
        return (t.controller, uint8(t.state));
    }
}
