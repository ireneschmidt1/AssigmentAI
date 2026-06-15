# AssigmentAI
D4_V8: Search and Rescue- Oxygen Constraints and Survival Limits
# Automated Planning for Autonomous SAR Fleets
**Search and Rescue – Oxygen Constraints and Survival Limits**

This repository contains the design, implementation, and evaluation of an automated planning framework for an autonomous multi-agent robotic fleet operating in a safety-critical Search and Rescue (SAR) environment. The central operational constraint is atmospheric oxygen degradation; both robotic assets and human victims depend entirely on localized, finite life-support payloads.

### Multi-Agent Fleet
* **Primary Rescue Units ($R_1$, $R_2$):** Equipped with composite high-pressure cylinders providing 1000L of oxygen. For computational grounding efficiency, this payload is normalized to 100 operational units.
* **Logistical Support Asset ($R_3$):** A specialized robot capable of delivering fresh cylinders mid-transit to prevent irreversible cellular necrosis in patients experiencing acute cerebral hypoxia.

### Modeling Paradigms
To address the full spectrum of planning expressiveness, the project develops two distinct architectural models:

#### 1. Q1 Model (Discrete Numeric PDDL)
* **Mechanics:** Employs the `:numeric-fluents` requirement where time is discretized into sequential task-steps, and oxygen depletion is mapped to discrete spatial movements.
* **Optimization:** Minimizes `total-oxygen-consumed`.
* **Reward Hacking Prevention:** Early iterations saw the heuristic planner "kidnapping" rescued patients from the safe zone to waste oxygen and artificially trigger a cylinder reset from $R_3$. This metric exploitation was solved by introducing a strict topological lock: `(not (safe-zone ?from))`.

#### 2. Q2 Model (Continuous Temporal PDDL+)
* **Mechanics:** Employs `:durative-actions` to model continuous resource degradation occurring concurrently alongside parallel multi-agent graph execution.
* **Optimization:** Minimizes global mission makespan (`total-time`).
* **Compiler Stabilization (Action Splitting):** State-of-the-art LP solvers (like OPTIC) can suffer severe memory corruption when evaluating conditional effects inside durative actions. To ensure stability, transport logic was split into two mutually exclusive actions (`move-with-patient` and `move-with-patient-to-safe-zone`). 
* **Exact Temporal Discretization:** Instead of relying on native continuous `#t` decay, oxygen depletion is calculated precisely at the end of the durative action using the integral of the flow rate over the specific edge duration.

### 🩺 Medical Device Constraints
The planner dynamically assigns medical devices based on the patient's SpO₂ saturation profile to prevent tissue hypoxia. The devices enforce the following parameters:

| Device | Indication | Q1 Flow | Q2 Flow | Alarm Threshold (Q1/Q2) |
| :--- | :--- | :--- | :--- | :--- |
| **Nasal Cannula** | Mild desaturation, SpO₂ > 92% | 3 units/step | 1.5 units/sec | 15 / 15 units |
| **Venturi Mask** | COPD/BPCO, 88% ≤ SpO₂ ≤ 91% | 4 units/step | 2.0 units/sec | 20 / 20 units |
| **Simple Face Mask** | Non-COPD, moderate hypoxia | 7 units/step | 3.5 units/sec | 35 / 35 units |
| **Reservoir Mask** | Profound hypoxia, SpO₂ < 91% | 12 units/step | 6.0 units/sec | 60 / 40 units |

### Execution and Emergent Behaviors
By linking physical kinematics directly to physiological constraints, the heuristic planning engines correctly predict mathematical dead-ends and dynamically rewrite operational timelines. Testing reveals emergent behaviors, such as multi-agent handoffs, where one robot acts purely as a clinical setup unit while the other acts as a dedicated transport vector to optimize asset availability.
