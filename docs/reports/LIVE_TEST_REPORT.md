# ATG Observability — Live Test Report

**Generated:** 2026-08-05T08:07:14Z (T0–T10) · T11/T12 completed 2026-08-05T08:15Z  
**Mode:** `ATG_MODE=live` · ADS-B OpenSky catchment (LAX area) · product A2G only  
**Stack left running** after this pass (no `docker compose down`).

---

## Root cause of blank dashboards

Three independent defects stacked:

| # | Cause | Effect | Fix |
|---|-------|--------|-----|
| 1 | **Geographic mismatch** — `scenario.yaml` ground stations were at London Heathrow while the live ADS-B feed is filtered to the Los Angeles catchment | Every aircraft sat beyond the radio horizon → LoS = 0, elevation ≪ 0°, slant range ~8000 km, geomap empty of useful geometry | Relocated GS to `LAX-GS0` / `BUR-GS1` inside the ADS-B radius |
| 2 | **Exporter image stale + missing derivation** — `src/` is baked into the Docker image (not bind-mounted); Doppler / TA / path-loss / atmospheric / fuselage metrics existed in the registry but were never published from live ADS-B | Geometry + RF model panels returned `no data` even after GS fix | Added `src/exporter/derive.py`, rebuilt exporter image, integrated into the poll loop |
| 3 | **PromQL / naming / Grafana UID drift** — broken recording-rule joins (`atg:thp_efficiency_pct`, `atg:doppler_margin_pct`), a few metric-name typos in dashboards, and Grafana DB stuck on legacy UIDs `atg-ho` / `atg-aerial-map` while the generator wrote `atg-mob` / `atg-orbit` | Recording-rule panels empty; mobility + map boards served **stale** content and ignored generator updates | Fixed rule joins; corrected queries; reset `grafana_data` volume so provisioning reloads contract UIDs |

**Honesty boundary (unchanged):** panels that need a live OAI softmodem HO/QoS stream, a Sionna RT worker, or a second ADS-B source stay empty and now show an explicit `noValue` / banner (`Requires OAI feed…`, `Requires Sionna…`). No fabricated KPI values under `source="sionna"`.

Secondary (non-blocking) fix: PostGIS volume predated `serving_link` / related tables — applied `db/init/*.sql` into the running DB so GeoJSON serving-link upserts stop erroring.

---

## Per-dashboard status (Grafana query path)

| UID | Title | LIVE | EMPTY | ERROR | Verdict | Notes |
|-----|-------|-----:|------:|------:|---------|-------|
| `atg-exec` | 01 ATG Executive Overview | 7 | 3 | 0 | **PASS** | EMPTY = HO success / p99 latency / validation gates (need live HO + validation) |
| `atg-rf` | 02 ATG RF Physical Layer | 12 | 10 | 0 | **PASS** | Path loss / gains / atmospherics LIVE from derive; Sionna MPC / delay-spread / residual heatmap EXPECTED-GAP |
| `atg-mac` | 03 ATG Link Adaptation / MAC | 4 | 9 | 0 | **PASS** | MCS / BLER from OAI fixture LIVE; CQI hist / HARQ / PRB need richer OAI stream |
| `atg-thp` | 04 ATG Throughput / Capacity | 8 | 6 | 0 | **PASS** | OAI DL/UL + 38.306 ceiling LIVE; `source=sionna` thp / SE / Jain EMPTY (EXPECTED-GAP) |
| `atg-mob` | 05 ATG Mobility / Handover | 6 | 17 | 0 | **PASS** | Serving-cell / geometry-driven panels LIVE; HO counters need softmodem events |
| `atg-qos` | 06 ATG QoS / Service | 1 | 12 | 0 | **PASS (partial)** | Primary live panel present; latency/jitter/5QI need OAI user-plane fixtures |
| `atg-geo` | 07 ATG Aerial Geometry / Doppler | 23 | 1 | 0 | **PASS** | Doppler ±2.7 kHz, TA, path loss, fuselage, coherence — all LIVE; only CP budget (delay-spread) waits on Sionna |
| `atg-val` | 08 ATG Sionna vs OAI Validation | 3 | 19 | 0 | **PASS (honest gap)** | Pipeline / gate scaffolding LIVE; RMSE/KS/Pearson EMPTY until Sionna RT runs |
| `atg-orbit` | 09 Live Aerial Track Map | 6 | 1 | 0 | **PASS** | Aircraft/GS/serving GeoJSON + Prom overlays LIVE; cross-source RMSE needs 2nd feed |
| `atg-sig` | 10 ATG Signaling / Control Plane | 7 | 8 | 0 | **PASS** | RRC/NGAP fixture counters LIVE; XnAP fail % / per-AMF rate need richer PCAP |

**Totals:** 77 LIVE · 86 EMPTY (feed-gated / EXPECTED-GAP) · 0 ERROR · all 10 boards have ≥1 live panel.

---

## T1–T12 results

