// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Genesis} from "../src/Genesis.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GenesisScript is Script {
    Genesis public genesis;

    function setUp() public {}

    function run(address _master, IERC20 _token, IERC20 _wrapperToken) public {
        vm.startBroadcast();

        genesis = new Genesis(_master, _token, _wrapperToken);

        vm.stopBroadcast();
    }
}
