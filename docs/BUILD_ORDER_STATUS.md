# BUILD_ORDER_STATUS — §10.5 + MODULE 9–10

Generated against `atg-observability/` after **coverage / OAI wiring / Sionna enable** pass.
No git commit.

| Step | Scope | Result | Notes |
|------|--------|--------|-------|
| 1 | `common/` units, geodesy, geometry, time_sync, **pseudonym** (`ATG_SALT`[:8]), link_budget | **PASS** | |
| 2 | `spec3gpp/` + tr36777 path_loss_av | **PASS** | |
| 3 | `exporter/registry.py` + local RSSI gauges | **PASS** | |
| 4 | `adsb/` §9.3–9.11 (frozen AircraftState, sources, UKF/EMA, attitude, history, record/replay) | **PASS** | |
| 5 | `db/init` + fusion geo | **PASS** | |
| 6–7 | sionna / oai pipelines | **PASS** | OAI ingest wired; Sionna optional RT (NaN unless real CIR) |
| 8 | `link_selector` 1 Hz steps + RT backpressure | **PASS** | `run_oai` / `run_sionna_rt` callbacks |
| 9 | validation aligner / report | **PASS** | |
| 10 | prometheus rules + alertmanager profile | **PASS** | |
| 11 | dashboards | **PASS** | |
| 12 | docker-compose + Makefile + demo + DATA_SOURCES | **PASS** | |
| 10.6 | Pydantic configs, structlog/JSON logging, ruff/black/mypy-strict(common+validation) | **PASS** | |
| 10.x | Coverage ≥ 80 %, OAI fixtures, Sionna enable path | **PASS** | see Pytest |

## Pytest

- Full suite green (`pytest -q` / `make test`).
- Coverage **~80 %** (`--cov-fail-under=80` in Makefile).
- Thin remainders (honest): live ADS-B source network paths, PostGIS happy-path SQL, full `_poll_loop` live-mode branch, UKF filterpy path, ITU edge cases.

## Compose

| Check | Status |
|-------|--------|
| Ports | 9105 current; 8000/8001 aliases |
| Profiles | `sionna`, `oai`, `alerts`, `fusion` |
| OAI logs | `./data/logs` via `./data` mount; `ATG_OAI_LOG_DIR` |
| `make demo` | Bundled `data/replay/demo/` + OAI fixtures seeded when logs empty |

## Remaining stubs

| Area | Status |
|------|--------|
| Live Trino OpenSky history | Interface + stub writer; needs credentials |
| filterpy UKF | Preferred when installed; EMA fallback |
| Sionna RT absolute calibration | NaN + WARN until real Paths / RSRP calibrated |
| Split atg-geojson process | Same app dual-port until cutover |
| Coverage ≥ 80 % | **PASS** (~80 %); thin modules listed above |
| mypy --strict beyond common/validation | Gradual |

## Product rules

- A2G only: ground BS ↔ aircraft UE in dashboards.
- No fabricated RF KPIs (`source=sionna` only when CIR finite).
- Position = values; geospatial history → PostGIS; signaling text → Loki.
- `tail_id = HMAC-SHA256(icao24, ATG_SALT)[:8]`; raw mapping gitignored.
