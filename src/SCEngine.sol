// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {StableCoin} from "./StableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
    // token => priceFeed
    mapping(address => address) private _priceFeeds;

    StableCoin private stable_coin;

    // user => token => amount
    mapping(address => mapping(address => uint256)) private collateralDeposited;

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

    function mintCollateral() external {}

    function burnSC() external {}

    function liquidate() external {}

    function healthFactor() external view {}
}
