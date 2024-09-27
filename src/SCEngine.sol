// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {StableCoin} from "./StableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title SCEngine
/// @author AGK
/// @notice This contract is the core of SC system. It handles all the logic for minting and burning SC, as well as depositing and withdrawing collateral.
contract SCEngine is ReentrancyGuard {
    // Error
    error SCEngine_NeedMoreThanZero();
    error SCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error SCEngine_TokenNotSupportedAsCollateral();
    error SCEngine_TransferFailed();

    // State Variables
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    // token => priceFeed
    mapping(address => address) private _priceFeeds;

    StableCoin private stable_coin;

    // user => token => amount
    mapping(address => mapping(address => uint256)) private collateralDeposited;
    mapping(address => uint256) private scMinted;

    address[] private collateralTokens;

    // Events
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    // modifiers
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert SCEngine_NeedMoreThanZero();
        }
        _;
    }

    modifier isTokenAllowed(address token) {
        if (_priceFeeds[token] == address(0)) {
            revert SCEngine_TokenNotSupportedAsCollateral();
        }
        _;
    }

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address stableCoin) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert SCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            _priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            collateralTokens.push(tokenAddresses[i]);
        }

        stable_coin = StableCoin(stableCoin);
    }

    function depositCollateralAndMintSC() external {}

    /// @dev function to deposit collateral token
    /// @param _collateralToken address of token to be collateralized
    /// @param _amountCollateral total Token amount
    function depositCollateral(address _collateralToken, uint256 _amountCollateral)
        external
        moreThanZero(_amountCollateral)
        isTokenAllowed(_collateralToken)
        nonReentrant
    {
        collateralDeposited[msg.sender][_collateralToken] += _amountCollateral;
        emit CollateralDeposited(msg.sender, _collateralToken, _amountCollateral);

        bool success = IERC20(_collateralToken).transferFrom(msg.sender, address(this), _amountCollateral);

        if (!success) {
            revert SCEngine_TransferFailed();
        }
    }

    function redeemCollateralforSC() external {}

    function redeemCollateral() external {}

    /// @dev To mint StableCoin, must check whether enough amount is collateralized
    /// @param amountToMint total token amount to be minted
    /// @notice To mint they must have more collateral than mint Amount
    function mintCollateral(uint256 amountToMint) external moreThanZero(amountToMint) nonReentrant {
        scMinted[msg.sender] += amountToMint;
    }

    function burnSC() external {}

    function liquidate() external {}

    function healthFactor() external view {}

    // private & internal Functions
    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalSCMinted, uint256 totalCollateralValueUsd)
    {
        totalSCMinted = scMinted[user];
        totalCollateralValueUsd = getUserCollateralValueUsd(user);
    }

    function _healthFactor(address user) private view returns (uint256) {
        uint256(totalSCMinted, collateralValueInUsd) = _getAccountInformation(user);
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {}

    // View function
    function getUserCollateralValueUsd(address user) public view returns (uint256) {
        for (uint256 i = 0; i < collateralTokens.length; i++) {
            address token = collateralTokens[i];
            uint256 amount = collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_priceFeeds[token]);

        (, int256 price,,,) = priceFeed.latestRoundData();

        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}
