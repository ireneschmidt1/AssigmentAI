(define (domain sar-oxygen-q1)
  (:requirements :typing :numeric-fluents :negative-preconditions :equality :conditional-effects)

  (:types
    robot patient location device - object
  )

  (:predicates
    (robot-at       ?r - robot    ?l - location)
    (patient-at     ?p - patient  ?l - location)
    (connected      ?from - location ?to - location)
    (safe-zone      ?l - location)
    (is-base-r3     ?l - location)

    (found          ?p - patient)
    (rescued        ?p - patient)
    (alive          ?p - patient)

    (is-copd        ?p - patient)
    (spo2-high      ?p - patient)
    (spo2-medium    ?p - patient)
    (spo2-low       ?p - patient)

    (device-assigned ?p - patient ?d - device)
    (on-oxygen       ?p - patient)

    (is-cannula     ?d - device)
    (is-mask        ?d - device)
    (is-venturi     ?d - device)
    (is-reservoir   ?d - device)

    (robot-has-device   ?r - robot ?d - device)
    (robot-has-cylinder ?r - robot)

    (alarm-sent      ?r - robot)
    (is-rescue-robot  ?r - robot)
    (is-support-robot ?r - robot)
  )

  (:functions
    (oxygen-remaining      ?r - robot)
    (spare-cylinders-count ?r - robot)
    (flow-rate             ?d - device)
    (alarm-threshold       ?d - device)
  )

  ;; 1. NAVIGATE (robot moves without patient)
  (:action navigate
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot-at ?r ?from)
      (connected ?from ?to)
    )
    :effect (and
      (not (robot-at ?r ?from))
      (robot-at ?r ?to)
    )
  )

  ;; 2. FIND PATIENT
  (:action find-patient
    :parameters (?r - robot ?p - patient ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (not (found ?p))
      (alive ?p)
      (is-rescue-robot ?r)
    )
    :effect (found ?p)
  )

  ;; 3a. ASSIGN DEVICE - Normal patient, high SpO2
  (:action assign-device-normal-high
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (found ?p)
      (alive ?p)
      (not (is-copd ?p))
      (spo2-high ?p)
      (is-cannula ?d)
      (robot-has-device ?r ?d)
      (not (device-assigned ?p ?d))
    )
    :effect (device-assigned ?p ?d)
  )

  ;; 3b. ASSIGN DEVICE - Normal patient, medium SpO2
  (:action assign-device-normal-medium
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (found ?p)
      (alive ?p)
      (not (is-copd ?p))
      (spo2-medium ?p)
      (is-mask ?d)
      (robot-has-device ?r ?d)
      (not (device-assigned ?p ?d))
    )
    :effect (device-assigned ?p ?d)
  )

  ;; 3c. ASSIGN DEVICE - Normal patient, low SpO2
  (:action assign-device-normal-low
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (found ?p)
      (alive ?p)
      (not (is-copd ?p))
      (spo2-low ?p)
      (is-reservoir ?d)
      (robot-has-device ?r ?d)
      (not (device-assigned ?p ?d))
    )
    :effect (device-assigned ?p ?d)
  )

  ;; 3d. ASSIGN DEVICE - COPD patient, high SpO2
  (:action assign-device-copd-high
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (found ?p)
      (alive ?p)
      (is-copd ?p)
      (spo2-high ?p)
      (is-cannula ?d)
      (robot-has-device ?r ?d)
      (not (device-assigned ?p ?d))
    )
    :effect (device-assigned ?p ?d)
  )

  ;; 3e. ASSIGN DEVICE - COPD patient, medium SpO2
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
      (not (device-assigned ?p ?d))
    )
    :effect (device-assigned ?p ?d)
  )

  ;; 3f. ASSIGN DEVICE - COPD patient, low SpO2
  (:action assign-device-copd-low
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (found ?p)
      (alive ?p)
      (is-copd ?p)
      (spo2-low ?p)
      (is-reservoir ?d)
      (robot-has-device ?r ?d)
      (not (device-assigned ?p ?d))
    )
    :effect (device-assigned ?p ?d)
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
      (not (on-oxygen ?p))
    )
    :effect (on-oxygen ?p)
  )

  ;; 5. MOVE WITH PATIENT (Aggiornato: Blocca il movimento dalla Safe-Zone)
  (:action move-with-patient
    :parameters (?r - robot ?p - patient ?d - device ?from - location ?to - location)
    :precondition (and
      (robot-at ?r ?from)
      (patient-at ?p ?from)
      (on-oxygen ?p)
      (alive ?p)
      (device-assigned ?p ?d)
      (connected ?from ?to)
      (robot-has-cylinder ?r)
      (not (alarm-sent ?r))
      (not (safe-zone ?from)) ;; <--- QUESTO BLOCCA IL PAZIENTE NELLA SAFE ZONE PER SEMPRE
      (> (oxygen-remaining ?r) (+ (flow-rate ?d) (alarm-threshold ?d)))
    )
    :effect (and
      (not (robot-at ?r ?from))
      (not (patient-at ?p ?from))
      (robot-at ?r ?to)
      (patient-at ?p ?to)
      (decrease (oxygen-remaining ?r) (flow-rate ?d))
      (when (safe-zone ?to) (rescued ?p))
    )
  )
  ;; 6. SEND ALARM
  (:action send-alarm
    :parameters (?r - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (robot-at ?r ?l)
      (patient-at ?p ?l)
      (on-oxygen ?p)
      (alive ?p)
      (device-assigned ?p ?d)
      (robot-has-cylinder ?r)
      (not (alarm-sent ?r))
      (<= (oxygen-remaining ?r) (+ (flow-rate ?d) (alarm-threshold ?d)))
    )
    :effect (alarm-sent ?r)
  )

  ;; 7a. R3 NAVIGATES TO ROBOT IN TROUBLE
  (:action navigate-to-alarm
    :parameters (?r3 - robot ?r-trouble - robot ?from - location ?to - location)
    :precondition (and
      (is-support-robot ?r3)
      (is-base-r3 ?from)
      (robot-at ?r3 ?from)
      (robot-at ?r-trouble ?to)
      (alarm-sent ?r-trouble)
      (> (spare-cylinders-count ?r3) 0)
      (connected ?from ?to)
    )
    :effect (and
      (not (robot-at ?r3 ?from))
      (robot-at ?r3 ?to)
    )
  )

  ;; 7b. R3 DELIVERS CYLINDER
  (:action deliver-cylinder
    :parameters (?r3 - robot ?r-receiver - robot ?p - patient ?d - device ?l - location)
    :precondition (and
      (is-support-robot ?r3)
      (robot-at ?r3 ?l)
      (robot-at ?r-receiver ?l)
      (patient-at ?p ?l)
      (device-assigned ?p ?d)
      (alarm-sent ?r-receiver)
      (> (spare-cylinders-count ?r3) 0)
    )
    :effect (and
      (assign (oxygen-remaining ?r-receiver) 100)
      (decrease (spare-cylinders-count ?r3) 1)
      (not (alarm-sent ?r-receiver))
    )
  )

  ;; 7c. R3 RETURNS TO BASE
  (:action return-to-base
    :parameters (?r3 - robot ?from - location ?base - location)
    :precondition (and
      (is-support-robot ?r3)
      (robot-at ?r3 ?from)
      (is-base-r3 ?base)
      (not (= ?from ?base))
      (connected ?from ?base)
    )
    :effect (and
      (not (robot-at ?r3 ?from))
      (robot-at ?r3 ?base)
    )
  )
)