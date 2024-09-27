# StableCoin

## Table of Contents

- [About](#about)

## About <a name = "about"></a>

The stable coin developed is anchored/pegged to USD, is exogenously collaterized, and has algorithmic stability mechanism.

### MakerDAO Liquidation

In Maker, the most important value for a CDP/Vault is the collateralization ratio, as this is what the system considers as the liquidation point and each collateral type has its own minimum collateralization ratio.

For ETH specifically that’s 150%. Allowing your position to fall below the minimum collateralization factor will result in your CDP being liquidated.

Once your collateralization ratio falls below 150% that allows anyone to call a “bite” on your position, effectively locking your collateral and starting the liquidation auction.
