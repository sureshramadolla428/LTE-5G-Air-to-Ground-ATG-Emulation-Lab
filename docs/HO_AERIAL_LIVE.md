# Live Aerial Map — Authentic F1 Handover (ATG)

**Product:** Air-to-Ground only · **OAI pin:** `38dc378` · **VM:** `192.168.122.133`  
**Date:** 2026-08-05

## What you see on the map

| Layer / panel | Source | Honesty |
|---------------|--------|---------|
| HO event Points (`/geojson/ho_events`) | OAI CU log tokens → exporter → PostGIS/memory | Only when authentic HO lines exist |
| Serving-link LineStrings | Switch `gs0`↔`gs1` after HO **success** | Geometry uses scenario GS coords (LAX/BUR stand-ins) |
| `atg_ho_*_total` | Same log tokens | Prometheus counters |
| Serving-cell timeline | `atg_serving_cell_info` | Cell id updates on HO success |
| Annotations (mob / all-in-one) | `changes(atg_ho_*_total[1m])` | Lights when counters increment |

**Not claimed:** aerial A3/A5 measurement-driven HO, CHO/DAPS, or OTA ATG RF.  
**What is claimed:** lab **F1 HO** between two ground DUs (PCI0→PCI1) for an **aircraft UE** session under RFsim AWGN (3GPP F1-AP + RRC Reconfiguration path).

## How HO is triggered

```bash
# On ATG VM — preferred one-shot (restores CU+UE+DU0+DU1, triggers HO, leaves stack up)
bash ~/oai-config/path-a2g/a2g-f1-ho-minimal.sh

# Or if dual-DU already up and CU telnet :9099 listening:
printf 'ci trigger_f1_ho\n' | nc -w 3 127.0.0.1 9099
# NEVER send this string to Prometheus :9090
```

**Do not** call `ci get_single_rnti` before HO on this pin after dual-DU — it has segfaulted the CU. Use `trigger_f1_ho` only.

Success evidence in `/tmp/patha2g/cu.log`:

```text
[NR_RRC] Handover triggered for UE … towards cell 11111111/…/PCI 1
[NR_RRC] handover for UE … complete!
[NR_RRC] UE … Handover: trigger release on cell PCI 0/…
```

Post-HO data plane: `ping -I oaitun_ue1 -c 5 192.168.70.135` should succeed.

## Observability path

```
CU/DU/UE logs (/tmp/patha2g)
  → oai-log-sync / sync-oai-logs-from-vm.ps1
  → data/logs/oai_sig_live.log + gnb_cu_live.log
  → OaiLogIngestor (signaling_extractor)
  → atg_ho_* + GeoWriter.add_ho_marker + serving-link switch
  → Grafana atg-orbit / atg-all-in-one / atg-mob
```

Windows host:

```powershell
cd atg-observability
docker compose --profile oai-sync up -d oai-log-sync oai-qos-probe
# or: powershell -File tools\sync-oai-logs-from-vm.ps1
python scripts/build_dashboards.py
docker compose up -d --build exporter
```

## Map / dashboard URLs

| Board | URL |
|-------|-----|
| Live Aerial Track Map | http://localhost:3000/d/atg-orbit |
| All-in-One | http://localhost:3000/d/atg-all-in-one |
| Mobility / HO | http://localhost:3000/d/atg-mob |
| GeoJSON HO | http://localhost:9105/geojson/ho_events?minutes=60 |
| Metrics | http://localhost:9105/metrics |

## Optional continuous HO loop

```bash
# On VM — toggles F1 HO every ~90s while CU stays healthy; stop with Ctrl-C
bash ~/oai-config/path-a2g/a2g-ho-loop.sh
```

Only run when dual-DU stack is healthy and you accept brief UP blips. Authentic tokens only — no fabricated markers.

## 3GPP mechanisms (lab vs field)

| Mechanism | Lab status |
|-----------|------------|
| F1 HO (intra-gNB CU, dual DU) | **Demonstrated** via CI telnet |
| RRC Reconfiguration + Complete | Present in CU log |
| A3/A5 measurement events | Not required for this demo; not claimed |
| CHO / DAPS | Not demonstrated |
| Xn HO | Not used (single CU) |

## Sample evidence (2026-08-05 live session)

CU log:

```text
[NR_RRC] Handover triggered for UE 1/RNTI 38a6 towards cell 11111111/assoc_id 290/PCI 1
[NR_RRC] handover for UE 1/RNTI 2f0d complete!
[NR_RRC] Handover triggered for UE 1/RNTI 2f0d towards cell 12345678/assoc_id 288/PCI 0
[NR_RRC] handover for UE 1/RNTI 32f6 complete!
```

Prometheus (after ingest):

```text
sum(atg_ho_success_total) = 4
sum(atg_ho_attempt_total) = 12
```

GeoJSON excerpt (`/geojson/ho_events?minutes=60`):

```json
{"type":"Feature","properties":{"event_type":"ho_success","src_cell":"gs0","tgt_cell":"gs1","result":"success","tail_id":"oai-demo"},"geometry":{"type":"Point","coordinates":[-118.3836,34.07115]}}
```

Post-HO ping: 0% loss, RTT ~9–12 ms via `oaitun_ue1`.

## Limitations

1. RFsim AWGN ≠ OTA ATG channel; band n78 stand-in for TR 38.876 ATG.
2. `ci trigger_f1_ho` is a **signaling actuator**, not measurement-driven mobility.
3. Map GS positions are scenario stand-ins (LAX/BUR); HO markers are midpoints between them.
4. Avoid `ci get_single_rnti` after dual-DU on pin `38dc378` (CU segfault observed).
5. Do not invent HO markers without CU/UE log evidence.

## Re-run checklist

1. `bash ~/oai-config/path-a2g/a2g-f1-ho-minimal.sh` on `.133`
2. Confirm `handover for UE … complete!` in `/tmp/patha2g/cu.log` and ping OK
3. Sync logs + restart exporter on Windows host
4. Open `atg-orbit` → layer **HO events**; check `sum(atg_ho_success_total)` in Prometheus
