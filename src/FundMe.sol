// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256; //!!!!!!!!!!!!!!!!!!!!!!!!!!!!--


    address[] private s_funders; //KEEP TRACKING OF FUNDERS
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeedAddress; //storage variable
    address private immutable i_owner;


    uint256 public minimumUSD; //usd

    constructor(address _priceFeedAddress /* uint256 _minimumUSD */) {
        i_owner = msg.sender;
        minimumUSD = 5e18 /* _minimumUSD */;
        s_priceFeedAddress = AggregatorV3Interface(_priceFeedAddress);
    }

    function fund() public payable {
        // -----------------IMPORTANT-------------
        // here msg.value  is the first parameter for function getConversionRate
        require(
            msg.value.getConversionRate(s_priceFeedAddress) > minimumUSD,
            "Not enough ETH sended"
        );

        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdrawCheaper() public onlyOwner {
        //ONLYOWNER checks for owner
        uint256 funderLength = s_funders.length;
        for (uint256 index = 0; index < funderLength; index++) {
            address funder = s_funders[index];
            s_addressToAmountFunded[funder] = 0;
        }

        // funders = new address[](0);
        delete s_funders;

        //withdrawing funds
        (bool callSucess,) = i_owner.call{value: address(this).balance}("");
        require(callSucess, "Call Failed");
    }

    function withdraw() public onlyOwner {
        //ONLYOWNER checks for owner

        for (uint256 index = 0; index < s_funders.length; index++) {
            address funder = s_funders[index];
            s_addressToAmountFunded[funder] = 0;
        }

        // funders = new address[](0);
        delete s_funders;

        //withdrawing funds
        (bool sucess,) = i_owner.call{value: address(this).balance}("");
        require(sucess);
    }

    modifier onlyOwner() {
        // require(msg.sender != i_owner, "You are not the owner");
        // require(msg.sender != i_owner, NotOwner());
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        return AggregatorV3Interface(s_priceFeedAddress).version();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * view / pure functions (Getters)
     * write these for private storage variable
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return  i_owner;
    }
}
