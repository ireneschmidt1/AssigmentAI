
;; PROBLEM 1 - Sufficient Oxygen, No Alarm
;;   Both robots start at corridor with full 100L cylinders.
;;   Patient A is COPD with medium SpO2 (88-91%) in room-b.
;;   Patient B is Normal with high SpO2 (>=95%) in room-a.
;;
;; TOPOLOGY:
;;   [room-a]-[room-b]-[corridor]-[room-c]-[room-d]-[safe-zone]

(define (problem sar-p1-no-alarm)
  (:domain sar-oxygen-q1)

  (:objects
    r1 r2 r3                                          - robot
    patient-a patient-b                               - patient
    room-a room-b corridor room-c room-d
    safe-zone base-r3                                 - location
    cannula mask-simple venturi reservoir             - device
  )

  (:init
    ;; Roles
    (is-rescue-robot r1)
    (is-rescue-robot r2)
    (is-support-robot r3)

    ;; Position
    (robot-at r1 corridor)
    (robot-at r2 corridor)
    (robot-at r3 base-r3)

    ;; Equipment
    (robot-has-cylinder r1)
    (robot-has-cylinder r2)
    
    (robot-has-device r1 cannula)
    (robot-has-device r1 mask-simple)
    (robot-has-device r1 venturi)
    (robot-has-device r1 reservoir)
    (robot-has-device r2 cannula)
    (robot-has-device r2 mask-simple)
    (robot-has-device r2 venturi)
    (robot-has-device r2 reservoir)

    ;; Oxygen levels
    (= (oxygen-remaining r1) 100)
    (= (oxygen-remaining r2) 100)
    (= (oxygen-remaining r3) 0)
    (= (spare-cylinders-count r3) 4)

    ;; Devices
    (is-cannula   cannula)
    (is-mask      mask-simple)
    (is-venturi   venturi)
    (is-reservoir reservoir)

    ;; Flow rates (L per transport step) 
    (= (flow-rate cannula)     3)
    (= (flow-rate mask-simple) 7)
    (= (flow-rate venturi)     4)
    (= (flow-rate reservoir)  12)

    ;; Alarm thresholds (flow-rate x 5) 
    (= (alarm-threshold cannula)     15)
    (= (alarm-threshold mask-simple) 35)
    (= (alarm-threshold venturi)     20)
    (= (alarm-threshold reservoir)   60)

    ;; bidirectional connections 
    (connected room-a room-b)
    (connected room-b room-a)
    (connected room-b corridor)
    (connected corridor room-b)
    (connected corridor room-c)
    (connected room-c corridor)
    (connected room-c room-d)
    (connected room-d room-c)
    (connected room-d safe-zone)
    (connected safe-zone room-d)

    ;; R3 base connections 
    (connected base-r3 room-a)
    (connected base-r3 room-b)
    (connected base-r3 corridor)
    (connected base-r3 room-c)
    (connected base-r3 room-d)
    (connected base-r3 safe-zone)
    (connected room-a base-r3)
    (connected room-b base-r3)
    (connected corridor base-r3)
    (connected room-c base-r3)
    (connected room-d base-r3)
    (connected safe-zone base-r3)

    ;; Location prop
    (safe-zone safe-zone)
    (is-base-r3 base-r3)

    ;; Patient A: COPD, medium SpO2  (needs venturi 4 L/step)
    (patient-at patient-a room-b)
    (alive patient-a)
    (is-copd patient-a)
    (spo2-medium patient-a)

    ;; Patient B: Normal, high SpO2 (cannula 3 L/step )
    (patient-at patient-b room-a)
    (alive patient-b)
    (spo2-high patient-b)
  )

  (:goal
    (and
      (rescued patient-a)
      (rescued patient-b)
    )
  )

  (:metric minimize
    (+ (- 100 (oxygen-remaining r1))
       (- 100 (oxygen-remaining r2)))
  )
)