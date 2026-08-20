# Authentic OAI handover capability gate

`a2g-dual-cell-isolated.sh` is an **opt-in, isolated Path-B reporting
stub**. It is not Path-A bring-up. It does not start, stop, restart, or edit
the stable stack, and it performs no remote action. Its only outputs are
console status and:

`/tmp/patha2g-dual-isolated/capability_report.json`

The directory can be overridden with `LOG_DIR`. Evidence can be supplied in
`EVIDENCE_DIR`; the default is `$LOG_DIR/evidence`.

## Running the report

Without opt-in, the script writes a denied report and exits non-zero:

```bash
./a2g-dual-cell-isolated.sh
```

Evidence evaluation requires an explicit guard:

```bash
PATH_B_DUAL_CELL_OPT_IN=1 \
EVIDENCE_DIR=/path/to/read-only/evidence \
./a2g-dual-cell-isolated.sh
```

Even when the gate passes, this script does not launch a dual-cell stack. A
pass means only that the supplied evidence supports the claim represented in
the report.

## Required evidence

All five checks are mandatory. File existence alone is insufficient; each
file must contain the listed marker.

1. `neighbour_measurement_configuration.log`
   - `NEIGHBOUR_MEASUREMENT_CONFIGURED`
   - Proves that neighbour measurement configuration was delivered.
2. `ue_measurement_report.log`
   - `UE_MEASUREMENT_REPORT_OBSERVED`
   - Proves that a UE `MeasurementReport` was observed.
3. `ho_rrc_reconfiguration.log`
   - `HO_RRC_RECONFIGURATION_OBSERVED`
   - Proves HO command / RRC Reconfiguration evidence.
4. `target_cell_access_or_context_setup.log`
   - `TARGET_CELL_ACCESS_CONFIRMED` or
     `TARGET_CELL_CONTEXT_SETUP_CONFIRMED`
   - Proves target-cell access or context setup.
5. `completion_or_explicit_failure.log`
   - `HO_COMPLETION_OBSERVED` or `HO_EXPLICIT_FAILURE_OBSERVED`
   - Proves completion or explicit failure.

The report keys are
`neighbour_measurement_configuration`, `ue_measurement_report`,
`ho_rrc_reconfiguration`, `target_cell_access_or_context_setup`, and
`completion_or_explicit_failure`. All must be true before the capability
sequence is considered complete. `authentic_ho_success` is true only when
all five checks pass and the final evidence is completion, not failure.
Missing or failed checks mean authentic success metrics remain absent.

## Provenance contract

These fields answer different questions and must not be substituted for one
another:

- `source` identifies the bounded RF/metric producer. Authentic OAI evidence
  uses `source=oai`. Modeled candidate RF uses `source=sionna`, including a
  link-budget fallback whose detailed RF backend is recorded separately.
- `event_origin` identifies who created the handover event. OAI-observed
  signaling uses `event_origin=oai`; modeled controller events use
  `event_origin=model`.
- `mechanism` identifies how the procedure was initiated. A measurement-based
  authentic sequence uses `mechanism=measurement_driven_a3`.

An F1 CI command demo remains `source=oai`, `event_origin=oai`, and
`mechanism=f1_ci_trigger`. **F1 CI completion alone is not measurement-driven
A3 and must never be claimed as authentic A3 handover success.**

Modeled A3 events are useful simulation outputs, but
`source=sionna event_origin=model` is not authentic OAI A3.

## Isolation contract

- The script only reads supplied evidence and process presence.
- Stable Path-A configuration, processes, logs, and launch scripts are never
  changed or invoked. Do not replace `patha2g-bringup-du0.sh` with this
  profile.
- No core, CU, DU, UE, RFsim, container, dashboard, or remote system is
  started, stopped, or restarted.
- The isolated output directory is separate from stable Path-A logs.
- Shared ports are not reserved or altered because this reporting stub never
  starts a stack.
- If a future launch extension cannot coexist on shared RFsim ports, stop
  Path-A manually first and set `CONFIRM_STOP_PATH_A=1`. This reporting stub
  still does not stop Path-A itself.
