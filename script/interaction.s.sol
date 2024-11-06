//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console } from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {olaMerkleAirdrop} from "../src/olaMerkleAirdrop.sol";


contract claimOlaAirdrop is Script {

    address claimAddress = 0xa2b2b1E2f7C291fc64675C56b60c4E8a092Eb7B9;
    uint256 claimingAmount = 25 * 1e18;
    bytes32 Proof1 = 0x7ee72d255a633863e5c78a7ad4411105034036f9ca884f045593d93c24c5727c;
    bytes32 Proof2 = 0x9d1d3b830168fc40b4f27d0823ea4d49be4d2c6ba8383afb297b6e31dc37e210;
    bytes32[] proof = [Proof1, Proof2];
    bytes private SIGNATURE = hex"af12c387d6138852c14305da8c4fa170cffe4921460977f96349da3c2a6d462817e5eab2a78f632ddd6e94fb06dd1601ceafa0b47d005bad7150ad45e1a9ac231c";
    
    function claimAirdrop (address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        console.log("claiming airdrop");
        olaMerkleAirdrop(airdrop).claim(claimAddress,claimingAmount, proof, v, r, s);
        vm.stopBroadcast();
        console.log("claiming airdrop");

    }
    function splitSignature(bytes memory _sig) public pure returns(uint8 v,bytes32 r, bytes32 s) {
        require(_sig.length == 65, "Invalid signature");
        assembly {
            
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
     function run() external {
        address mostRecentlyDeployedAddress = DevOpsTools.get_most_recent_deployment("olaMerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployedAddress);
    }

}