# BitCharity - Transparent Donation Management Protocol

[![Stacks](https://img.shields.io/badge/Stacks-Layer%202-purple)](https://stacks.co)
[![Bitcoin](https://img.shields.io/badge/Secured%20by-Bitcoin-orange)](https://bitcoin.org)
[![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)](package.json)

## Overview

BitCharity is a revolutionary decentralized charity platform built on Stacks Layer 2, leveraging Bitcoin's security to provide unprecedented transparency in charitable giving. The platform enables donors to track fund utilization in real-time while ensuring accountability through immutable blockchain records.

## Key Features

- **Transparent Donations**: All donations recorded immutably on Bitcoin-secured blockchain
- **Role-Based Access Control**: Multi-tier permission system for admins, moderators, and beneficiaries
- **Milestone Tracking**: Fund utilization tracked through approved milestones
- **Real-Time Monitoring**: Live tracking of donation goals and fund usage
- **Bitcoin Security**: Leverages Bitcoin's proven security model through Stacks Layer 2

## System Overview

BitCharity operates as a multi-stakeholder ecosystem where transparency and accountability are enforced through smart contract logic and blockchain immutability.

### Core Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Donors      │    │   Moderators    │    │     Admins      │
│   (STX Users)   │    │ (NGO Partners)  │    │ (Fund Managers) │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │ Donate STX           │ Register             │ Approve
          │                      │ Beneficiaries        │ Utilization
          ▼                      ▼                      ▼
    ┌─────────────────────────────────────────────────────────────┐
    │                BitCharity Smart Contract                    │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐   │
    │  │ Beneficiary │ │  Donation   │ │    Utilization      │   │
    │  │  Registry   │ │   Tracker   │ │     Manager         │   │
    │  └─────────────┘ └─────────────┘ └─────────────────────┘   │
    └─────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────────┐
                    │      Stacks Blockchain      │
                    │    (Bitcoin Layer 2)        │
                    └─────────────────────────────┘
```

## Contract Architecture

### Data Models

#### Beneficiaries

```clarity
{
  id: uint,
  name: string-utf8,
  description: string-utf8,
  target-amount: uint,
  received-amount: uint,
  status: string-ascii
}
```

#### Donations

```clarity
{
  id: uint,
  donor: principal,
  beneficiary-id: uint,
  amount: uint,
  timestamp: uint
}
```

#### Utilization Records

```clarity
{
  id: uint,
  beneficiary-id: uint,
  milestone: uint,
  description: string-utf8,
  amount: uint,
  status: string-ascii
}
```

### Role Hierarchy

1. **Contract Owner**: Ultimate authority, can assign/remove all roles
2. **Admin (Level 1)**: Can approve fund utilization and manage milestones
3. **Moderator (Level 2)**: Can register new beneficiaries
4. **Beneficiary (Level 3)**: Basic role for fund recipients

## Data Flow

### Donation Process

```
Donor → Validate Amount → Transfer STX → Update Beneficiary Balance → Record Transaction
  ↓
Log Donation with Timestamp → Increment Counters → Return Success
```

### Fund Utilization Process

```
Admin → Create Utilization Request → Validate Funds Available → Set Pending Status
  ↓
Admin Approval → Check Balance Sufficiency → Mark as Approved → Update Records
```

### Beneficiary Registration

```
Moderator → Submit Registration → Validate Input → Create Beneficiary Record
  ↓
Assign Unique ID → Set Active Status → Update Counter → Return ID
```

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) for local development
- [Stacks Wallet](https://wallet.hiro.so/) for mainnet interactions
- Node.js 16+ for frontend integration

### Installation

```bash
# Clone the repository
git clone https://github.com/jeatune/bitcharity.git
cd bitcharity

# Install Clarinet
npm install -g @hirosystems/clarinet-cli

# Initialize project
clarinet new bitcharity-project
```

### Deployment

```bash
# Test locally
clarinet test

# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

## Usage Examples

### Register a Beneficiary

```clarity
(contract-call? .bitcharity register-beneficiary 
  u"Local Food Bank" 
  u"Providing meals to families in need during economic hardship" 
  u1000000) ;; 1,000 STX target
```

### Make a Donation

```clarity
(contract-call? .bitcharity donate u1 u50000) ;; Donate 50 STX to beneficiary #1
```

### Track Fund Utilization

```clarity
(contract-call? .bitcharity add-utilization 
  u1 
  u"Purchased 500 meals for distribution" 
  u25000) ;; 25 STX utilized
```

## API Reference

### Public Functions

| Function | Parameters | Access Level | Description |
|----------|------------|--------------|-------------|
| `donate` | beneficiary-id, amount | Public | Make donation to beneficiary |
| `register-beneficiary` | name, description, target | Moderator+ | Register new beneficiary |
| `add-utilization` | beneficiary-id, description, amount | Admin | Add fund utilization record |
| `approve-utilization` | beneficiary-id, milestone | Admin | Approve fund usage |
| `set-role` | user, role | Owner | Assign user roles |

### Read-Only Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `get-beneficiary` | Beneficiary data | Retrieve beneficiary information |
| `get-donation-by-id` | Donation record | Get specific donation details |
| `get-utilization-by-id` | Utilization record | Get fund usage details |
| `get-donation-count` | Total donations | Get donation counter |

## Security Features

- **Role-based access control** prevents unauthorized actions
- **Input validation** ensures data integrity
- **Fund sufficiency checks** prevent over-utilization
- **Immutable audit trail** provides complete transparency
- **Bitcoin-level security** through Stacks Layer 2

## Contributing

We welcome contributions to BitCharity! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Roadmap

- [ ] **Q2 2025**: Multi-signature fund release
- [ ] **Q3 2025**: Mobile app integration
- [ ] **Q4 2025**: Cross-chain bridge support
- [ ] **Q1 2026**: AI-powered impact analytics
