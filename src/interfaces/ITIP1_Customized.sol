// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// This version is customized for specific calls. DO NOT use for new contract versions.
interface ITIP1 {
    event Created(uint256 indexed id, address indexed controller);
    
    event Updated(uint256 indexed id, uint8 indexed oldState, uint8 indexed newState);

    function register(uint256 id, address controller) external;
    
    function update(uint256 id, uint8 newState) external;
    
    function fetch(uint256 id) external view returns (address controller, uint8 state);
}
