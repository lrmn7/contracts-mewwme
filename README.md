# Mewwme Smart Contracts

A collection of smart contracts powering the Mewwme platform — a decentralized ecosystem enabling token creation, liquidity management, and gamified burn challenges.

Built with Solidity and Hardhat.

---

## Features

- ERC20 Token Factory
- Liquidity Pool Management
- Burn Challenge Mechanism
- Modular & Upgradeable Design (via OpenZeppelin)

---

## Project Structure

```
contracts/
├── BurnChallenge.sol     # Token burn challenge mechanism
├── CustomToken.sol       # Base ERC20 token implementation
├── LiquidityPool.sol     # Liquidity pool management logic
└── TokenFactory.sol      # ERC20 token factory contract
```

---

## Prerequisites

- Node.js v16 or later
- npm or yarn
- Hardhat v2.x

---

## Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/your-org/mewwme-contracts.git
cd mewwme-contracts
npm install
```

---

## Usage

### Compile Smart Contracts

```bash
npx hardhat compile
```

### Run Unit Tests

```bash
npx hardhat test
```

### Run Tests with Gas Report

```bash
REPORT_GAS=true npx hardhat test
```

### Start Local Hardhat Network

```bash
npx hardhat node
```

---

Run deployment:

```bash
npx hardhat run scripts/deploy.ts --network localhost
```

---

## Dependencies

- [Hardhat v2.22.19](https://hardhat.org/)
- [OpenZeppelin Contracts v5.2.0](https://docs.openzeppelin.com/contracts/)
- [Ethers.js v6.13.5](https://docs.ethers.org/)

---

