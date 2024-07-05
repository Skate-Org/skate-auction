# Skate Auction App

Skate auction app is used to demonstrate how Stateless Apps tap into Skate to enable intent powered, crosschain compatible apps with a single application state.

Refer to [https://docs.skatechain.org/developers/stateless-app-cookbook] for more information on how to build your own Stateless App!

## Stateless App Overview

<img width="671" alt="Screenshot 2024-07-05 at 12 38 35 PM" src="https://github.com/Skate-Org/skate-auction/assets/131840631/0762da9d-fb8c-4840-a2f9-d50e7a1eb4bc">

Stateless Applications are split into two components: **Kernel and Periphery.**

The kernel stores the core application logic and state variables for your app. It also taps into the set of standard libraries provided by Skate to enable intent powered, crosschain compatible apps with a single application state.

Conversely, the periphery serves as the user facing component to facilitate user actions on other periphery chains. This component resides on the external chains and retrieves its state from the kernel

## Directory Structure
```bash
src
├── app
│   ├── kernel
│   └── periphery
└── skate
    ├── common
    ├── kernel
    └── periphery
```

**src/app** <br>
kernel: Contains core contract implementations related to the main functionality of the application.   <br>
periphery: Contains contracts that provide auxiliary functionalities to the core contracts.   <br>

**src/skate**  <br>
common: Contains shared utilities and helper contracts that are used across different modules. <br>
kernel: Additional kernel-related contracts specific to the Skate project.
periphery: Additional peripheral-related contracts specific to the Skate project. <br>


## Auction Contracts

![Screenshot 2024-07-05 at 2 30 23 PM](https://github.com/Skate-Org/skate-auction/assets/131840631/5171fd5f-c077-425e-b4f0-d38e79c2331e)

Here's a brief overview for the contracts used for the auction. 

### For kernel
  1. SkateAuction.sol: contains the main functionalities required for auction
  2. SkateNFT.sol: contains the main functionalities required for NFT
  3. SkateApp.sol: contains the main functionalities required for intent processing, task creation that's used to interact with Skate

### For Periphery:
  1. SkateAuctionPeriphery.sol: contains the main functionalities required for auction
  2. SkateNFTPeriphery.sol: contains the main functionalities required for NFT
  3. SkateApp.sol: contains the main functionalities required for intent processing, task creation that's used to interact with Skate

## Foundry commands
### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/CONTRACT.s.sol:CONTRACT_NAME --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
