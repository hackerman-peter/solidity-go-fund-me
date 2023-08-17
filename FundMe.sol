// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();
error CallFailure();
error MinEthError();

contract FundMe {

    using PriceConverter for uint256;

    uint public constant MIN_USD = 5 * 1e18;
    uint public version;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable{

        require(msg.value.getConversionRate() >= MIN_USD, "Does not meet the minimum ETH requirement");
        if (msg.value.getConversionRate() >= MIN_USD) { revert MinEthError(); }
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public checkOwner{        

        for (uint i = 0; i < funders.length; i++) {
            address funder = funders[i];
            // withdraw the funds
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // call 
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");    
        if (callSuccess) { revert CallFailure(); }

    }

    modifier checkOwner() {
        // require(msg.sender == i_owner, "You are not the owner of this contract.");
        if (msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    receive() external payable { fund(); }

    fallback() external payable { fund(); }

}
