# Grafana screenshot captures

PNG files here are used **once** in the root [README.md](../../README.md) **Live Demo** walkthrough (not repeated under Key Findings or Dashboard Pages). Display order on GitHub is catalog → all-in-one → link-budget tiles → serving/HO → signalling → Sionna twin → Diona baseline.

| File | What the capture shows | Honesty |
|---|---|---|
| `00-dashboard-catalog.png` | Grafana folder listing of the eleven ATG boards (01–11) | Catalog only |
| `01-all-in-one-live-operations.png` | All-in-One Live Operations: health strip + aerial geomap | Mix of measured ping, ADS-B kinematics, log RF, modeled A3 / optional Sionna |
| `02-sionna-vs-oai-digital-twin.png` | Sionna vs OAI RSRP/SINR/path-loss overlay + offline study strip | Twin is model (`source=sionna`); RMSE/accuracy empty until a paired feed |
| `03-diona-baseline-comparison.png` | Diona vs ATG KPI tiles, alerts, OAI log tail | **Diona = CSV baseline**, not live telemetry |
| `04-signalling-control-plane.png` | 3GPP control-plane ladder (RRC / F1AP / NGAP / NAS) | F1 HO is signalling-class; not measurement-report A3 |
| `05-link-budget-kpis-aiops.png` | Link-budget / KPI / AIOps / aerial-health stat tiles | Path loss family = model; RSRP/SINR = log when present; empties stay empty |
| `06-serving-cell-ho-log.png` | Ground stations, altitude, serving-cell ribbon, HO-by-source | Split `source=oai` (F1) vs `procedure=modeled_a3` |

Older captures kept for extra map/call-flow proof (not the README walkthrough order):

| File | Grafana UID / role |
|---|---|
| `atg-all-in-one.png` | `atg-all-in-one` |
| `atg-orbit.png` | `atg-orbit` (Live Aerial Track Map UID; filename is a path token) |
| `atg-map-semantics.png` | map symbol / layer proof |
| `atg-callflow.png` | signaling / call-flow sample |
| `atg-signalling.png` | All-in-One signaling row |
| `atg-map-hover.png` | map hover / tooltip |
| `atg-all-in-one-sample.png` / `atg-orbit-sample.png` | additional samples |

Do not include raw ICAO24, callsigns, passwords, or `.env` contents in new captures. This pack is **ATG only** (ground BS ↔ aircraft UE).
