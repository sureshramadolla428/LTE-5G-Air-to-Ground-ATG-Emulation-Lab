# SPEC_ALIGNMENT — MODULE 0–10

Alignment of `atg-observability/` against the production ATG observability spec
(MODULE 0–10).

A2G only. Dashboard 09 uid=`atg-orbit` title=**Live Aerial Track Map** (ADS-B).

## MODULE 0 — Constraints

| Constraint | Status |
|------------|--------|
| Spec citations on KPI formulas | **PASS** (inline in `spec3gpp/*`, registry docs) |
| Unit suffixes on metric names | **PASS** |
| Label budget + feed/quality + §5.6–5.10 labels | **PASS** (`result,reason,component,amf_id,feed_a,feed_b,stage`) |
| `source ∈ {sionna, oai}` for RF | **PASS** |
| No fabricated KPIs (NaN + WARN) | **PASS** |
| Token bucket / backoff / cache / breaker | **PASS** (`adsb/ratelimit.py` + `_http.py`) |
| Parquet replay determinism | **PASS** (`test_replay_determinism`) |
| HMAC pseudonym `tail_id` | **PASS** |
| UTC epoch nanoseconds | **PASS** |
| `{model=}` / `{itype=}` braces | Mapped to `bin_type`+`bin` / `cause` (forbidden as label names) |

## MODULE 5 — Metric coverage

### 5.1–5.5

Complete in registry (see prior checklist). Includes `atg_scs_khz_value` for Doppler margin PromQL.

### 5.6 Signaling

| Metric | Registry |
|--------|----------|
| atg_sig_msg_total / atg_sig_bytes_total | ✓ |
| atg_rrc_setup_attempt/success_total | ✓ |
| atg_rrc_resume_attempt/success_total | ✓ |
| atg_ngap_initial_ctx_setup_total{result=} | ✓ |
| atg_pdu_session_estab_total{result=} | ✓ |
| atg_xnap_ho_prep_total{result=} / cancel | ✓ |
| atg_f1ap_msg_total{procedure=} | ✓ |
| atg_registration_total{result=} / atg_paging_total | ✓ |
| atg_rrc_setup_latency_ms / atg_pdu_session_setup_latency_ms | ✓ |
| atg_sig_load_* / atg_cp_load_per_amf_* / active rrc/pdu | ✓ |

Values absent until OAI signaling / log ingest feeds (fixtures light RSRP/SINR/MCS/BLER/thp + sig counters offline).

### 5.7 Aerial geometry

| Metric | Registry |
|--------|----------|
| atg_position_lat/lon/alt_* / altitude_ft | ✓ `{tail_id}` |
| atg_ground_speed_mps/kt, vertical_rate, heading, track | ✓ |
| atg_roll/pitch/turn_rate | ✓ (unset until attitude available) |
| atg_elevation_angle_deg / azimuth_deg / slant_range_km | ✓ `{tail_id,cell_id}` |
| atg_radio_horizon_* / k_factor / los_* | ✓ |
| atg_beam_pointing_error_deg / coverage_availability_ratio | ✓ |
| atg_serving_cell_info | ✓ `{tail_id,cell_id,beam_id}` |

Legacy `atg_lat_deg` / `atg_slant_range_m` dual-published for dashboards.

### 5.8 ADS-B feed quality

| Metric | Registry | Wired |
|--------|----------|-------|
| atg_adsb_aircraft_tracked / feed_up | ✓ | poll loop + circuit breaker |
| atg_adsb_msg_age_s / nic/nac/sil/version | ✓ | from AircraftState |
| crosssource RMSE / alt delta | ✓ | registered (absent until dual-feed run) |
| atg_clock_skew_ms{component=} | ✓ | registered |
| fetch/reject/ratelimit/ingest counters | ✓ | `_http.LastFetchStats` + integrity/plausibility |
| atg_adsb_fetch_latency_ms | ✓ | real client latency |

### 5.9 Validation

All `atg_val_*` gauges registered (`kpi,bin_type,bin`). Populated when validation runs; else absent.

### 5.10 Pipeline health

| Metric | Status |
|--------|--------|
| atg_pipeline_up{component=} | Set honestly: adsb/exporter/fusion/geo=1 in loop; **oai=1** when ingest sets metrics; **sionna=1** only when `ATG_SIONNA=1` and package importable (RF still NaN until finite CIR) |
| atg_replay_mode | 1 if `ATG_MODE=replay` |
| atg_sionna_rt_* / oai_parse_errors / exporter_scrape | Registered; scrape counter incremented |
| atg_fusion_cycle_ms | Observed from poll + selector |

### 5.11 Registry rules

| Rule | Status |
|------|--------|
| Only declare in `registry.py` | **PASS** |
| `assert_label_budget()` at import | **PASS** |
| `export_metric_catalog_md()` → `docs/METRIC_CATALOG.md` | **PASS** (`make catalog`) |

## MODULE 6 — Recording & alerts

| Artifact | Status |
|----------|--------|
| `atg_recording_rules.yml` groups: delta, validation, mobility, capacity, qos, geometry, signaling, feed_health | **PASS** |
| `atg_alert_rules.yml` MODULE 6 alerts + runbook_url | **PASS** (30 MODULE alerts + AtgExporterDown) |
| README runbook anchors | **PASS** (stubs) |

