// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITIP1 {
    event Updated(uint256 indexed id, uint8 indexed oldState, uint8 indexed newState);

    function update(uint256 id, uint8 newState) external;

    function fetch(uint256 id) external view returns (address controller, uint8 state);
}
