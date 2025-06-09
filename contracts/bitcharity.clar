;; Title: BitCharity - Transparent Donation Management Protocol
;;
;; Summary: A decentralized charity platform enabling transparent donations
;;          and fund utilization tracking on Bitcoin's Stacks Layer 2
;;
;; Description: BitCharity revolutionizes charitable giving by leveraging 
;;              Bitcoin's security and Stacks' smart contract capabilities.
;;              Features include role-based access control, transparent fund
;;              tracking, milestone-based fund utilization, and immutable
;;              donation records. Perfect for NGOs, relief organizations,
;;              and community-driven charitable initiatives seeking full
;;              transparency and donor confidence.

;; CONTRACT OWNERSHIP & GOVERNANCE

(define-data-var contract-owner principal tx-sender)

;; ERROR CONSTANTS

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u104))
(define-constant ERR-UTILIZATION-NOT-FOUND (err u105))
(define-constant ERR-INVALID-INPUT (err u106))

;; ROLE DEFINITIONS

(define-constant ROLE-ADMIN u1)
(define-constant ROLE-MODERATOR u2)
(define-constant ROLE-BENEFICIARY u3)

;; DATA STRUCTURES

;; User role management
(define-map roles
  { user: principal }
  { role: uint }
)

;; Beneficiary registry with funding goals and status
(define-map beneficiaries
  { id: uint }
  {
    name: (string-utf8 50),
    description: (string-utf8 255),
    target-amount: uint,
    received-amount: uint,
    status: (string-ascii 20),
  }
)

;; Donation transaction records
(define-map donations
  { id: uint }
  {
    donor: principal,
    beneficiary-id: uint,
    amount: uint,
    timestamp: uint,
  }
)

;; Fund utilization tracking with milestone system
(define-map utilization
  { id: uint }
  {
    beneficiary-id: uint,
    milestone: uint,
    description: (string-utf8 255),
    amount: uint,
    status: (string-ascii 20),
  }
)

;; COUNTERS FOR UNIQUE IDS

(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; HELPER FUNCTIONS

;; Check if user has required authorization level
(define-private (is-authorized
    (user principal)
    (required-role uint)
  )
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)
  )
)

;; Get the last milestone for a beneficiary
(define-private (get-last-milestone (beneficiary-id uint))
  (var-get utilization-count)
)

;; ROLE MANAGEMENT FUNCTIONS

;; Assign roles to users (admin, moderator, beneficiary)
(define-public (set-role
    (user principal)
    (new-role uint)
  )
  (let ((existing-role (default-to u0 (get role (map-get? roles { user: user })))))
    (if (and
        (is-eq tx-sender (var-get contract-owner))
        (<= new-role ROLE-BENEFICIARY)
        (not (is-eq user tx-sender)) ;; Prevent self-role assignment
        (or
          (is-eq new-role ROLE-ADMIN)
          (is-eq new-role ROLE-MODERATOR)
          (is-eq new-role ROLE-BENEFICIARY)
        )
      )
      (ok (map-set roles { user: user } { role: new-role }))
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Remove user roles
(define-public (remove-role (user principal))
  (if (and
      (is-eq tx-sender (var-get contract-owner))
      (is-some (map-get? roles { user: user }))
      (not (is-eq user tx-sender))
    )
    ;; Prevent self-role removal
    (ok (map-delete roles { user: user }))
    ERR-NOT-AUTHORIZED
  )
)

;; BENEFICIARY MANAGEMENT

;; Register new beneficiary with funding goal
(define-public (register-beneficiary
    (name (string-utf8 50))
    (description (string-utf8 255))
    (target-amount uint)
  )
  (let ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (if (and
        (is-authorized tx-sender ROLE-MODERATOR)
        (> (len name) u0)
        (> (len description) u0)
        (> target-amount u0)
      )
      (begin
        (map-set beneficiaries { id: beneficiary-id } {
          name: name,
          description: description,
          target-amount: target-amount,
          received-amount: u0,
          status: "active",
        })
        (var-set beneficiary-count beneficiary-id)
        (ok beneficiary-id)
      )
      ERR-INVALID-INPUT
    )
  )
)

;; Retrieve beneficiary information
(define-read-only (get-beneficiary (id uint))
  (match (map-get? beneficiaries { id: id })
    beneficiary (ok beneficiary)
    ERR-BENEFICIARY-NOT-FOUND
  )
)

;; DONATION FUNCTIONS

;; Make donation to a specific beneficiary
(define-public (donate
    (beneficiary-id uint)
    (amount uint)
  )
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
    (if (and
        (> amount u0)
        (< beneficiary-id (var-get beneficiary-count)) ;; Validate beneficiary ID
        (is-some (map-get? beneficiaries { id: beneficiary-id }))
      )
      (match (stx-transfer? amount tx-sender (as-contract tx-sender))
        success (begin
          ;; Update beneficiary received amount
          (map-set beneficiaries { id: beneficiary-id }
            (merge beneficiary { received-amount: (+ (get received-amount beneficiary) amount) })
          )
          ;; Record donation transaction
          (map-set donations { id: (+ (var-get donation-count) u1) } {
            donor: tx-sender,
            beneficiary-id: beneficiary-id,
            amount: amount,
            timestamp: stacks-block-height,
          })
          (var-set donation-count (+ (var-get donation-count) u1))
          (ok true)
        )
        error
        ERR-INSUFFICIENT-FUNDS
      )
      ERR-INVALID-INPUT
    )
  )
)