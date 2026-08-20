# HO / QoS Live Observability Report

**Date:** 2026-08-05 · **Product:** ATG A2G only · **Host:** Windows + OAI VM `192.168.122.133`

## Summary

Live Mobility/Handover and QoS dashboards now consume **real OAI-derived events** and **ICMP data-plane measurements**. Authentic HO events are **not available** in this single-cell Path-A session and were **not fabricated**. Panel audit: **BROKEN = 0** for `atg-mob` and `atg-qos`.

## Data sources

| Stream | Path | Mechanism |
|--------|------|-----------|
| DU RF / MAC / in-sync | `/tmp/patha2g/du0.log` → `data/logs/gnb_du0_live.log` | `oai-log-sync` / `sync-oai-logs-from-vm.ps1` |
| UE MAC / SIB1 | `/tmp/patha2g/ue.log` → `nrue_ue_live.log` + `oai_sig_live.log` | same sync (expanded patterns) |
| Signaling tokens | DU/UE/CU grep → `oai_sig_live.log` | HO/RRC/NGAP/F1/SIB1 patterns |
| AMF registration | `docker logs oai-amf` → `amf_ue_live.log` | 5GMM-REGISTERED rows |
| QoS ICMP | `ping -I oaitun_ue1 192.168.70.135` → `data/qos/latest.json` | `oai-qos-probe` compose + `tools/oai_qos_probe.py` |
| Exporter | `:9105/metrics` | `OaiLogIngestor` + `QosProbeIngestor` |

**Jitter formula (documented):** mean absolute successive RTT difference, RFC 3550-style, from measured ICMP samples — not SMF jitter.

**five_qi label:** `"none"` on ICMP metrics — 5QI is not read from OAI/SMF config in this lab.

## Sample live readings (verified)

| Metric | Sample | Notes |
|--------|--------|-------|
| `atg_rsrp_dbm{source="oai"}` | **−43 dBm** | DU `average RSRP` |
| `atg:latency_p50_ms` | **~8.5–11.6 ms** | ICMP via oaitun_ue1 |
| `atg:latency_p95_ms` | **~18–20 ms** | recording rule `sum by(le)` |
| `atg:latency_p99_ms` | **~40 ms** | |
| `atg:jitter_p95_ms` | **~10 ms** | successive-RTT jitter hist |
| `atg_packet_loss_ratio{five_qi="none"}` | **0** | ping 0% loss |
| `atg_retainability_ratio{five_qi="none"}` | **1.0** | recv/sent (UP reachability proxy) |
| `atg_active_rrc_connections` | **1** | DU in-sync |
| `atg_active_pdu_sessions{five_qi="none"}` | **1** | in-sync + MAC |
| `atg_time_of_stay_s{source="oai"}` | **~1515 s** | continuous in-sync dwell |
| `atg_thp_dl_bps{source="oai"}` | **~394 bps** | MAC TX byte delta (idle link) |
| `atg_sig_msg_total` | **sib1=1, Registration=1** | parsed authentic tokens |
| `atg_latency_ms_count` | **530+** | histogram observations growing |
| `sum(atg_ho_attempt_total)` | **EMPTY** | no authentic HO — honest |

## Authentic HO availability

**None in current session.** Evidence:

- CU log empty; DU log has zero HO/RRC/NGAP/F1AP strings (MAC/RF only).
- UE log: `[NR_RRC] SIB1 decoded` only (setup predated rotating log).
- Single-cell Path-A ATG — no neighbour / HO trigger expected.
- Dashboard `atg-mob` banner: *“No handover events in current single-cell session.”*

Path-B dual-DU was **not** started (would disrupt stable ATG session).

## Dashboard panel status

| Dashboard | LIVE | NODATA (honest) | BROKEN | STATIC |
|-----------|------|-----------------|--------|--------|
| [atg-mob](http://localhost:3000/d/atg-mob) | **8** | **12** | **0** | 1 |
| [atg-qos](http://localhost:3000/d/atg-qos) | **7** | **5** | **0** | 1 |

NODATA panels are intentional: HO/CHO/DAPS/ping-pong/GBR/PDB/DRB/SLO burn without authentic feeds. Each panel description states formula/source/spec and measured vs unavailable.

Also regenerated: [atg-all-in-one](http://localhost:3000/d/atg-all-in-one) (11th board).

## Tests

- Focused: `tests/test_ho_qos_live.py`, `test_oai_pipeline.py`, `test_oai_ingest.py`, `test_dashboard_json.py` — pass
- Full suite: **pytest 100% pass** (warnings only: FastAPI `on_event` deprecation)

## URLs

| Service | URL |
|---------|-----|
| Grafana mobility | http://localhost:3000/d/atg-mob |
| Grafana QoS | http://localhost:3000/d/atg-qos |
| Grafana all-in-one | http://localhost:3000/d/atg-all-in-one |
| Prometheus | http://localhost:9090 |
| Exporter | http://localhost:9105/metrics |

## Keep-alive

```powershell
docker compose --profile oai-sync up -d oai-log-sync oai-qos-probe
# or Windows host probe:
python tools/oai_qos_probe.py
```

## Limitations

1. No authentic HO/RLF/CHO/DAPS until multi-cell or log tokens appear.
2. GBR/PDB/DRB compliance absent — no 5QI from SMF.
3. ICMP measures UP path RTT, not 5QI PDB.
4. iperf skipped — no listener on :5201.
5. CU log empty — F1/NGAP setup history not in softmodem files (AMF table used for registration presence).
