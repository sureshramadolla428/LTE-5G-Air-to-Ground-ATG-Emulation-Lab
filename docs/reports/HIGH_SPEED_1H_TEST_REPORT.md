# High-Speed 1-Hour Dashboard Continuity Test

**Status:** FINAL | **Verdict:** **PASS** | **Mode:** FULL (3600 s / 1h)
**Start (UTC):** 2026-08-05 18:43:28Z  |  **As-of (UTC):** 2026-08-05 19:43:29Z  |  **Elapsed:** 3601s
**Cycle:** 180s data session -> 10s wait | **Sample:** every 12s | **Fail blank streak:** 3

## Handover context (honest)

- **Ground-tower (cell) HO** for an aircraft UE is in-scope 3GPP ATG mobility (TS 38.331 A3/A5/CHO/DAPS; TR 38.876 aerial scenarios).
- **This lab is single-cell Path-A** - authentic cell HO is **not expected** unless Path-B dual-DU (neighbour cells) is brought up. HO-only panels may stay **NODATA** and are scored **EXPECTED**, not FAIL.
- **HO between flights** is **not** a UE-UE handover: multiple aircraft are multiple UEs that may be served by different cells; inter-flight HO is not a 3GPP procedure.
- No HO counters or GeoJSON HO markers were fabricated for this test.

## Stack

| Service | URL |
|---------|-----|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Exporter | http://localhost:9105 |
| Progress log | `C:\Users\sures\OneDrive\Desktop\LTE_5g_ATG_emulation_lab\atg-observability\data\highspeed_1h_progress.jsonl` |

## Per-dashboard pass/fail

