# Building an Honest ATG 5G Lab: OAI RFsim, ADS-B Mobility, and Grafana Observability

Air-to-ground (ATG / A2G) connectivity is simple to state and hard to instrument well: a **ground base station** serves an **aircraft UE** at cruise altitude, with long slant ranges, strong Doppler, cell handovers across a sparse ground grid, and KPIs that mix radio physics with control-plane reality. After roughly fifteen years in wireless systems, I wanted a lab that could answer operational questions without pretending to be an over-the-air flight campaign.

This post describes an ATG-focused 5G NR emulation and observability stack around OpenAirInterface (OAI) RFsim, a Prometheus/Grafana exporter, live ADS-B trajectories, PostGIS geometry, optional Sionna RT, and an Aurora-themed NOC view. The design priority was honesty: **modeled** quantities stay labeled as models; **measured** softmodem readings stay labeled as OAI; absent series stay empty rather than invented.

## Why ATG observability matters

Commercial and research interest in direct air-to-ground 5G is growing: cabin connectivity, cockpit data, and contingency links all need predictable coverage along corridors and around terminals. Relative to terrestrial urban NR, ATG changes the geometry:

- Ground stations tilt **up** toward aircraft, not down toward street level.
- Path loss and LoS are dominated by slant range, radio horizon, and fuselage mounting—not street clutter.
- Mobility is high-speed and multi-cell over tens of kilometres, so handover storytelling must be precise about *mechanism*.
- Many dashboards quietly mix simulation outputs with live counters. For engineering work, that mix has to be visible.

My goal was a **research and network-planning lab**: no real RF emission, OAI RFsim only, ADS-B for kinematics, and dashboards that cite 3GPP / ITU formulas where they apply.

## Architecture at a glance

The lab splits cleanly across two hosts:

| Layer | Where it runs | Role |
|--------|----------------|------|
| OAI CN5G + RAN (CU/DU/UE) | Ubuntu VM | Softmodem attach, PDU, F1 HO demos, multi-UE tunnels |
| Observability stack | Windows Docker Compose | Exporter, Prometheus, Grafana, Loki, PostGIS |
| Live aircraft feed | ADS-B (e.g. adsb.fi) | Tracks → geometry KPIs + map layers |
| Optional physics twin | Sionna RT (LLVM/CPU in container) | CIR → `source=sionna` RF gauges |
| Canonical models | `link_budget.py` + `spec3gpp/` | TR 36.777 PL, ITU atmospherics, A3 params |

High-level data path:

```text
ADS-B feed ──► exporter (normalize, integrity, plausibility)
                    │
OAI CU/DU/UE logs ──┼──► OAI ingest (RSRP/SINR/MCS/BLER/HO tokens)
                    │
Sionna RT (opt.) ───┼──► source=sionna gauges when CIR is finite
                    │
                    ▼
         Prometheus  +  PostGIS / GeoJSON
                    │
                    ▼
         Grafana Aurora NOC (11 provisioned dashboards)
```

GeoJSON for tracks, serving links, ground stations, sectors, horizon, and HO events is served from the exporter (`:9105/geojson/*`) with CORS so the **browser** can load map overlays. Aircraft markers can also come from Prometheus position series. Docker-internal hostnames do not resolve from a laptop browser.

Scenario radio defaults (example LA basin four-cell layout): n78 / 3.5 GHz, 30 kHz SCS, 100 MHz BW, EIRP 46 dBm, channel model `rma_av` (TR 36.777), ground stations co-located with the ADS-B catchment so LoS geometry is meaningful.

## Setup process (high level)

**1. Observability on Windows (Docker)**

```bash
cd atg-observability
cp .env.example .env
docker compose up -d --build
```

Typical local endpoints:

- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`
- Exporter metrics / health / GeoJSON: `http://localhost:9105`
- PostGIS: `localhost:5432`

Live ADS-B is the default (`ATG_MODE=live`). Replay mode reads Parquet for deterministic demos. Optional profiles cover Sionna worker and OAI log sync.

**2. Softmodems on the Ubuntu ATG VM**

```bash
bash ~/oai-config/path-a2g/patha2g-bringup-du0.sh
# or day-of with helpers:
bash ~/oai-config/day-of-green.sh
```

Healthy single-UE evidence in this lab has looked like **20/20 ping** on `oaitun_ue1` toward the DN with roughly **6–14 ms** RTT—emulation latency, not cabin Wi‑Fi marketing numbers.

**3. Wire softmodem logs into the exporter**

CU/DU/UE logs on the VM are synced into `atg-observability/data/logs/`. The exporter’s OAI ingest publishes refreshing `source=oai` gauges. Offline fixtures exist for CI; live files overwrite them when present.

**4. Optional Sionna**

```bash
# .env
INSTALL_SIONNA=1
ATG_SIONNA=1
ATG_SIONNA_VARIANT=llvm_ad_mono_polarized
docker compose up -d --build exporter
```

Sionna GPU/OptiX is **not** required. LLVM/CPU LoS paths are enough to populate twin gauges when amplitudes are finite. If Sionna is off or CIR is invalid, those series stay absent—never fabricated under the `sionna` label.

## Multi-UE: three aircraft softmodems

For capacity and per-UE dashboard filtering I run up to **three NR-UEs** against one DU.

