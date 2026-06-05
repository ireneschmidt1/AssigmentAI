
;; PROBLEM 1.2 - Alarm Fires Mid-Transport, R3 Intervenes
;;   Both robots start at the corridor with full 100L cylinders.
;;   Patient A is Normal with LOW SpO2 (<91%) in room-a -> reservoir 12 L/step
;;   Patient B is COPD with MEDIUM SpO2 (88-91%) in room-b -> venturi 4 L/step
;;
;; TOPOLOGY:
;;   [room-a]-[room-b]-[corridor]-[room-c]-[room-d]-[safe-zone]

(define (problem sar-p2-alarm)
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

    ;; Positions
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

    ;; Initial oxygenlevels
    (= (oxygen-remaining r1) 100)
    (= (oxygen-remaining r2) 100)
    (= (oxygen-remaining r3) 0)
    (= (spare-cylinders-count r3) 4)

    ;; Devices
    (is-cannula   cannula)
    (is-mask      mask-simple)
    (is-venturi   venturi)
    (is-reservoir reservoir)

    ;; Flow rate (Liters used x step)
    (= (flow-rate cannula)     3)
    (= (flow-rate mask-simple) 7)
    (= (flow-rate venturi)     4)
    (= (flow-rate reservoir)   12)

    ;; Alarm thresholds 
    (= (alarm-threshold cannula)     15)
    (= (alarm-threshold mask-simple) 35)
    (= (alarm-threshold venturi)     20)
    (= (alarm-threshold reservoir)   60)

    ;; Topology that force to a controlled passage
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

    ;; R3 connections
    (connected base-r3 room-c)
    (connected room-c base-r3)
    (connected base-r3 safe-zone)
    (connected safe-zone base-r3)

    ;; Properties
    (safe-zone safe-zone)
    (is-base-r3 base-r3)

    ;; Patient A: Critic, (Reservoir (12 L/step), Alarm at 60L left))
    (patient-at patient-a room-a)
    (alive patient-a)
    (spo2-low patient-a)

    ;; Patient B: COPD (needs Venturi (4 L/step))
    (patient-at patient-b room-b)
    (alive patient-b)
    (is-copd patient-b)
    (spo2-medium patient-b)
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