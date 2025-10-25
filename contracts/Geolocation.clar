;; title: Geolocation
;; version: 1.0.0
;; summary: A contract for geolocation data
;; description: This contract allows users to store and retrieve geolocation data

;; geo-app

(define-data-var checkin-counter uint u0)

(define-map checkins {id: uint}
  {user: principal,
   location: (string-ascii 50),
   timestamp: uint,
   status: (string-ascii 10)})

;; Check in at a location
(define-public (check-in (location (string-ascii 50)) (timestamp uint))
  (begin
    (asserts! (> (len location) u0) (err u1))
    (let
      (
        (id (var-get checkin-counter))
      )
      (map-set checkins {id: id}
        {user: tx-sender,
         location: location,
         timestamp: timestamp,
         status: "active"})
      (var-set checkin-counter (+ id u1))
      (ok id)
    )
  )
)

;; Verify a check-in
(define-public (verify-checkin (id uint))
  (match (map-get? checkins {id: id})
    checkin
    (if (is-eq (get status checkin) "active")
      (begin
        (map-set checkins {id: id}
          {user: (get user checkin),
           location: (get location checkin),
           timestamp: (get timestamp checkin),
           status: "verified"})
        (ok "Check-in verified")
      )
      (err u2)) ;; not active
    (err u3)) ;; check-in not found
)

;; Remove a check-in
(define-public (remove-checkin (id uint))
  (match (map-get? checkins {id: id})
    checkin
    (if (and (is-eq (get status checkin) "active") (is-eq tx-sender (get user checkin)))
      (begin
        (map-set checkins {id: id}
          {user: (get user checkin),
           location: (get location checkin),
           timestamp: (get timestamp checkin),
           status: "removed"})
        (ok "Check-in removed")
      )
      (err u4)) ;; not active or not user
    (err u5)) ;; check-in not found
)