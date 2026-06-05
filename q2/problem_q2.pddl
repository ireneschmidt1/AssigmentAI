(define (problem sar-q2-temporal-alarm)
  (:domain sar-oxygen-q2)

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

    ;; Position and state
    (robot-at r1 corridor)
    (robot-at r2 corridor)
    (robot-at r3 base-r3)
    (alarm-clear r1)
    (alarm-clear r2)
    (alarm-clear r3)

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

    ;; Oxygen Levels 
    (= (oxygen-remaining r1) 100)
    (= (oxygen-remaining r2) 100)
    (= (oxygen-remaining r3) 0)
    (= (spare-cylinders-count r3) 4)

    ;; Devices
    (is-cannula   cannula)
    (is-mask      mask-simple)
    (is-venturi   venturi)
    (is-reservoir reservoir)

    ;; Continuous Flow Rates (Liters per second)
    (= (flow-rate cannula)     1.5)
    (= (flow-rate mask-simple) 3.5)
    (= (flow-rate venturi)     2.0)
    (= (flow-rate reservoir)   6.0)

    ;; Standby Background Drainage Rate
    (= (idle-consumption-rate) 0.1)

    ;; Critical Alarm Thresholds
    (= (alarm-threshold cannula)     15)
    (= (alarm-threshold mask-simple) 35)
    (= (alarm-threshold venturi)     20)
    (= (alarm-threshold reservoir)   40)

    ;; Temporal Map Topology (Durations in seconds)
    (= (transit-duration room-a room-b) 4.0)
    (= (transit-duration room-b room-a) 4.0)
    (= (transit-duration room-b corridor) 3.0)
    (= (transit-duration corridor room-b) 3.0)
    (= (transit-duration corridor room-c) 3.0)
    (= (transit-duration room-c corridor) 3.0)
    (= (transit-duration room-c room-d) 4.0)
    (= (transit-duration room-d room-c) 4.0)
    (= (transit-duration room-d safe-zone) 5.0)
    (= (transit-duration safe-zone room-d) 5.0)

    ;; R3 Support Durations (just for room c and safe zone)
    (= (transit-duration base-r3 room-c) 2.0)
    (= (transit-duration room-c base-r3) 2.0)
    (= (transit-duration base-r3 safe-zone) 2.0)
    (= (transit-duration safe-zone base-r3) 2.0)

    ;; Logical Map Topology
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

    ;; R3 Support Connections ---
    (connected base-r3 room-c)
    (connected room-c base-r3)
    (connected base-r3 safe-zone)
    (connected safe-zone base-r3)

    ;; Properties
    (safe-zone safe-zone)
    (is-base-r3 base-r3)
    (is-normal-room room-a)
    (is-normal-room room-b)
    (is-normal-room corridor)
    (is-normal-room room-c)
    (is-normal-room room-d)

    ;; Patient A (Reservoir: 6.0 L/s, Alarm at 40)
    (patient-at patient-a room-a)
    (alive patient-a)
    (is-normal patient-a)
    (spo2-low patient-a) 
    (unfound patient-a)
    (unassigned patient-a)
    (oxygen-off patient-a)

    ;; Patient B (Venturi: 2.0 L/s, Alarm at 20)
    (patient-at patient-b room-b)
    (alive patient-b)
    (is-copd patient-b)
    (spo2-medium patient-b) 
    (unfound patient-b)
    (unassigned patient-b)
    (oxygen-off patient-b)
  )

  (:goal
    (and
      (rescued patient-a)
      (rescued patient-b)
    )
  )

  (:metric minimize (total-time))
)