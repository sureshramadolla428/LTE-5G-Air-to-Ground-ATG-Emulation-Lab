# Grafana honesty — ATG / Air-to-Ground presentation

**Date:** 2026-08-04 (ATG-clean honesty + panel audit)  
**Status:** Radio path is **ATG / Air-to-Ground** (n78 AWGN, TR 38.876 ground BS ↔ aircraft UE).

## Lab honesty panel (canonical)

### Lab honesty (read once)
- **RFsim** = software Uu (not OTA). Current path: **ground BS ↔ aircraft UE**, band **n78**, **AWGN**, UE altitude in `nrue.a2g.rfsim.conf`.
- **Ping** must use `oaitun_ue1` → DN `192.168.70.135`. Healthy ATG RTT is typically **~6–15 ms**. Near-0 ms is usually host/loopback, not the PDU path.
- If Ping UP=DOWN: `bash ~/oai-config/path-a2g/patha2g-bringup-du0.sh`.
- **DL/UL Mbps:** show **measured** only when `ping_up=1` and thr>0.05; otherwise optional **capacity** estimate from MCS/PRB is **not** user traffic.
- Day-of: Path A2G bring-up · Grafana folder **ATG Lab** · example VM `192.168.122.133`


## Thresholds

| KPI | ATG expectation | Gauge / color |
|---|---|---|
| Ping RTT | **~6–15 ms** | green &lt;20 · orange ≥20 · red ≥40 |
| Ping UP | 1 when `oaitun_ue1` → DN | measured |
| RSRP/SINR | RFsim / log | not OTA |

## Out of scope on this ATG AWGN demo

Rel-18 NR-ATG RF conformance, OTA / SDR, and HAPS-as-gNB are not part of the green Path-A2G recipe. The Live Aerial Track Map is aircraft / ADS-B / ground-station geometry.

## Commands

```bash
make a2g
bash ~/grafana/start-atg-kpi-exporter.sh   # defaults to --no-rf-from-elevation
```

See also: `grafana/ATG_DASHBOARD_PANEL_AUDIT.md`.
