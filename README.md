# Foundry Upgradeable Smart Contract

A [Foundry](https://book.getfoundry.sh/) project demonstrating **upgradeable smart contracts** on Ethereum — how to deploy logic behind a proxy so contract behavior can be changed after deployment without losing state or the contract's address.

## Why upgradeable contracts?

Normal smart contracts are immutable once deployed — any bug or missing feature is permanent. The proxy pattern solves this by splitting a contract in two:

- **Proxy contract** — holds the storage/state and the address users actually interact with. It never changes.
- **Implementation (logic) contract** — holds the executable code. The proxy `delegatecall`s into it, so the implementation's code runs in the proxy's storage context.

To "upgrade," you deploy a new implementation contract and point the proxy at it. Users keep the same address and state; only the logic behind it changes.

This repo works with that pattern (e.g. via OpenZeppelin's UUPS or Transparent proxy standards) — check `src/` for the exact implementation contracts and proxy setup used here.

> This README describes the general upgradeable-proxy pattern this project is built around. Contract names/details may vary — see `src/` and `script/` for specifics.

## Project structure

```
.
├── src/                 # Solidity contracts (implementation contract(s), proxy setup)
├── script/              # Foundry deployment / upgrade scripts
├── test/                # Foundry tests
├── lib/                 # Dependencies (installed via git submodules / forge install)
├── .github/workflows/   # CI configuration
├── foundry.toml         # Foundry project configuration
└── foundry.lock         # Locked dependency versions
```

## Requirements

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`, `cast`, `anvil`, `chisel`)
- [Git](https://git-scm.com/)

## Getting started

Clone the repo and install dependencies:

```bash
git clone https://github.com/sanjaysugunan/foundry-upgradable-smart-contract
cd foundry-upgradable-smart-contract
forge install
```

### Build

```bash
forge build
```

### Test

```bash
forge test
```

Run with higher verbosity for debugging:

```bash
forge test -vvvv
```

### Format

```bash
forge fmt
```

### Gas snapshots

```bash
forge snapshot
```

### Local node (Anvil)

```bash
anvil
```

### Deploy / upgrade

Deployment and upgrade logic live in `script/`. Run a script against a local or remote RPC:

```bash
forge script script/<YourScript>.s.sol:<YourScript> --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

Replace `<YourScript>` with the actual script contract name in `script/` (e.g. a deploy script and a separate upgrade script are common in this pattern).

### Cast

```bash
cast <subcommand>
```

### Help

```bash
forge --help
anvil --help
cast --help
```

## Typical upgrade flow

1. Deploy the initial implementation contract and a proxy pointing at it.
2. Interact with the contract through the **proxy address** only — never the implementation address directly.
3. When logic needs to change, write and deploy a new implementation contract (keeping storage layout compatible with the previous version).
4. Call the proxy's upgrade function (as the authorized owner/admin) to point it at the new implementation.
5. Verify existing state is preserved and new logic is now active — all through the same proxy address.

## Important gotchas with upgradeable contracts

- **Storage layout**: new implementation versions must preserve the existing storage slot order — don't reorder, remove, or change the type of existing state variables. Only append new variables at the end.
- **Constructors are not used for initialization**: implementation contracts typically use an `initialize()` function (with an initializer guard) instead of a constructor, since constructors don't run in the proxy's storage context.
- **Access control on upgrades**: only an authorized address should be able to trigger an upgrade — check the tests in `test/` for how this is enforced here.

## License

MIT