- **Single-UE:** UE = RFsim **server**, DU = client (avoids a known `nbAnt` assert path).
- **Multi-UE (`MULTI_UE=2|3`):** DU = RFsim **server** on `:4043`, UEs = clients. Peer UEs must not point at another UE-as-server or they only see host TX.

Bring-up renames tunnels so each UE keeps a stable interface: `oaitun_ue1`, `oaitun_ue2`, `oaitun_ue3`. UE confs offset cruise geometry so the story reads as multiple aircraft, not three clones on one point.

On the observability side, dashboards expose a **`$ue_id`** template variable. Log ingest maps softmodem identity with a clear preference order: per-UE log filename → **CU-UE-ID** → RNTI table.

QoS ICMP probing targets `oaitun_ue1` by default; retainability and RTT panels stay tied to a real tunnel.

## Handovers: F1 demonstrated, A3 modeled

### Authentic lab F1 HO (OAI)

With dual DU under a single CU, F1 handover can be triggered (CI telnet `ci trigger_f1_ho` on the CU). CU logs show the familiar RRC handover sequence; post-HO ping on the UE tunnel should still reach the DN. Observability parses those tokens into attempt/success counters (`source=oai`), serving-cell updates, and a short-lived white flash on the map for **lab UEs only**.

This is **F1 / signaling-class** mobility in RFsim—not measurement-report-driven A3, not CHO/DAPS, not Xn (single CU).

### Modeled A3 for the ADS-B mobility story

Live ADS-B aircraft move across a four-cell ground grid (scenario stand-ins around LAX / BUR / LGB / SNA). A modeled A3 controller scores neighbours from Sionna RSRP when available, otherwise from the canonical link budget—never by copying single-cell OAI RSRP across cells.

| Parameter | Value |
|-----------|--------|
| Offset (Off) | **3.0 dB** |
| Hysteresis (Hys) | **1.0 dB** |
| Time-to-trigger | **320 ms** |
| Min dwell | 10 s |
| Ping-pong window | 30 s |
| Exec delay | 50 ms |

Modeled events carry `source=sionna`, `procedure=modeled_a3`, `event_origin=model`. Serving beams on the hero map are restricted to **lab UEs**. ADS-B tails appear as aircraft markers without fake green “connected” starbursts.

## Link budget and 3GPP-aligned KPIs

```text
rx_power = EIRP + G_tx(az,el,tilt) + G_rx(az,el,roll,pitch)
         − PL − gaseous − rain − scint − pol − impl − fuselage
```

| Topic | Reference / treatment |
|--------|------------------------|
| SS-RSRP / SS-SINR | TS **38.215** |
| MCS / BLER / SE | TS **38.214** / TS **28.552** |
| Peak rate ceiling | TS **38.306** |
| Timing advance | TS **38.213** |
| HO / RRC mobility | TS **38.331** (OAI F1 vs modeled A3) |
| Perf / retainability proxies | TS **28.552** / **28.554** |
| Aerial path loss | TR **36.777** |
| Atmosphere / refractivity | ITU-R **P.676** / **P.618** / **P.453** |

Exportable “current KPI readings” are ordinary Prometheus series. Empty rows mean absent series—not zeros invented for a screenshot.

## Sionna twin vs OAI readings

When enabled, LoS path amplitudes become `source=sionna` RSRP/SINR/path loss. Recording rules compute residuals such as `atg:rsrp_delta_db` against `source=oai`. Validation dashboard **08** shows RMSE/bias/Pearson-style gates.

Sample softmodem readings after log sync in this lab have included RSRP around **−43 dBm**, UL SNR mapped toward SINR near **~22 dB**, MCS 0, BLER 0 in benign RFsim AWGN—useful for wiring validation, not for claiming OTA link budgets.

## AIOps-lite and exportable readings

The All-in-One board includes a residual/anomaly strip from Prometheus recording rules: gate pass percentage, ADS-B reject ratio, and pipeline-up components. This is **AIOps-lite**—threshold and residual logic, not a trained ops agent.

## Aerial map

The Live Aerial Track Map (`atg-orbit`) is an **A2G aerial** product: aircraft, ground stations, serving geometry, HO flash. The filename token `orbit` is a Grafana path name only.

Non-goals:

- No real RF emission; RFsim / emulation only
- Not aviation-safety or ATC decision support
- Pseudonymised `tail_id` only
- No fabricated KPIs
- F1 CI triggers are signaling demos unless measurement-driven A3 is actually present
- Metric names prefer `atg_*`

n78 here is an ATG-intended band stand-in (TR 38.876 Table 5-1 context), not Rel-18 NR-ATG RF conformance.

## Closing

What I ended up with is less a demo wallboard and more a **discipline**: every series has a provenance, every HO has a mechanism, every map layer has a rule about what it is allowed to imply. OAI CN5G + RAN RFsim gives a real control/user-plane session. ADS-B gives real aircraft kinematics. Link budget and optional Sionna RT give a physics twin. Prometheus, Loki, PostGIS, and Grafana glue them into something I would show another radio engineer without a disclaimer slide full of footnotes—because the footnotes are already on the panels.

If you are building ATG planning tools, corridor studies, or softmodem labs, the useful part may not be any single dashboard UID. It is the contract: **label the source, cite the spec, leave NODATA empty**.

*Lab stack: `atg-observability` · OAI Path A2G · Grafana UIDs `atg-*` · no OTA RF.*
