;; Title: BitcraftMarket - Decentralized Gaming Asset Management Protocol
;; 
;; Summary: A comprehensive smart contract for minting, trading, and tracking
;; ownership of gaming assets on the Stacks blockchain with Bitcoin-backed security.
;;
;; Description: BitcraftMarket enables game developers and players to create,
;; trade, and manage in-game assets as Bitcoin-secured NFTs on Stacks Layer 2.
;; The contract provides robust marketplace functionality with batch operations,
;; player statistics tracking, and transparent ownership verification while
;; maintaining compatibility with Bitcoin settlement guarantees.

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-not-authorized (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-invalid-price (err u104))
(define-constant max-level u100)
(define-constant max-experience u10000)
(define-constant max-metadata-length u256)
(define-constant max-batch-size u10)  ;; Limit batch operations to prevent potential gas issues

;; Data Maps
(define-map assets 
    { asset-id: uint }
    { owner: principal, metadata-uri: (string-utf8 256), transferable: bool }
)

(define-map asset-prices
    { asset-id: uint }
    { price: uint }
)

(define-map player-stats
    { player: principal }
    { experience: uint, level: uint }
)

(define-map marketplace-listings
    { asset-id: uint }
    { seller: principal, price: uint, listed-at: uint }
)

;; Data Variables
(define-data-var asset-counter uint u0)

;; Helper Functions

;; Validate asset exists and return asset data
(define-private (get-asset-checked (asset-id uint))
    (let ((asset (map-get? assets { asset-id: asset-id })))
        (asserts! (and 
                (is-some asset)
                (<= asset-id (var-get asset-counter)))
            err-not-found)
        (ok (unwrap-panic asset))
	)
)

;; Validate metadata URI length
(define-private (validate-metadata-uri (uri (string-utf8 256)))
    (let ((uri-length (len uri)))
        (and 
            (> uri-length u0)
            (<= uri-length max-metadata-length))
	)
)