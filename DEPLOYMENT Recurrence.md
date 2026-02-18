# TIP Protocol Deployment Guide (Hackathon Edition)



> For Hackathon Participants & Judges: This guide provides the fastest method to deploy a fresh instance of the TIP_Protocol (TIP1) to any EVM-compatible testnet (Sepolia, Base Sepolia, etc.) or local test environment using Remix IDE and scripts.



---



## ✅ Prerequisites



1.  **Wallet**: MetaMask (or compatible) installed.

2.  **Network**: Connected to your desired Testnet (e.g., Sepolia).

3.  **Gas**: Sufficient Testnet ETH/Tokens for deployment.



---



## 🚀 Method 1: The "5-Minute" Deployment (Remix IDE)



This is the recommended method for quick reproduction and testing.



### Step 1: Prepare the Code

1.  Open [Remix IDE](https://remix.ethereum.org/) in your browser.

2.  In the **File Explorer** , click the `+` icon to create a new file.

3.  Name it: `TIP_Protocol.sol`.

4.  Copy and paste the **entire source code** below into the file:



    <details open>

    <summary>👁️ Source Code </summary>



    ```solidity

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

    ```

    </details>



### Step 2: Compile 

1.  Click the **Solidity Compiler** icon .

2.  **Compiler Version**: Select `0.8.20` (or newer).

3.  **EVM Version**: Select **`shanghai`** (This ensures `PUSH0` opcode optimization is used).

    * *Note: If `shanghai` is not available, select `default`.*

4.  Click the blue button **Compile TIP_Protocol.sol**.

5.  *Success Check: You should see a green checkmark on the compiler icon.*



### Step 3: Deploy

1.  Click the **Deploy & Run Transactions** icon .

2.  **Environment**: Select `Injected Provider - MetaMask`.

    * *Remix will ask to connect to your wallet. Approve it.*

3.  **Contract**: Ensure `TIP_Protocol` is selected in the dropdown menu.

4.  Click the orange **Deploy** button.

5.  Confirm the transaction in MetaMask.



### Step 4: Verify

Once deployed, check the output console at the bottom of Remix.

1.  Copy the **Contract Address**.

2.  Go to the block explorer (e.g., Etherscan/SepoliaScan).

3.  Paste the address and verify your contract code.



---



⚡ Method 2: The "Magic Button" Demo (Foundry)



If you have Foundry installed, you can simulate the entire protocol lifecycle (Deployment + Registration + State Transition) in 60 seconds without spending real Gas.



# 1. Install dependencies
forge install foundry-rs/forge-std

# 2. Run the automated simulation script
forge script script/Deploy.s.sol


What happens? Foundry will spin up a local EVM, deploy the TIP Protocol, register a demo task, and execute a state update. You will see the success logs directly in your terminal.



---



Success Check
Whether you use Method 1 or Method 2, the TIP Protocol will enforce the strict 7-state transition logic, ensuring high-integrity task management on-chain.
