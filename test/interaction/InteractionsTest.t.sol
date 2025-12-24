// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {IntractionFundMe, IntractionWithdraw } from "../../script/Interaction.s.sol";


//here we testing IntractionTest.t.sol  , so firstly we have to deploy this IntractionFundMe contract

contract IntractionsTest is Test {
    FundMe fundMe;

    //take name of user and return address of account..
    address USER = makeAddr("user"); //cheat function of forge-std
    uint256 constant SEND_VALUE = 0.1 ether; // DECIMALS are not working in solidity but ether will
    //0.1 ether = 10000000000000000     10**17
    uint256 STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function  setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerCanWithdrawIntraction() public {
        IntractionFundMe intractionFundMe = new IntractionFundMe();
        intractionFundMe.fundFundMe(address(fundMe));

        IntractionWithdraw intractionWithdraw = new IntractionWithdraw();
        intractionWithdraw.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