| ID | Test | Verdict | Evidence (sample) |
|----|------|---------|-------------------|
| T0 | Containers healthy | **PASS** | 6 services; unhealthy=none |
| T0b | Prometheus targets UP | **PASS** | `atg-exporter@exporter:9105=up`, `prometheus@localhost:9090=up` |
| T0c | Service endpoints 200 | **PASS** | `/healthz` `/readyz` `/metrics` Grafana `/api/health` Loki `/ready` all 200 |
| T0d | PostGIS reachable | **PASS** | `select 1` → `1` |
| T1 | Live ADS-B ingest | **PASS** | tracked 25→25; `records_ingested` 1506→1601 (Δ95 / 20 s) |
| T2 | Position freshness | **PASS** | `feed_up=1`; `msg_age_s` avg≈0 max=0.2 s |
| T3 | Geometry derived | **PASS** | 28 series each: slant max 146.7 km, elev max 11.3°, az 357°, Doppler max 2764 Hz, TA max 979 µs, PL max 146.7 dB, LoS sum=28 |
| T4a | GeoJSON endpoints 200 | **PASS** | aircraft/tracks/serving_links/ground_stations/sectors/coverage/ho_events/horizon all 200 |
| T4b | Aircraft GeoJSON updates | **PASS** | 28 features; payload changed over 12 s |
| T4c | PII scrub | **PASS** | no `icao24` / `callsign` / `hex` / `flight` keys in any payload |
| T5 | Recording rules live | **PASS** | 15/15 `atg:` series populated (incl. `atg:doppler_margin_pct`, `atg:thp_efficiency_pct`, `atg:horizon_margin_km`) |
| T6 | Alert/recording rules | **PASS** | `promtool check rules` rc=0; 31 alert + 50 recording rules loaded; unhealthy=none |
| T7 | OAI fixture path | **PASS** | `source=oai`: RSRP=-90.5, SINR=12, MCS=15, BLER=0.008, thp_dl=85 Mbps; `sig_msg_total=1960` |
| T8 | Sionna absent (honest) | **EXPECTED-GAP** | `pipeline_up{sionna}=0`; no `source=sionna` series; `ATG_SIONNA=0` / package not installed — correctly not fabricating |
| T9 | 10 dashboards primary data | **PASS** | see per-dashboard table; all boards ≥1 LIVE panel via Prom query path |
| T10 | Cardinality / forbidden labels | **PASS** | forbidden labels=none; 46 labels; ~1808 `atg_*` series; 28 `tail_id` (cap 64) |
| T11 | `pytest` suite | **PASS** | 199 collected tests, all green (`pytest -q`) |
| T12 | Replay determinism | **PASS** | `ParquetReplayer` seed=42 digest identical across runs (240 states); live exporter still `mode=live`, tracks>0 after check |

## T8 / live wire update (2026-08-05 follow-up)

| Workstream | Result |
|------------|--------|
| **Sionna RT** | **LIVE** — `sionna-rt` in exporter (`INSTALL_SIONNA=1`, LLVM CPU). Finite `atg_rsrp_dbm{source="sionna"}` ≈ −100 dBm, `atg_path_loss_db` ≈ 146 dB, `atg_pipeline_up{sionna}=1`, 49+ successful RT runs. OptiX GPU blocked in Docker Desktop (`libnvoptix`); LLVM is the supported path. |
| **Live OAI** | **LIVE** — softmodems on `.133`; `tools/sync-oai-logs-from-vm.ps1` + compose `oai-log-sync` → `data/logs/gnb_du0_live.log`. Sample: RSRP=**−43**, SINR≈**21.9**, MCS=0, BLER=0 (`source=oai`). See [SIONNA_OAI_WIRE.md](SIONNA_OAI_WIRE.md). |


---

## Exact URLs to open

| What | URL |
|------|-----|
| Grafana (login `admin` / `atgadmin`) | http://localhost:3000 |
| 01 Executive | http://localhost:3000/d/atg-exec |
| 02 RF Physical | http://localhost:3000/d/atg-rf |
| 03 MAC | http://localhost:3000/d/atg-mac |
| 04 Throughput | http://localhost:3000/d/atg-thp |
| 05 Mobility | http://localhost:3000/d/atg-mob |
| 06 QoS | http://localhost:3000/d/atg-qos |
| 07 Geometry / Doppler | http://localhost:3000/d/atg-geo |
| 08 Validation | http://localhost:3000/d/atg-val |
| 09 Aerial Track Map | http://localhost:3000/d/atg-orbit |
| 10 Signaling | http://localhost:3000/d/atg-sig |
| Prometheus | http://localhost:9090 |
| Prometheus targets | http://localhost:9090/targets |
| Exporter health | http://localhost:9105/healthz |
| Exporter metrics | http://localhost:9105/metrics |
| GeoJSON aircraft | http://localhost:9105/geojson/aircraft |
| Loki ready | http://localhost:3100/ready |

---

## Data-source honesty (what is live vs derived vs gated)

| Class | Examples | Present now? |
|-------|----------|--------------|
| Live ADS-B | `atg_altitude_ft`, `atg_adsb_feed_up`, GeoJSON aircraft | Yes |
| Deterministic model from live ADS-B + scenario | Doppler, TA, FSPL/TR36.777 path loss, ITU gaseous/rain/scintillation, fuselage, coherence time (`source="oai"` label convention for model path) | Yes (after `derive.py`) |
| OAI fixture ingest | RSRP/SINR/MCS/BLER/thp + RRC/NGAP counters from `data/logs` | Yes (fixture files) |
| Live OAI softmodem HO/QoS/CQI/PRB | HO attempt counters, latency histograms, CQI, PRB util | No — panels marked **Requires OAI feed** |
| Sionna RT | `source="sionna"` RSRP/SINR/MPC/delay-spread | No — **EXPECTED-GAP**, NaN/absent by design |
| Validation RMSE/KS | `atg_val_*`, `atg:rmse_*` | No until Sionna + dual-source validation run |

---

## Reproduction commands

```bash
cd atg-observability
docker compose ps
python scripts/audit_panels.py --json-out audit_after.json
python scripts/live_test.py
python scripts/check_replay.py
PYTHONPATH=src python -m pytest -q
```

Artifacts: `audit_after.json`, `live_test_results.json`, this file.
