// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/contracts/TIP_Protocol_Mainnet.sol";

contract TIPTest is Test {
    TIP_Protocol public tip;
    address public controller = address(0x123);

    function setUp() public {
        tip = new TIP_Protocol();
    }

    function test_Workflow() public {
        uint256 taskId = 1001;

        vm.startPrank(controller);
        
        tip.register(taskId, controller);
        
        (address c, uint8 s) = tip.fetch(taskId);
        assertEq(c, controller);
        assertEq(s, 0);

        tip.update(taskId, 1);
        
        (_, s) = tip.fetch(taskId);
        assertEq(s, 1);

        vm.stopPrank();
    }
}
