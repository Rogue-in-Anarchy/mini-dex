// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/MultiSwap.sol";
import "../src/IERC20.sol";

contract MultiSwapTest is Test {
    MultiSwap public multiSwap;

    address DAIContract = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;
    address LINKContract = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    address ethUsd = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address diaUsd = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;
    address linkUsd = 0xc59E3633BAAC79493d908e63626716e204A45EdF;

    address DAIWHALE = 0xFE95E892D250322a65d87b1D5B3BcB78c8c8EF7F;
    address LINKWHALE = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

    function setUp() public {
        multiSwap = new MultiSwap();
    }

    // function testGetDATAPRICE() public view {
    //     int ethUSDPrice = multiSwap.LatestETHprice();
    //     int DAIUSDPrice = multiSwap.LatestDAIprice();
    //     int LINKUSDPrice = multiSwap.LatestLinkprice();

    //     // console.log("ETH price: ", price);
    //     console2.log("ethUSD price: ", ethUSDPrice );
    //     console2.log("DAIUSD price: ", DAIUSDPrice);
    //     console2.log("LINKUSD price: ", LINKUSDPrice );
    //     assertTrue(ethUSDPrice > 0);
    //     assertTrue(DAIUSDPrice > 0);
    //     assertTrue(LINKUSDPrice > 0);
    // }

    // function testGetDerivedPrice() public view {
    //     int rate = multiSwap.getDerivedPrice(ethUsd, diaUsd, 8);

    //     console2.log("rate==>", rate);
    // }

    // function testSwapEthForDAI() public {
    //     vm.startPrank(0xd0aD7222c212c1869334a680e928d9baE85Dd1d0);
    //     IERC20(DAIContract).transfer(address(multiSwap), 30000e18);

    //     uint256 _amount = 1e18;

    //     uint256 resultBeforeSwap = IERC20(DAIContract).balanceOf(
    //         0x77158c23cC2D9dd3067a82E2067182C85fA3b1F6
    //     );

    //     multiSwap.swapTokens(address(0), DAIContract, _amount);
    //     uint256 result = IERC20(DAIContract).balanceOf(
    //         0x77158c23cC2D9dd3067a82E2067182C85fA3b1F6
    //     );

    //     console2.log("result resultBeforeSwap swap", resultBeforeSwap);
    //     console2.log("result after swap", result);

    //     assertLt(result, _amount);
    // }

    function testSwapDAIforETH() public {
        fundContract();
        vm.startPrank(DAIWHALE);
        // vm.deal(address(DAIWHALE), 0.02 ether);
        fundUserEth(DAIWHALE);
        fundUserToken(DAIWHALE, DAIContract);

        uint256 _amount = 10;

        getBeforeBalance(DAIWHALE, DAIContract, "DAI");

        // approve multiswap to remove money
        IERC20(DAIContract).approve(address(multiSwap), _amount);

        multiSwap.swapTokens(DAIContract, address(0), _amount);

        getAfterBalance(DAIWHALE, DAIContract, "DAI");
        vm.stopPrank();
    }

    // function testSwapLINKforETH() public {
    //     fundContract();
    //     vm.startPrank(LINKWHALE);
    //     // vm.deal(address(DAIWHALE), 0.02 ether);
    //     fundUserEth(LINKWHALE);
    //     fundUserToken(LINKWHALE, LINKContract);

    //     uint256 _amount = 10;

    //     getBeforeBalance(LINKWHALE, LINKContract, "LINK");

    //     // approve multiswap to remove money
    //     IERC20(LINKContract).approve(address(multiSwap), _amount);

    //     multiSwap.swapTokens(LINKContract, address(0), _amount);

    //     getAfterBalance(LINKWHALE, LINKContract, "DAI");
    // }

    function fundContract() public {
        vm.deal(address(multiSwap), 100 ether);
        deal(address(DAIContract), address(multiSwap), 100000 ether);
        deal(address(LINKContract), address(multiSwap), 100000 ether);

        console.log("ETHERS in Contract:  ", address(multiSwap).balance);
        console.log(
            "DAI in Contract:  ",
            IERC20(DAIContract).balanceOf(address(multiSwap))
        );
        console.log(
            "LINK in Contract:  ",
            IERC20(LINKContract).balanceOf(address(multiSwap))
        );
    }

    function getBeforeBalance(
        address userAddress,
        address _tokenContract,
        string memory tokenNAME
    ) public view {
        console.log("ETH BALANCE BEFORE ===>", address(userAddress).balance);
        console.log(
            "TOKEN BALANCE BEFORE ===>",
            IERC20(_tokenContract).balanceOf(DAIWHALE),
            tokenNAME
        );
    }

    function getAfterBalance(
        address userAddress,
        address _tokenContract,
        string memory tokenNAME
    ) public view {
        console.log("ETH BALANCE BEFORE ===>", address(userAddress).balance);
        console.log(
            "TOKEN BALANCE BEFORE ===>",
            IERC20(_tokenContract).balanceOf(DAIWHALE),
            tokenNAME
        );
    }

    function fundUserEth(address userAdress) public {
        vm.deal(address(userAdress), 0.5 ether);
    }

    function fundUserToken(address userAddress, address tokenAddress) public {
        deal(address(tokenAddress), address(userAddress), 100 ether);
    }
}
