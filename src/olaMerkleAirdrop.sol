// Layout:
//     - pragma
//     - imports
//     - interfaces, libraries, contracts
//     - type declarations
//     - state variables
//     - events
//     - errors
//     - modifiers
//     - functions
//         - constructor
//         - receive function (if exists)
//         - fallback function (if exists)
//         - external
//         - public
//         - internal
//         - private
//         - view and pure functions

// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


/// @title olaMerkleAirdrop
/// @author Ola Hamid
/// @notice 
    //------------------------//
    //-------IMPORTS----------//
    //------------------------//
import {wrappedEther} from "../src/wrappedEther.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";


contract olaMerkleAirdrop is wrappedEther{
    using SafeERC20 for wrappedEther;

    //------------------------//
    //-----state Var----------//
    //------------------------//
    bytes32 private immutable i_merkleRoot;
    wrappedEther private immutable i_wrappedETH;
    mapping (address claimer => bool claimed) private s_hasClaimed;

    //------------------------//
    //--=-----EVENTS----------//
    //------------------------//
    event olaAirdropClaimEvent(address indexed _account, uint indexed _amount);

    //------------------------//
    //---------ERROR----------//
    //------------------------//
    error olaAirdropInvalidMerkleVerification();
    error olaAirdropAlreadyClaimedError();
    //------------------------//
    //-----CONSTRUCTOR--------//
    //------------------------//
    constructor (bytes32 merkleRoot, wrappedEther wrappedETH) {
        i_merkleRoot = merkleRoot;
        i_wrappedETH = wrappedETH;
    }

    //------------------------//
    //-------Function---------//
    //------------------------//
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) public{
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        if (s_hasClaimed[account] == true) {
            revert olaAirdropAlreadyClaimedError();
        }
        if (MerkleProof.verify(merkleProof, i_merkleRoot, leaf) != true) {
            revert olaAirdropInvalidMerkleVerification();
        } 
        
        emit olaAirdropClaimEvent(account, amount);

        i_wrappedETH.transferFrom(address(this),account, amount);
    }

    function getMerkleRoot() public view returns(bytes32) {
        return i_merkleRoot;
    }

    function getToken() public view returns(wrappedEther) {
        return i_wrappedETH;
    }
}

