# Realistic Map + Multi-Cell Handover — Live Report

Date: 2026-08-05  
Workspace: `atg-observability`  
Plan: `docs/superpowers/plans/2026-08-05-realistic-map-multicell-handover.md`

## Outcome

Multi-cell ATG map presentation and **modeled A3** handovers are implemented end-to-end with honest provenance. Authentic OAI measurement-driven HO remains gated behind an opt-in Path-B capability report and is **not** claimed from F1 CI triggers.

| Layer | Status |
|-------|--------|
| Four LA-basin cells (`gs0`–`gs3`) + colors/horizons | Live |
| Modeled RF candidates (Sionna preferred, link-budget fallback; OAI RSRP never copied) | Live (fallback) |
| Modeled A3 controller (`source=sionna`, `event_origin=model`, `procedure=modeled_a3`) | Live |
| GeoJSON origin/result filters + legacy origin inference | Live |
| Decluttered Geomap (tower/aircraft SVGs, origin-split HO) | Live (dashboards regenerated) |
| HO PromQL grouped by `source` | Live |
| Isolated Path-B capability gate (reporting-only) | Docs + stub |

## Verification evidence

### Tests
- Focused multicell / HO suite: **PASS**
- Full suite: **PASS** (`python -m pytest -q`)
- Dashboard + Path-B contract tests: **PASS**
- `bash -n` on `a2g-dual-cell-isolated.sh` via Git Bash: **PASS**

### Runtime smoke (after exporter rebuild)
| Check | Result |
|-------|--------|
| `http://localhost:3000/public/img/atg/aircraft.svg` | 200 |
| `http://localhost:3000/public/img/atg/gnb-tower.svg` | 200 |
| `/geojson/ground_stations` | 200, **4** features with distinct `color` |
| `/geojson/sectors` | 200, **4** features |
| `/geojson/horizon?cell_id=gs{0..3}` | 200 each, colors `#F18F01/#C73E1D/#2E86AB/#A23B72` |
| `/geojson/ho_events?origin=model` | 200, **0** features at sample time |
| `/geojson/ho_events?origin=oai` | 200, **12** features (`event_origin=oai`, `source=oai`) |
| Active serving cells | `gs0`, `gs1`, `gs2`, `gs3` all present (modeled attach/selection) |

Exporter was rebuilt so the container picked up the new Python path; Grafana dashboards are bind-mounted and already show the regenerated map layers.

## Provenance contracts (locked)

| Kind | `source` | `event_origin` | Notes |
|------|----------|----------------|-------|
| Modeled A3 | `sionna` | `model` | `procedure=modeled_a3`; RF backend recorded separately |
| Authentic OAI HO | `oai` | `oai` | Only after Path-B capability gate |
| F1 CI demo | `oai` | `oai` | `mechanism=f1_ci_trigger` — **not** measurement-driven A3 |

## Limitations (honest)

1. **Modeled A3 ≠ OAI A3.** Map/metric series labeled `source=sionna` / `event_origin=model` are lab-modelled from ADS-B geometry + link budget (Sionna RT package not installed in the exporter image).
2. **Single-cell Path-A** cannot produce authentic inter-cell measurement HO. Existing OAI HO markers/counters are F1/signaling-class events, not MeasurementReport-driven A3.
3. **Path-B dual-cell profile** (`oai-config/path-a2g/a2g-dual-cell-isolated.sh`) is **opt-in** and **reporting-only**. It never launches or stops Path-A. Authentic success requires all five evidence gates in `CAPABILITY_AUTHENTIC_HO.md`.
4. **No fabricated KPIs** when the gate fails — authentic HO panels remain NODATA / empty rather than inventing MeasurementReports.
5. At verification sample time, **no modeled HO markers** had fired yet (aircraft were attaching onto the strongest usable cell; A3 needs Off+Hys sustained through TTT). Serving already spans all four cells, which is the precondition for later modeled HO as aircraft move.
6. `atg_a3_margin_db{source="sionna"}` appears when the modeled controller emits events; it is not fabricated when idle.

## Grafana boards to inspect

- `atg-orbit` — Live Aerial Track Map  
- `atg-all-in-one` — All-in-One Live Operations  
- `atg-mob` — Mobility / Handover (HO rates grouped by `source`, live A3 margin series)

## Follow-ups (optional)

- Leave the stack running through aircraft motion to accumulate modeled HO markers, or temporarily lower Off/Hys in `scenario.yaml` for a demo (restore defaults afterward).
- Install Sionna RT in the exporter image if per-cell RT RSRP is required (`rf_backend=sionna`).
- Only after Path-B evidence gates pass, claim authentic measurement-driven HO.
