// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./IERC20.sol";
import "./chainlinkInterface.sol";
import "forge-std/Test.sol";

contract MultiSwap {
    address Owner;

    AggregatorV3Interface internal ETHpriceFeed;
    AggregatorV3Interface internal DAIpriceFeed;
    AggregatorV3Interface internal LinkpriceFeed;
    AggregatorV3Interface internal dataFeed;

    /**
     * Network: Sepolia Testnet
     * ETH/USD Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     * DAI/USD Address: 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19
     * LINK/USD Address: 0xc59E3633BAAC79493d908e63626716e204A45EdF
     */

    // DAI 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6
    // LINK 0x779877A7B0D9E8603169DdbD7836e478b4624789

    // IERC20 public DAIInterface =
    //     IERC20(0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6);

    // IERC20 public LINKInterface =
    //     IERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    address public linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address public daiToken = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;

    address ethUsd = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address diaUsd = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;
    address linkUsd = 0xc59E3633BAAC79493d908e63626716e204A45EdF;

    event Swap(
        address indexed fromToken,
        address indexed toToken,
        address indexed trader,
        uint256 fromAmount,
        uint256 toAmount
    );

    constructor() {
        ETHpriceFeed = AggregatorV3Interface(ethUsd);
        DAIpriceFeed = AggregatorV3Interface(diaUsd);
        LinkpriceFeed = AggregatorV3Interface(linkUsd);
    }

    /**
     * Returns the latest prices
     */

    function LatestETHprice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = ETHpriceFeed.latestRoundData();
        return (answer);
    }

    function LatestDAIprice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/

        ) = DAIpriceFeed.latestRoundData();
        return (answer);
    }

    function LatestLinkprice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/

        ) = LinkpriceFeed.latestRoundData();
        return (answer);
    }

    /**
     * @dev To change DAI interface
     * @param _address Address of the DAI interface
     */
    function changeDAI(address _address) external onlyOwner {
        daiToken = _address;
    }

    /**
     * @dev To change LINK interface
     * @param _address Address of the LINK interface
     */
    function changeLink(address _address) external onlyOwner {
        linkToken = _address;
    }

    modifier onlyOwner() {
        require(msg.sender == Owner);
        _;
    }

    function getDerivedPrice(
        address _base,
        address _quote,
        uint8 _decimals
    ) public view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 basePrice, , , ) = AggregatorV3Interface(_base)
            .latestRoundData();
        uint8 baseDecimals = AggregatorV3Interface(_base).decimals();
        basePrice = scalePrice(basePrice, baseDecimals, _decimals);

        (, int256 quotePrice, , , ) = AggregatorV3Interface(_quote)
            .latestRoundData();
        uint8 quoteDecimals = AggregatorV3Interface(_quote).decimals();
        quotePrice = scalePrice(quotePrice, quoteDecimals, _decimals);

        return (basePrice * decimals) / quotePrice;
    }

    function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }

    function swapTokens(
        address _fromToken,
        address _toToken,
        uint256 _amount
    ) external payable {
        require(_fromToken != _toToken, "Cannot swap to the same token");

        if (_fromToken == address(0)) {
            require(
                msg.value == _amount,
                "Sent ETH amount must match specified amount"
            );
        } else {
            IERC20 fromToken = IERC20(_fromToken);
            uint256 allowance = fromToken.allowance(msg.sender, address(this));
            require(allowance >= _amount, "Token allowance too low");
            require(
                fromToken.transferFrom(msg.sender, address(this), _amount),
                "Transfer from failed"
            );
        }

        uint256 receivedAmount = _swap(_fromToken, _toToken, _amount);

        emit Swap(_fromToken, _toToken, msg.sender, _amount, receivedAmount);
    }

    function _swap(
        address _fromToken,
        address _toToken,
        uint256 _amount
    ) internal returns (uint256) {
        uint256 amountOut;
        if (_fromToken == address(0) && _toToken == linkToken) {
            // ETH to LINK swap
            amountOut = getAmountOut(ethUsd, linkUsd, 8, _amount);
            require(
                IERC20(_toToken).balanceOf(address(this)) >= amountOut,
                "Insufficient liquidity"
            );
            require(
                IERC20(_toToken).transfer(msg.sender, amountOut),
                "Transfer failed"
            );
        } else if (_fromToken == address(0) && _toToken == daiToken) {
            // ETH to DAI swap
            amountOut = getAmountOut(ethUsd, diaUsd, 8, _amount);
            require(
                IERC20(_toToken).balanceOf(address(this)) >= amountOut,
                "Insufficient liquidity"
            );
            require(
                IERC20(_toToken).transfer(msg.sender, amountOut),
                "Transfer failed"
            );
        } else if (_fromToken == linkToken && _toToken == address(0)) {
            // LINK to ETH swap
            amountOut = getAmountOut(linkUsd, ethUsd, 8, _amount);
            require(
                address(this).balance >= amountOut,
                "Insufficient Ether in Contract"
            );
            payable(msg.sender).transfer(amountOut);
        } else if (_fromToken == linkToken && _toToken == daiToken) {
            // LINK to DAI swap
            amountOut = getAmountOut(linkUsd, diaUsd, 8, _amount);
            require(
                IERC20(_toToken).balanceOf(address(this)) >= amountOut,
                "Insufficient liquidity"
            );
            require(
                IERC20(_toToken).transfer(msg.sender, amountOut),
                "Transfer failed"
            );
        } else if (_fromToken == daiToken && _toToken == address(0)) {
            // DAI to ETH swap
            amountOut = getAmountOut(diaUsd, ethUsd, 8, _amount);
            console.log("amountOut====>", amountOut);
            require(
                address(this).balance >= amountOut,
                "Insufficient Ether in Contract"
            );
            payable(msg.sender).transfer(amountOut);
        } else if (_fromToken == daiToken && _toToken == linkToken) {
            // DAI to LINK swap
            amountOut = getAmountOut(diaUsd, linkUsd, 8, _amount);
            require(
                IERC20(_toToken).balanceOf(address(this)) >= amountOut,
                "Insufficient liquidity"
            );
            require(
                IERC20(_toToken).transfer(msg.sender, amountOut),
                "Transfer failed"
            );
        } else {
            revert("Invalid swap pair");
        }

        return amountOut;
    }

    function getAmountOut(
        address _base,
        address _quote,
        uint8 _decimals,
        uint256 _amount
    ) public view returns (uint256) {
        int256 result = getDerivedPrice(_base, _quote, _decimals);
        uint256 amountOut = (_amount * uint256(result)) / 10e7;
        return amountOut;
    }

    function withdrawERC20(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(0), "Cannot withdraw ETH with this function");
        IERC20 token = IERC20(_token);
        require(
            token.balanceOf(address(this)) >= _amount,
            "Insufficient balance"
        );
        require(token.transfer(Owner, _amount), "Transfer failed");
    }

    function withdrawETH(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        (bool success, ) = Owner.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}

    fallback() external payable {}
}