## MODULE 7 — PostGIS / GeoJSON / Loki

| Item | Strategy |
|------|----------|
| Timescale | **Optional**: `CREATE EXTENSION` + `create_hypertable` / retention behind `EXCEPTION` |
| Compose image | `postgis/postgis:16-3.4` (plain) — hypertables skipped gracefully |
| Tables | ground_stations, aircraft_track, serving_link, ho_event, coverage_polygon + legacy atg_* shims |
| Views | v_latest_aircraft, v_track_recent, v_serving_link_current, v_ho_events_recent, v_cell_load |
| Retention | aircraft_track/serving_link 7d, ho_event 30d, coverage keep latest; `atg_purge_stale()` |
| geo_writer | MODULE 7 tables + legacy; memory history for LineString tracks |
| geojson_api (7.3) | `/geojson/aircraft\|tracks\|serving_links\|ground_stations\|sectors\|coverage\|ho_events\|horizon` — RFC7946, ETag, max-age=2, cap 5000, no raw icao24 |
| Promtail (7.4) | Jobs `oai_gnb`, `oai_nrue`, `ttracer`, `pcap_json` under `/logs`; DEBUG dropped unless `PROMTAIL_CONFIG=promtail-config-debug.yaml` |
| pcap_decoder | tshark `-T ek` + bounded procedure/cause → `other` |

## MODULE 8 — Grafana dashboards

| UID | File | Title |
|-----|------|-------|
| atg-exec | 01_… | 01 ATG Executive Overview |
| atg-rf | 02_… | 02 ATG RF Physical Layer |
| atg-mac | 03_… | 03 ATG Link Adaptation / MAC |
| atg-thp | 04_… | 04 ATG Throughput / Capacity |
| atg-mob | 05_… | 05 ATG Mobility / Handover |
| atg-qos | 06_… | 06 ATG QoS / Service |
| atg-geo | 07_… | 07 ATG Aerial Geometry / Doppler |
| atg-val | 08_… | 08 ATG Sionna vs OAI Validation |
| atg-orbit | 09_… | **09 Live Aerial Track Map** |
| atg-sig | 10_… | 10 ATG Signaling / Control Plane |

Generator: `scripts/build_dashboards.py` + `scripts/panel_factory.py` (color contract + overrides).
Plugin strategy: **core-safe default** — Prometheus-driven Geomap markers for aircraft plus browser-side GeoJSON layers at `http://localhost:9105/geojson/*` (override with `ATG_GEOJSON_BROWSER_URL`; exporter serves CORS). Optional trackmap/plotly/echarts via `GF_INSTALL_PLUGINS` when DNS allows.

## Compose URLs

| Service | URL |
|---------|-----|
| Grafana | http://localhost:3000 (admin / atgadmin) |
| Prometheus | http://localhost:9090 |
| Exporter | http://localhost:9105 (/metrics /healthz /readyz /geojson/*); aliases :8000/:8001 |
| Loki | http://localhost:3100 |
| PostGIS | localhost:5432 |

## MODULE 9 — ADS-B ingest / fusion / replay

| Item | Status |
|------|--------|
| §9.3 frozen `AircraftState` + `to_row` / `to_parquet_dict` | **PASS** |
| OpenSky named index + `opensky_history.py` writer | **PASS** (Trino client stubbable) |
| Shared readsb parser (adsbfi / airplaneslive / readsb_local) | **PASS** |
| readsb RSSI + msg rate metrics | **PASS** |
| Rate limit / backoff / breaker / cache / ETag / fetch outcomes | **PASS** |
| Integrity + plausibility exact reasons | **PASS** |
| UKF (filterpy) + EMA fallback; raw+smoothed | **PASS** |
| Coordinated-turn attitude → airborne_antenna | **PASS** |
| Cross-check RMSE + degrade lagging feed | **PASS** |
| Clock skew gauges; aligner \|skew\|>50 ms reject | **PASS** |
| Session Parquet + manifest; replayer flags; determinism | **PASS** |
| Link selector 1 Hz + RT backpressure | **PASS** |
| DATA_SOURCES.md + `data/static/` placeholders | **PASS** |

## MODULE 10 — Runtime / tests / acceptance

| Item | Status |
|------|--------|
| Compose profiles + healthchecks + port aliases | **PASS** |
| Makefile targets (up/down/demo/report/…) | **PASS** |
| Bundled `data/replay/demo/` | **PASS** |
| Test matrix §10.3 | **PASS** (added altitude/smoother/attitude/history/rules/tr36777/…) |
| Acceptance §10.4 | See README — coverage **~80 % PASS** (`--cov-fail-under=80`) |
| OAI log ingest | **PASS** — `oai_pipeline/ingest.py` + fixtures under `tests/fixtures/oai/` / `data/logs/` |
| Sionna enable | **PASS** — `ATG_SIONNA=1` + optional `[sionna]` extra; `source=sionna` only on finite CIR |
| `tail_id` HMAC `ATG_SALT`[:8] | **PASS** |
