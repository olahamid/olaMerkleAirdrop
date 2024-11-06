// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {olaMerkleAirdrop} from "../src/olaMerkleAirdrop.sol";
import {wrappedEther} from "../src/wrappedEther.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
contract deployOlaAirdrop is Script{
    olaMerkleAirdrop public olaAirdrop;
    wrappedEther public wETH;
    bytes32 public root = 0x69bde30dcb382cb90cbc1cb73b6c5c1b0853b2ef1b1929efbfb94355451bafbf;
    uint public totalETH = 100 * 1e18;


    function run() external {
        deployDrops();
    }

    function deployDrops() public returns (olaMerkleAirdrop, wrappedEther) {
        vm.startBroadcast();
        wETH = new wrappedEther();
        olaAirdrop = new olaMerkleAirdrop(root, wETH);
        wETH.mint(address(olaAirdrop), totalETH);
        vm.stopBroadcast();

        return (olaAirdrop, wETH);

    }
}