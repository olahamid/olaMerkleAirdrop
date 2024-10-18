// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {olaMerkleAirdrop} from "../src/olaMerkleAirdrop.sol";
import {wrappedEther} from "../src/wrappedEther.sol";

contract testMerkleAirdrop is Test {
    olaMerkleAirdrop public olaAirdrop;
    wrappedEther public wETH;
    address user;
    uint256 userPrivKey;

    bytes32 public ROOT = 0x56d421160b35433b3742992cc6e7d5644882450964a20adeacbb899f833ace1e;
    uint amountUser0 = 25 * 1e18;
    uint amountOwner = amountUser0 * 10 ; 
    bytes32 public proof1 = 0xdf6009557d8c5d09490c008453617dc47d70a3eede299d0e5fe9f718b43fb5f5;
    bytes32 public proof2 = 0xb842a25c74facf73c3814b5ef7e7437b3f7e85da7a3ea1c4ae3878e10d6de046;
    bytes32[] public proof = [proof1, proof2];

    address public gasPayer = makeAddr("gasPayer");


    function setUp() external {
        wETH = new wrappedEther();
        olaAirdrop = new olaMerkleAirdrop(ROOT, wETH);
        wETH.mint(address(olaAirdrop), amountOwner);
        (user, userPrivKey) = makeAddrAndKey("user");

        gasPayer = makeAddr("gasPayer");

    }
    function testUserCanClaim() public {
        // ACT
        console.log("Airdrop balance amount;", wETH.balanceOf(address(olaAirdrop)));
        uint256 startBalance = wETH.balanceOf(user);
        bytes32 digest = olaAirdrop.getDigest(user, amountUser0);
        wETH.approve(user, amountUser0);
        vm.prank(address(olaAirdrop));
        wETH.approve(user, amountUser0);

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        
        vm.startPrank(gasPayer);
        olaAirdrop.claim(user, amountUser0, proof, v, r, s);
        vm.stopPrank();
        uint256 endingBalance = wETH.balanceOf(user);
        console.log("this is the ending balance;", endingBalance);
        console.log("this is the starting balance;", startBalance);
        assertEq((endingBalance - startBalance), amountUser0);

    }

    function testTransferFrom() public {
        // Approve user to spend owner's tokens
        vm.prank(address(olaAirdrop));
        wETH.approve(user, amountUser0);

        // Check initial balances
        uint256 ownerInitialBalance = wETH.balanceOf(address(olaAirdrop));
        uint256 userInitialBalance = wETH.balanceOf(user);
        console.log(ownerInitialBalance, "this is owner initial balance");
        console.log(userInitialBalance, "this is user initial balance");

        // Simulate user calling transferFrom
        vm.prank(user);
        wETH.transferFrom(address(olaAirdrop), user,amountUser0 );
        // // Check final balances
        uint256 ownerFinalBalance = wETH.balanceOf(address(olaAirdrop));
        uint256 userFinalBalance = wETH.balanceOf(user);
        console.log("this is the final balance", ownerFinalBalance);
        console.log("this is the final user balance", userFinalBalance);
        // // Assertions
        assertEq(ownerFinalBalance, ownerInitialBalance - amountUser0);
        assertEq(userFinalBalance, userInitialBalance + amountUser0);
    }
}
