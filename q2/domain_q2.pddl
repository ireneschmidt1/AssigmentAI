(define (domain sar-oxygen-q2)
  (:requirements :typing :durative-actions :numeric-fluents)

  (:types
    robot patient location device - object
  )

  (:predicates
    (robot-at       ?r - robot    ?l - location)
    (patient-at     ?p - patient  ?l - location)
    (connected      ?from - location ?to - location)
    
    (safe-zone      ?l - location)
    (is-normal-room ?l - location) 
    (is-base-r3     ?l - location)

    (found          ?p - patient)
    (unfound        ?p - patient)
    (rescued        ?p - patient)
    (alive          ?p - patient)

    (is-copd        ?p - patient)
    (is-normal      ?p - patient)
    (spo2-high      ?p - patient)
    (spo2-medium    ?p - patient)
    (spo2-low       ?p - patient)

    (device-assigned ?p - patient ?d - device)
    (unassigned      ?p - patient)
    (on-oxygen       ?p - patient)
    (oxygen-off      ?p - patient)

    (is-cannula     ?d - device)
    (is-mask        ?d - device)
    (is-venturi     ?d - device)
    (is-reservoir   ?d - device)

    (robot-has-device   ?r - robot ?d - device)
    (robot-has-cylinder ?r - robot)

    (alarm-sent      ?r - robot)
    (alarm-clear     ?r - robot)
    (is-rescue-robot  ?r - robot)
    (is-support-robot ?r - robot)
  )

  (:functions
    (oxygen-remaining      ?r - robot)
    (spare-cylinders-count ?r - robot)
    (flow-rate             ?d - device)
    (alarm-threshold       ?d - device)
    (transit-duration      ?from - location ?to - location)
    (idle-consumption-rate)
  )

  ;; 1. DURATIVE NAVIGATE
  (:durative-action navigate
    :parameters (?r - robot ?from - location ?to - location)
    :duration (= ?duration (transit-duration ?from ?to))
    :condition (and
      (at start (robot-at ?r ?from))
      (over all (connected ?from ?to))
    )
    :effect (and
      (at start (not (robot-at ?r ?from)))
      (at end (robot-at ?r ?to))
      ;; Discretizzazione: Consumo calcolato = tasso * durata
      (at end (decrease (oxygen-remaining ?r) (* (idle-consumption-rate) (transit-duration ?from ?to))))
    )
  )

  ;; 2. INSTANT FIND PATIENT
  (:action find-patient
    :parameters (?r - robot ?p - patient ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (unfound ?p)
      (alive ?p)
      (is-rescue-robot ?r)
    )
    :effect (and
      (found ?p)
      (not (unfound ?p))
    )
  )

  ;; 3a. ASSIGN DEVICE - COPD Medium (Venturi)
  (:action assign-device-copd-medium
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (found ?p)
      (alive ?p)
      (is-copd ?p)
      (spo2-medium ?p)
      (is-venturi ?d)
      (robot-has-device ?r ?d)
      (unassigned ?p)
    )
    :effect (and
      (device-assigned ?p ?d)
      (not (unassigned ?p))
    )
  )

  ;; 3b. ASSIGN DEVICE - Normal Low (Reservoir)
  (:action assign-device-normal-low
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (found ?p)
      (alive ?p)
      (is-normal ?p)
      (spo2-low ?p)
      (is-reservoir ?d)
      (robot-has-device ?r ?d)
      (unassigned ?p)
    )
    :effect (and
      (device-assigned ?p ?d)
      (not (unassigned ?p))
    )
  )

  ;; 4. START OXYGEN DELIVERY
  (:action start-oxygen
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (found ?p)
      (alive ?p)
      (device-assigned ?p ?d)
      (oxygen-off ?p)
    )
    :effect (and
      (on-oxygen ?p)
      (not (oxygen-off ?p))
    )
  )

  ;; 5a. DURATIVE MOVE WITH PATIENT
  (:durative-action move-with-patient
    :parameters (?r - robot ?p - patient ?d - device ?from - location ?to - location)
    :duration (= ?duration (transit-duration ?from ?to))
    :condition (and
      (at start (robot-at ?r ?from))
      (at start (patient-at ?p ?from))
      (over all (on-oxygen ?p))
      (over all (alive ?p))
      (over all (device-assigned ?p ?d))
      (over all (connected ?from ?to))
      (over all (robot-has-cylinder ?r))
      (over all (alarm-clear ?r))
      (over all (is-normal-room ?to)) 
      (at start (> (oxygen-remaining ?r) (+ (* (transit-duration ?from ?to) (flow-rate ?d)) (alarm-threshold ?d))))
    )
    :effect (and
      (at start (not (robot-at ?r ?from)))
      (at start (not (patient-at ?p ?from)))
      (at end (robot-at ?r ?to))
      (at end (patient-at ?p ?to))
      ;; Discretizzazione: Consumo calcolato = flusso * durata
      (at end (decrease (oxygen-remaining ?r) (* (flow-rate ?d) (transit-duration ?from ?to))))
    )
  )

  ;; 5b. DURATIVE MOVE WITH PATIENT TO SAFE ZONE
  (:durative-action move-with-patient-to-safe-zone
    :parameters (?r - robot ?p - patient ?d - device ?from - location ?to - location)
    :duration (= ?duration (transit-duration ?from ?to))
    :condition (and
      (at start (robot-at ?r ?from))
      (at start (patient-at ?p ?from))
      (over all (on-oxygen ?p))
      (over all (alive ?p))
      (over all (device-assigned ?p ?d))
      (over all (connected ?from ?to))
      (over all (robot-has-cylinder ?r))
      (over all (alarm-clear ?r))
      (over all (safe-zone ?to)) 
      (at start (> (oxygen-remaining ?r) (+ (* (transit-duration ?from ?to) (flow-rate ?d)) (alarm-threshold ?d))))
    )
    :effect (and
      (at start (not (robot-at ?r ?from)))
      (at start (not (patient-at ?p ?from)))
      (at end (robot-at ?r ?to))
      (at end (patient-at ?p ?to))
      ;; Discretizzazione
      (at end (decrease (oxygen-remaining ?r) (* (flow-rate ?d) (transit-duration ?from ?to))))
      (at end (rescued ?p)) 
    )
  )

  ;; 6. INSTANT SEND ALARM
  (:action send-alarm
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (on-oxygen ?p)
      (alive ?p)
      (device-assigned ?p ?d)
      (robot-has-cylinder ?r)
      (alarm-clear ?r)
      (<= (oxygen-remaining ?r) (alarm-threshold ?d))
    )
    :effect (and
      (alarm-sent ?r)
      (not (alarm-clear ?r))
    )
  )

  ;; 7a. DURATIVE SUPPORT NAVIGATE TO ALARM
  (:durative-action navigate-to-alarm
    :parameters (?r3 - robot ?rtarget - robot ?from - location ?to - location)
    :duration (= ?duration (transit-duration ?from ?to))
    :condition (and
      (over all (is-support-robot ?r3))
      (at start (is-base-r3 ?from))
      (at start (robot-at ?r3 ?from))
      (over all (robot-at ?rtarget ?to))
      (over all (alarm-sent ?rtarget))
      (over all (> (spare-cylinders-count ?r3) 0))
      (over all (connected ?from ?to))
    )
    :effect (and
      (at start (not (robot-at ?r3 ?from)))
      (at end (robot-at ?r3 ?to))
    )
  )

  ;; 7b. DURATIVE CYLINDER REPLACEMENT TASK
  (:durative-action deliver-cylinder
    :parameters (?r3 - robot ?rtarget - robot ?p - patient ?d - device ?l - location)
    :duration (= ?duration 2.0)
    :condition (and
      (over all (is-support-robot ?r3))
      (over all (robot-at ?r3 ?l))
      (over all (robot-at ?rtarget ?l))
      (over all (patient-at ?p ?l))
      (over all (device-assigned ?p ?d))
      (over all (alarm-sent ?rtarget))
      (at start (> (spare-cylinders-count ?r3) 0))
    )
    :effect (and
      (at end (assign (oxygen-remaining ?rtarget) 100))
      (at end (decrease (spare-cylinders-count ?r3) 1))
      (at end (not (alarm-sent ?rtarget)))
      (at end (alarm-clear ?rtarget))
    )
  )

  ;; 7c. DURATIVE RETURN TO BASE
  (:durative-action return-to-base
    :parameters (?r3 - robot ?from - location ?base - location)
    :duration (= ?duration (transit-duration ?from ?base))
    :condition (and
      (over all (is-support-robot ?r3))
      (at start (robot-at ?r3 ?from))
      (over all (is-base-r3 ?base))
      (over all (connected ?from ?base))
    )
    :effect (and
      (at start (not (robot-at ?r3 ?from)))
      (at end (robot-at ?r3 ?base))
    )
  )
)