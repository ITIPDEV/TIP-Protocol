// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/contracts/TIP_Protocol_Mainnet.sol";

contract DeployTIP is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address deployerAddr = vm.addr(deployerPrivateKey);

        console2.log("-------------------------------------------");
        console2.log("Deployer:", deployerAddr);
        console2.log("-------------------------------------------");

        vm.startBroadcast(deployerPrivateKey);

        TIP_Protocol tip = new TIP_Protocol();
        console2.log("Contract:", address(tip));

        uint256 demoTaskId = 2026;
        tip.register(demoTaskId, deployerAddr);
        tip.update(demoTaskId, 1);

        console2.log("Status: Workflow Success");
        console2.log("-------------------------------------------");

        vm.stopBroadcast();
    }
}
