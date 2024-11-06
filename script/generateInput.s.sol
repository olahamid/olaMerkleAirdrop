// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";

// Merkle tree input file generator script
contract GenerateInput is Script {
    // uint256 private constant AMOUNT = 25 * 1e18;
    string[] types = new string[](2);
    uint256 count;
    uint[] private AMOUNT = new uint[](5);
    string[] whitelist = new string[](5);
    string private constant  INPUT_PATH = "/script/target/input.json";
    
    function run() public {
        types[0] = "address";
        types[1] = "uint";
        whitelist[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[3] = "0xa2b2b1E2f7C291fc64675C56b60c4E8a092Eb7B9";
        whitelist[4] = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";
        
            
        AMOUNT[0] = 25 * 1e18;
        AMOUNT[1] = 10 * 1e18;
        AMOUNT[2] = 20 * 1e18;
        AMOUNT[3] = 30 * 1e18;
        AMOUNT[4] = 20 * 1e18;


        count = whitelist.length;
        string memory input = _createJSON();
        // write to the output file the stringified output json tree dumpus 
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console.log("DONE: The output is found at %s", INPUT_PATH);
    }

    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        //string memory amountString = vm.toString(AMOUNT); // convert amount to string
        string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',whitelist[i],'"',', "1":', '"',vm.toString(AMOUNT[i]),'"', ' }');
            } else {
            json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',whitelist[i],'"',', "1":', '"',vm.toString(AMOUNT[i]),'"', ' },');
            }
        }
        json = string.concat(json, '} }');
        
        return json;
    }
}