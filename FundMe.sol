// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 1e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunders;
    //Immutable variables can be set inside the constructor but cannot be modified afterwards.
    address public immutable I_owner;

    constructor() {
        I_owner = msg.sender;
    }

    function fund() public payable {
        // Allow user to send $
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        require(
            (msg.value).getConversionRate() >= MINIMUM_USD,
            "didn't send enough Eth"
        );
        funders.push(msg.sender);
        addressToAmountFunders[msg.sender] += msg.value;
    }

    function withDraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunders[funder] = 0;
        }
        funders = new address[](0);

        // Transfer
        // ******TYPE******:
        // msg.sender = address;
        // payable(msg.sender) = payable;
        // payable(msg.sender).transfer(address(this).balance);

        // //Send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Fail");

        //Call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call Failed");
    }

    modifier onlyOwner() {
        require(msg.sender == I_owner, "Sender is not owners");
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
