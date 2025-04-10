// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LiquidityPool.sol";
import "./CustomToken.sol";

contract TokenFactory is Ownable(msg.sender) {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;
    uint256 public tokenIdCounter;
    uint256 public CREATION_FEE = 0.005 ether;
    uint256 public FEE_RATE = 1; // 1%
    address public FEE_RECEIVER = 0x0000000000000000000000000000000000000000;

    struct TokenInfo {
        address tokenAddress;
        address liquidityPool;
        uint256 id;
    }

    mapping(uint256 => TokenInfo) public tokens;
    mapping(address => address) public tokenLiquidityPools;

    event TokenCreated(
        address tokenAddress,
        address liquidityPool,
        uint256 tokenId,
        uint256 bonusTokens
    );

    event Swap(
        address indexed liquidityPool,
        address indexed sender,
        uint256 ethAmountIn,
        uint256 tokenAmountIn,
        uint256 ethAmountOut,
        uint256 tokenAmountOut,
        address indexed to
    );

    event Sync(
        address indexed liquidityPool,
        uint256 ethReserve,
        uint256 tokenReserve
    );

    function setFeeRate(uint256 _feeRate) external onlyOwner {
        FEE_RATE = _feeRate;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        FEE_RECEIVER = _feeReceiver;
    }

    function setCreationFee(uint256 _creationFee) external onlyOwner {
        CREATION_FEE = _creationFee;
    }

    function createToken(
        string memory name,
        string memory symbol
    ) external payable {
        require(bytes(name).length > 0, "Token name is required");
        require(bytes(symbol).length > 0, "Token symbol is required");
        require(msg.value >= CREATION_FEE, "Insufficient creation fee");

        CustomToken createdToken;
        try new CustomToken(name, symbol, INITIAL_SUPPLY) returns (
            CustomToken tokenInstance
        ) {
            createdToken = tokenInstance;
        } catch {
            revert("Token creation failed");
        }

        LiquidityPool pool = new LiquidityPool(
            address(createdToken),
            FEE_RATE,
            FEE_RECEIVER
        );

        (bool success, ) = address(pool).call{value: CREATION_FEE}("");
        require(success, "ETH transfer failed");

        IERC20 tokenInterface = IERC20(address(createdToken));
        tokenInterface.transfer(address(pool), INITIAL_SUPPLY);

        tokenIdCounter++;
        tokens[tokenIdCounter] = TokenInfo({
            tokenAddress: address(createdToken),
            liquidityPool: address(pool),
            id: tokenIdCounter
        });

        tokenLiquidityPools[address(createdToken)] = address(pool);

        uint256 bonusTokens = 0;

        if (msg.value > CREATION_FEE) {
            uint256 netEth = msg.value - CREATION_FEE;
            pool.buyTokens{value: netEth}();

            uint256 balance = tokenInterface.balanceOf(address(this));
            tokenInterface.transfer(msg.sender, balance);
            bonusTokens = balance;
        }

        emit TokenCreated(
            address(createdToken),
            address(pool),
            tokenIdCounter,
            bonusTokens
        );
    }

    function getTokenInfo(
        uint256 tokenId
    ) external view returns (TokenInfo memory) {
        return tokens[tokenId];
    }

    function getLiquidityPool(
        address tokenAddress
    ) external view returns (address) {
        return tokenLiquidityPools[tokenAddress];
    }

    modifier onlyLiquidityPool(address liquidityPool) {
        require(
            LiquidityPool(payable(liquidityPool)).factoryAddress() ==
                address(this),
            "Only liquidity pool can call this function"
        );
        _;
    }

    function swapEvent(
        address sender,
        uint256 ethAmountIn,
        uint256 tokenAmountIn,
        uint256 ethAmountOut,
        uint256 tokenAmountOut,
        address to
    ) public onlyLiquidityPool(msg.sender) {
        emit Swap(
            msg.sender,
            sender,
            ethAmountIn,
            tokenAmountIn,
            ethAmountOut,
            tokenAmountOut,
            to
        );
    }

    function syncEvent(
        uint256 ethReserve,
        uint256 tokenReserve
    ) public onlyLiquidityPool(msg.sender) {
        emit Sync(msg.sender, ethReserve, tokenReserve);
    }
}
