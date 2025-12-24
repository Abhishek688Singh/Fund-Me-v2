// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

// ==================================================================================================
// 1. Unit: Testing a single function
// 2. Integration: Testing multiple functions
// 3. Forked: Testing on a forked network
// 4. Staging: Testing on a live network (testnet or mainnet)
// ==================================================================================================

contract FundMeTest is Test {
    FundMe fundMe;

    //take name of user and return address of account..
    address USER = makeAddr("user"); //cheat function of forge-std
    uint256 constant SEND_VALUE = 0.1 ether; // DECIMALS are not working in solidity but ether will
    //0.1 ether = 10000000000000000     10**17
    uint256 STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        //give USER 10 ether or STARTING_BALANCE
        deal(USER, STARTING_BALANCE); //cheat code of solidity (foundary)
    }

    function testMinimumUSD() public view {
        //unit test
        assertEq(fundMe.minimumUSD(), 5e18);
    }

    function testOwner() public view {
        //unit test
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        // assertEq(fundMe.i_owner(), address(this) );
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        //forked test
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4); //on sepolia and Anvil
        // assertEq(version, 6); // on eth mainnet
    }

    function testFundMeFailsNotSendEnough() public {
        vm.expectRevert(); //next line should revert
        fundMe.fund(); //this will fail because we call fund with 0eth send
        //if we want to add value in this write like this:
        //fundMe.fund{value:....}();
    }

    function testForAddressToAmountFundedDataStructure() public /* funded */{
        vm.prank(USER); //NEXT txn will send by USER
        fundMe.fund{value: SEND_VALUE}(); //1st txn to contract

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    modifier funded() {
        vm.prank(USER); //NEXT txn will send by USER
        fundMe.fund{value: SEND_VALUE}(); //1st txn to contract
        _;
    }

    function testAddFundersInArrayOfFunders() public funded {
        address sender = fundMe.getFunders(0);
        assertEq(sender, USER);
    }

    function testOnlyOwnerCanWidraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWidrawWithSingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        //DO THIS STUFF, IF YOU WANT TO CHECK GAS MANUALLY
        // uint256 gasStart = gasleft(); //fun in foundry, return gas left
        // vm.txGasPrice(GAS_PRICE); //default is 0 in vm
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //tx.gasprice --> returns current gas price
        // console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWidrawWithManyFunderCheaper() public {
        //Arrange
        uint160 numberOfFunders = 10;//i --> used to iterate as address
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i <= numberOfFunders; i++){
            //vm.prank() 
            //vm.deal(,)  or deal(,)
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: STARTING_BALANCE}();//funded by all address from 1-->10
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance; 

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawCheaper();
        vm.stopPrank();

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );

    }

    function testWidrawWithManyFunder() public {
        //Arrange
        uint160 numberOfFunders = 10;//i --> used to iterate as address
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i <= numberOfFunders; i++){
            //vm.prank() 
            //vm.deal(,)  or deal(,)
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: STARTING_BALANCE}();//funded by all address from 1-->10
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance; 

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );

    }
}
