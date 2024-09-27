// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title StableCoin
/// @author AGK
/// @dev ERC20 implementation of stablecoin system, meant to be governed by main contract.
contract StableCoin is ERC20Burnable, Ownable {
    error StableCoin_NotZeroAddress();
    error StableCoin_MustBeMoreThanZero();
    error StableCoin_BurnAmountExceedsBalance();

    constructor() ERC20("StableCoin", "SC") Ownable(msg.sender) {}

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert StableCoin_NotZeroAddress();
        }
        if (_amount <= 0) {
            revert StableCoin_MustBeMoreThanZero();
        }

        _mint(_to, _amount);
        return true;
    }

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);

        if (_amount <= 0) {
            revert StableCoin_MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert StableCoin_BurnAmountExceedsBalance();
        }

        super.burn(_amount);
    }
}
