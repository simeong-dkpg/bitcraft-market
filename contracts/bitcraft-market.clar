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

;; Helper function for batch minting
(define-private (mint-single-asset 
    (uri (string-utf8 256))
    (transferable bool))
    (let 
        ((asset-id (+ (var-get asset-counter) u1)))
        (asserts! (validate-metadata-uri uri) err-invalid-input)
        (map-set assets
            { asset-id: asset-id }
            { owner: contract-owner,
              metadata-uri: uri,
              transferable: transferable })
        (var-set asset-counter asset-id)
        (ok asset-id)
	)
)

;; Helper function for batch transfer
(define-private (transfer-single-asset
    (asset-id uint)
    (recipient principal))
    (let 
        ((asset (unwrap-panic (get-asset-checked asset-id))))
        (asserts! (and
                (is-eq (get owner asset) tx-sender)
                (get transferable asset)
                (not (is-eq recipient tx-sender)))
            err-not-authorized)
        (map-set assets
            { asset-id: asset-id }
            { owner: recipient,
              metadata-uri: (get metadata-uri asset),
              transferable: (get transferable asset) })
        (ok true)
	)
)

;; Minting Functions

;; Mint single asset
(define-public (mint-asset (metadata-uri (string-utf8 256)) (transferable bool))
    (let
        ((asset-id (+ (var-get asset-counter) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (validate-metadata-uri metadata-uri) err-invalid-input)
        (map-set assets
            { asset-id: asset-id }
            { owner: tx-sender,
              metadata-uri: metadata-uri,
              transferable: transferable })
        (var-set asset-counter asset-id)
        (ok asset-id)
	)
)

;; Batch Mint new gaming assets
(define-public (batch-mint-assets 
    (metadata-uris (list 10 (string-utf8 256))) 
    (transferable-list (list 10 bool)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (and 
            (> (len metadata-uris) u0)
            (<= (len metadata-uris) max-batch-size)
            (is-eq (len metadata-uris) (len transferable-list))) 
            err-invalid-input)
        (let ((minted-assets 
            (map mint-single-asset 
                metadata-uris 
                transferable-list)))
            (ok minted-assets))
	)
)

;; Transfer Functions

;; Transfer asset ownership
(define-public (transfer-asset (asset-id uint) (recipient principal))
    (begin
        (asserts! (<= asset-id (var-get asset-counter)) err-invalid-input)
        (let ((asset (try! (get-asset-checked asset-id))))
            (asserts! (and
                    (is-eq (get owner asset) tx-sender)
                    (get transferable asset)
                    (not (is-eq recipient tx-sender)))
                err-not-authorized)
            (map-set assets
                { asset-id: asset-id }
                { owner: recipient,
                  metadata-uri: (get metadata-uri asset),
                  transferable: (get transferable asset) })
            (ok true))
	)
)

;; Batch Transfer assets
(define-public (batch-transfer-assets 
    (asset-ids (list 10 uint)) 
    (recipients (list 10 principal)))
    (begin
        (asserts! (and 
            (> (len asset-ids) u0)
            (<= (len asset-ids) max-batch-size)
            (is-eq (len asset-ids) (len recipients))) 
            err-invalid-input)
        (let ((transfers 
            (map transfer-single-asset 
                asset-ids 
                recipients)))
            (ok transfers))
	)
)

;; Marketplace Functions

;; List asset for sale with enhanced marketplace listing
(define-public (list-asset-for-sale (asset-id uint) (price uint))
    (begin
        (asserts! (<= asset-id (var-get asset-counter)) err-invalid-input)
        (let ((asset (try! (get-asset-checked asset-id))))
            (asserts! (and 
                    (is-eq (get owner asset) tx-sender)
                    (> price u0)
                    (get transferable asset))
                err-invalid-price)
            (map-set marketplace-listings
                { asset-id: asset-id }
                { seller: tx-sender, 
                  price: price, 
                  listed-at: stacks-block-height })
            (ok true))
	)
)