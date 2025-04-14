# BitcraftMarket - Decentralized Gaming Asset Management Protocol

A secure and efficient protocol for managing blockchain-based gaming assets on Stacks (Bitcoin L2). Facilitates NFT minting, P2P trading, and player progression tracking with enterprise-grade security.

## Table of Contents

- [BitcraftMarket - Decentralized Gaming Asset Management Protocol](#bitcraftmarket---decentralized-gaming-asset-management-protocol)
	- [Table of Contents](#table-of-contents)
	- [Overview](#overview)
	- [Key Features](#key-features)
	- [Smart Contract Functions](#smart-contract-functions)
		- [Asset Management](#asset-management)
			- [`mint-asset`](#mint-asset)
			- [`batch-mint-assets`](#batch-mint-assets)
		- [Marketplace Operations](#marketplace-operations)
			- [`list-asset-for-sale`](#list-asset-for-sale)
			- [`purchase-asset`](#purchase-asset)
		- [Player Statistics](#player-statistics)
			- [`update-player-stats`](#update-player-stats)
		- [Utility Functions](#utility-functions)
			- [Read Operations](#read-operations)
	- [Error Codes](#error-codes)
	- [Security Model](#security-model)

## Overview

BitcraftMarket revolutionizes gaming economies by enabling:

- Bitcoin-secured NFT assets via Stacks L2
- Developer-friendly asset lifecycle management
- Player-owned digital economies
- Real-time market dynamics with on-chain settlement
- Cross-game compatibility framework

## Key Features

**Enterprise-Grade Infrastructure**

- Bitcoin finality through Stacks blockchain
- Batch operations with gas optimization
- Immutable ownership records
- Compliance-ready architecture

**Core Components**

1. **Asset Factory System**

   - Configurable NFT minting (transferable/non-transferable)
   - Metadata standardization (IPFS/Arweave compatible)
   - Bulk creation capabilities

2. **Decentralized Exchange Engine**

   - Trustless STX-based marketplace
   - Time-stamped order book
   - Atomic swap functionality

3. **Player Profile System**

   - On-chain progression tracking
   - Cross-game reputation system
   - Achievement verification framework

4. **Governance Framework**
   - Multi-sig compatible ownership
   - Upgradeable contract modules
   - Fee structure hooks

## Smart Contract Functions

### Asset Management

#### `mint-asset`

```clarity
(define-public (mint-asset (metadata-uri (string-utf8 256)) (transferable bool))
```

- **Permission**: Contract Owner
- **Parameters**:
  - `metadata-uri`: UTF-8 string (max 256 chars)
  - `transferable`: Boolean flag
- **Flow**:
  1. Validate caller authorization
  2. Check URI format compliance
  3. Increment global asset counter
  4. Create new NFT record

#### `batch-mint-assets`

```clarity
(define-public (batch-mint-assets (metadata-uris (list 10...)) (transferable-list...))
```

- **Batch Limit**: 10 assets per operation
- **Requirements**:
  - Equal length for URIs and transferable flags
  - Total assets ≤ 10,000 (via counter)

### Marketplace Operations

#### `list-asset-for-sale`

```clarity
(define-public (list-asset-for-sale (asset-id uint) (price uint))
```

- **Prerequisites**:
  - Asset exists and is transferable
  - Caller = current owner
  - Price > 0 STX
- **Effects**:
  - Creates time-stamped market entry
  - Locks asset transfers while listed

#### `purchase-asset`

```clarity
(define-public (purchase-asset (asset-id uint))
```

- **Execution Flow**:
  1. Verify listing existence
  2. Validate STX balance ≥ price
  3. Execute STX transfer (buyer → seller)
  4. Update ownership records
  5. Remove market listing

### Player Statistics

#### `update-player-stats`

```clarity
(define-public (update-player-stats (experience uint) (level uint))
```

- **Validation Rules**:
  - Experience ≤ 10,000
  - Level ≤ 100
  - Self-authenticated updates
- **Use Cases**:
  - Cross-game achievement tracking
  - Skill-based matchmaking
  - Progressive asset unlocking

### Utility Functions

#### Read Operations

| Function                  | Description        | Output Format                |
| ------------------------- | ------------------ | ---------------------------- |
| `get-asset-details`       | Full NFT metadata  | `{owner, uri, transferable}` |
| `get-marketplace-listing` | Current sale info  | `{seller, price, timestamp}` |
| `get-player-stats`        | Player progression | `{experience, level}`        |
| `get-total-assets`        | Supply metrics     | `uint`                       |

## Error Codes

| Code | Description               | Resolution                |
| ---- | ------------------------- | ------------------------- |
| u100 | Owner-restricted function | Verify contract ownership |
| u101 | Asset not found           | Check asset ID validity   |
| u102 | Unauthorized operation    | Validate permissions      |
| u103 | Invalid parameters        | Review input format       |
| u104 | Invalid pricing           | Ensure price > 0 STX      |

## Security Model

**Core Protections**

1. **Ownership Controls**

   - Critical functions restricted to `contract-owner`
   - Multi-sig compatible authorization

2. **Asset Safeguards**

   - Immutable transfer flags
   - Marketplace listing locks
   - Batch operation limits

3. **Financial Security**

   - STX-native escrow system
   - Atomic swap guarantees
   - Front-running protection

4. **Data Integrity**
   - Metadata length validation
   - Statistic boundary checks
   - Blockchain-anchored records