| Dashboard | LIVE sample-hits | BLANK | EXPECTED(HO) | ERROR | Critical fail | Verdict |
|-----------|-----------------:|------:|-------------:|------:|:-------------:|---------|
| [01 ATG Executive Overview](http://localhost:3000/d/atg-exec) | 813 | 0 | 271 | 0 | no | **PASS** |
| [02 ATG RF Physical Layer](http://localhost:3000/d/atg-rf) | 1084 | 0 | 0 | 0 | no | **PASS** |
| [03 ATG Link Adaptation / MAC](http://localhost:3000/d/atg-mac) | 271 | 0 | 0 | 0 | no | **PASS** |
| [04 ATG Throughput / Capacity](http://localhost:3000/d/atg-thp) | 269 | 2 | 0 | 0 | no | **PASS** |
| [05 ATG Mobility / Handover](http://localhost:3000/d/atg-mob) | 598 | 0 | 1570 | 0 | no | **PASS** |
| [06 ATG QoS / Service](http://localhost:3000/d/atg-qos) | 1349 | 6 | 0 | 0 | no | **PASS** |
| [07 ATG Aerial Geometry / Doppler](http://localhost:3000/d/atg-geo) | 1084 | 0 | 0 | 0 | no | **PASS** |
| [08 ATG Sionna vs OAI Validation](http://localhost:3000/d/atg-val) | 542 | 0 | 0 | 0 | no | **PASS** |
| [09 Live Aerial Track Map](http://localhost:3000/d/atg-orbit) | 1084 | 0 | 268 | 3 | no | **PASS** |
| [10 ATG Signaling / Control Plane](http://localhost:3000/d/atg-sig) | 542 | 0 | 0 | 0 | no | **PASS** |
| [11 All-in-One Live Operations](http://localhost:3000/d/atg-all-in-one) | 542 | 0 | 0 | 0 | no | **PASS** |

Counts are sample-hit totals across the run (not unique panel counts).

## Panel detail

| Id | Dashboard | Title | Class | LIVE | BLANK | EXPECTED | ERROR | Max blank streak | Last | Last value | Fail |
|----|-----------|-------|-------|-----:|------:|---------:|------:|-----------------:|------|------------|:----:|
| `adsb_tracked` | atg-exec | Aircraft tracked | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 267 |  |
| `adsb_feed` | atg-exec | ADS-B feed up | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `alt_series` | atg-orbit | Altitude series count | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 32 |  |
| `exporter_up` | atg-all-in-one | Exporter build | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `geojson_aircraft` | atg-orbit | GeoJSON aircraft | critical | 270 | 0 | 0 | 1 | 1 | LIVE | 267 |  |
| `slant` | atg-geo | Slant range | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 32 |  |
| `elev` | atg-geo | Elevation | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 32 |  |
| `doppler` | atg-geo | Doppler | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 32 |  |
| `path_loss_derive` | atg-rf | Path loss (derive) | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 33 |  |
| `ta` | atg-geo | Timing advance | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 32 |  |
| `oai_pipe` | atg-all-in-one | OAI pipeline | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `oai_rsrp` | atg-rf | OAI RSRP | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 2 |  |
| `oai_sinr` | atg-rf | OAI SINR | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 2 |  |
| `oai_mcs` | atg-mac | OAI MCS | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 4 |  |
| `rrc` | atg-sig | RRC connections | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `thp_dl` | atg-thp | OAI DL throughput | critical | 269 | 2 | 0 | 0 | 2 | BLANK | - |  |
| `lat_p50` | atg-qos | Latency p50 | critical | 269 | 2 | 0 | 0 | 2 | LIVE | 11.1404 |  |
| `lat_p95` | atg-qos | Latency p95 | critical | 269 | 2 | 0 | 0 | 2 | LIVE | 19.4298 |  |
| `jitter` | atg-qos | Jitter p95 | critical | 269 | 2 | 0 | 0 | 2 | LIVE | 9.9375 |  |
| `pkt_loss` | atg-qos | Packet loss ratio | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `retain` | atg-qos | Retainability | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `sionna_pipe` | atg-val | Sionna pipeline | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `sionna_rsrp` | atg-rf | Sionna RSRP | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `sionna_runs` | atg-val | Sionna RT runs | critical | 271 | 0 | 0 | 0 | 0 | LIVE | 14 |  |
| `coverage_pct` | atg-exec | Coverage availability | continuous | 271 | 0 | 0 | 0 | 0 | LIVE | 100 |  |
| `sig_total` | atg-sig | Sig msg total | continuous | 271 | 0 | 0 | 0 | 0 | LIVE | 30 |  |
| `geojson_gs` | atg-orbit | GeoJSON ground stations | continuous | 270 | 0 | 0 | 1 | 1 | LIVE | 2 |  |
| `geojson_links` | atg-orbit | GeoJSON serving links | continuous | 270 | 0 | 0 | 1 | 1 | LIVE | 249 |  |
| `time_of_stay` | atg-mob | Time of stay (OAI) | continuous | 271 | 0 | 0 | 0 | 0 | LIVE | 1 |  |
| `serving_cell` | atg-mob | Serving cell info | continuous | 271 | 0 | 0 | 0 | 0 | LIVE | 90 |  |
| `ho_attempt` | atg-mob | HO attempts | expected_ho | 28 | 0 | 243 | 0 | 0 | LIVE | 6 |  |
| `ho_success` | atg-mob | HO success | expected_ho | 2 | 0 | 269 | 0 | 0 | LIVE | 2 |  |
| `ho_fail` | atg-mob | HO fail | expected_ho | 0 | 0 | 271 | 0 | 0 | EXPECTED | - |  |
| `ho_rate` | atg-mob | HO attempt rate | expected_ho | 26 | 0 | 245 | 0 | 0 | LIVE | 0.00338997 |  |
| `cho_exec` | atg-mob | CHO executed | expected_ho | 0 | 0 | 271 | 0 | 0 | EXPECTED | - |  |
| `daps` | atg-mob | DAPS HO | expected_ho | 0 | 0 | 271 | 0 | 0 | EXPECTED | - |  |
| `ho_success_pct` | atg-exec | HO success pct | expected_ho | 0 | 0 | 271 | 0 | 0 | EXPECTED | - |  |
| `geojson_ho` | atg-orbit | GeoJSON HO events | expected_ho | 3 | 0 | 268 | 0 | 0 | LIVE | 6 |  |

## Critical failures

None - all critical continuous panels stayed within blank-streak budget.

## Re-run

```powershell
cd C:\Users\sures\OneDrive\Desktop\LTE_5g_ATG_emulation_lab\atg-observability
docker compose --profile oai-sync up -d
powershell -ExecutionPolicy Bypass -File tools\highspeed_1h_dashboard_test.ps1
# Smoke only (~8 min):
powershell -ExecutionPolicy Bypass -File tools\highspeed_1h_dashboard_test.ps1 -SmokeOnly
# Watch progress:
Get-Content data\highspeed_1h_progress.jsonl -Tail 20 -Wait
```


