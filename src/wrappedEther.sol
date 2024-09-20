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

/// @title wrappedEther
/// @author Ola Hamid
/// @notice 

import {IwrappedEther} from "../../src/interface/IwrappedEther.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract wrappedEther is IwrappedEther {
    string public name = "wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimal = 18;
    uint256 public s_totalSupply;

    error wETH_insufficientFunds();

    event e_deposit(address indexed dst, uint256 wad);
    event e_withdrawal(address indexed dst, uint256 wad);
    event e_mint(address indexed dst, uint wad);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowance;


    function deposit() public payable {
        s_totalSupply += msg.value;
        balanceOf[msg.sender] += msg.value;
        emit e_deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public {
        if (balanceOf[msg.sender] < wad) {
            revert wETH_insufficientFunds();
        }
        s_totalSupply -= wad;
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit e_withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice this function allows a token owner to authorize another address [spender] GUY, to spend a specific amount
     * @param guy this is the [SPENDER], he has the authorization to spend money on behalf of the caller
     * @param wad amount allowed to be spent
     */
    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        return true;
    }

    /**
     * @notice allows a third party[spender(maybe the contract or GUY)] to send money from the owner to the a specific receiver
     * @param src address from. called token Owner
     * @param dst address to, called token reciever
     * @param wad amount to be recieived
     */
    function transferFrom(address src, address dst, uint256 wad) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        return true;
    }


    function transfer(address dst, uint256 wad) public returns(bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function mint(address to, uint amount) public {
        s_totalSupply += amount;
        balanceOf[to] += amount;
        emit e_mint(to, amount);

    }

    receive () external payable{
        deposit();
    }
}
