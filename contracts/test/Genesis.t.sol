// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Genesis} from "../src/Genesis.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeERC20 is ERC20 {
    constructor() ERC20("Fake Token", "FAKE") {
        _mint(msg.sender, 1_000_000 ether);
    }
}

contract GenesisTest is Test {
    Genesis public genesis;
    FakeERC20 public token;

    address master = address(0xa11ce);

    function setUp() public {
        token = new FakeERC20();
        genesis = new Genesis(master, token);
    }
}
