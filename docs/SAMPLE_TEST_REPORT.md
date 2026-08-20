# SAMPLE_TEST_REPORT — ATG observability sample test case

**When:** 2026-08-06 · **Product:** A2G / ATG only · **Host:** Windows Docker Desktop  
**Stack:** Grafana `:3000` · Exporter `:9105` · Prometheus `:9090` · OAI VM `.133` (log sync)  
**Verdict:** **PASS** (critical path healthy; honest NODATA where feeds absent)

---

## Executive verdict

| Area | Result |
|------|--------|
| Stack health | **PASS** — 8 compose services healthy; Prom targets up |
| ADS-B live | **PASS** — ~42–53 aircraft; feed_up=1; GeoJSON refreshing |
| OAI sync / KPIs | **PASS** — RSRP −43 dBm, SINR 22.5 dB, PDU=1, RRC/HO/NGAP counters live |
| Live call signalling | **PASS** — `/callflow` ladder lit from authentic OAI events (10 stages seen) |
| Sionna offline study → ATG | **PASS** — `atg_sionna_study_*` loaded from rebranded artefacts |
| Live Sionna RT twin | **EXPECTED-GAP** — `atg_pipeline_up{component="sionna"}=0` (ATG_SIONNA=0) |
| Critical all-in-one blanks | See table — none critical fabricated; blanks are honest |

`scripts/live_test.py`: **PASS=15 · FAIL=0 · EXPECTED-GAP=1**

---

## Critical tiles / Prometheus (all-in-one)

| Tile / metric | Verdict | Value |
|---|---|---|
| Aircraft count | OK | ~42–45 |
| ADS-B feed up | OK | 1 |
| Position series | OK | ~42 |
| OAI RSRP | OK | −43 dBm |
| OAI SINR | OK | 22.5 dB |
| Active PDU sessions | OK | 1 |
| RRC setup success | OK | 2 |
| HO attempts (oai) | OK | ≥12 |
| NGAP Initial Context | OK | 3 |
| Pipeline oai / adsb / exporter | OK | 1 |
| Sionna study loaded | OK | 1 |
| Sionna study pred RTT | OK | ~11.39 ms |
| Live twin Sionna | OK (down) | 0 — honest |
| Validation gate pass % | **BLANK** | no paired validation run |
| F1AP msg counter | **BLANK** | not exported in this scrape |
| Thp DL / Thp UL tiles | **n/a** | no current OAI thp sample in strip (MAC may be idle) |
| HO fail tile | **n/a** | counter never incremented (not fabricated as 0) |
| Acc % / gate | **need val** | validation pipeline not run |

**Nothing critical is falsely blank** (ADS-B, OAI RF, attach/session, HO attempts, signalling ladder all populated). Remaining blanks are documented feed gaps.

---

## Live call signalling

| Item | Detail |
|------|--------|
| Full-screen | http://localhost:9105/callflow |
| JSON API | http://localhost:9105/api/signalling |
| All-in-one | http://localhost:3000/d/atg-all-in-one — gold **Signalling** row · iframe to `/callflow` |
| Live Aerial Track Map (optional) | http://localhost:3000/d/atg-orbit — signalling strip iframe |
| Model | Adapted from 5G SA UE→Core ladder HTML; ATG wording (aircraft UE ↔ ground gNB); signalling only |
| Live wire | OAI ingest `on_sig_event` → ring buffer; stages advance on authentic tokens only |
| Sample state at test | Attach **active** 3/4 · Registration **complete** · PDU **complete** · HO **active** 3/4 · F1 Initial UL still **waiting** (honest) |

Screenshot: `sample_callflow.png`

---

## Sionna offline real-run (ATG study)

| Source | Notes |
|--------|------------|
| Artefacts | `data/sionna_real_run_atg/` (`sionna_predictions_atg.csv`, `predicted_vs_measured_atg.csv`, phase3 MCS/BLER sweeps, README_ATG.md) |
| Metrics | `atg_sionna_study_*{campaign="offline_real_run"}` — pred RTT/SNR/BLER, lab RTT, ΔRTT, elev, Doppler, rows, dry_run=0, loaded=1 |
| Dashboard | All-in-one **Sionna offline real-run (ATG study)** tiles under Sionna vs Real |
| Honesty | **Not** live RT twin · **Not** OTA · BLER = research toy curve |

---

## Screenshots

| File | Content |
|------|---------|
| `sample_callflow.png` | Live ladder with cinematic phase chips + message rows |
| `sample_allinone_top.png` | All-in-one health strip + aerial map |
| `sample_allinone_signalling.png` | All-in-one (signalling iframe region when provisioned) |
| `sample_orbit.png` | Live Aerial Track Map board |

---

## Tests touched

```text
pytest tests/test_callflow_sionna_study.py tests/test_oai_ingest.py  → 10 passed
```

---

## Remaining honest gaps

1. **Live Sionna RT** off (`ATG_SIONNA=0` / package not in image) — twin tiles DOWN / NODATA  
2. **Validation gates** (`atg:gate_pass_pct`) — no paired Sionna↔OAI validation run  
3. **F1AP Initial UL** stage waiting — no authentic F1AP counter/token in this scrape  
4. **Thp DL/UL strip n/a** when softmodem MAC bytes idle  
5. **HO fail** series absent until a fail token is parsed  

Stack left **running**. No git commit. `.132` untouched.
