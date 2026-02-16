// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TIP Protocol.

pragma solidity ^0.8.20;

interface ITIP1 {
    event Updated(uint256 indexed id, uint8 indexed oldState, uint8 indexed newState);

    function update(uint256 id, uint8 newState) external;

    function fetch(uint256 id) external view returns (address controller, uint8 state);
}

contract TIP1 is ITIP1 {
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
        uint8 state;
    }

    mapping(uint256 => Task) private _tasks;

    event Created(uint256 indexed id, address indexed controller);

    function register(uint256 id, address controller) external {
        if (controller == address(0)) revert Auth();
        if (_tasks[id].controller != address(0)) revert Exists();
        
        _tasks[id].controller = controller;
        emit Created(id, controller);
    }

    function update(uint256 id, uint8 newState) external {
        Task storage t = _tasks[id];
        uint8 oldState = t.state;

        if (msg.sender != t.controller) revert Auth();
        if (oldState == newState) return;
        
        if (((_TRANSITIONS >> (oldState << 3)) & 0xFF) >> newState & 1 == 0) revert Flow();

        t.state = newState;
        emit Updated(id, oldState, newState);
    }

    function fetch(uint256 id) external view returns (address, uint8) {
        Task storage t = _tasks[id];
        return (t.controller, t.state);
    }
}
