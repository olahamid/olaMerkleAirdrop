// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IwrappedEther {

    receive() external payable;

    function deposit() external payable;

    function totalSupply() external view returns (uint256) ;

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function transfer(address, uint256) external returns(bool);

}
