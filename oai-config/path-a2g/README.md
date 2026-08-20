# Path A2G — Air-to-Ground / ATG RFsim recipe

**Status (2026-08-04): VERIFIED** — attach + PDU + ping **20/20 @ ~6–14 ms** RTT  
Evidence: `~/a2g-evidence/20260804_201942` on the ATG lab VM (`192.168.122.133`).

## Topology (TR 38.876)

Ground ATG-style gNB ↔ **aircraft UE** (not HAPS-as-BS).

| Piece | What we run |
|-------|-------------|
| CU / DU | Stock OAI `GENERIC-NR-5GC` **band 78** confs (same as Path B) |
| UE | `nrue.a2g.rfsim.conf` — cruise altitude ~10 km AGL, AWGN |
| RFsim roles | **UE = server**, **DU = client** (avoids `nbAnt` assert) |
| Channel | AWGN |
| Band | **n78** (TR 38.876 Table 5-1) |

## Files

| File | Role |
|------|------|
| `patha2g-bringup-du0.sh` | Bring-up |
| `nrue.a2g.rfsim.conf` | ATG aircraft UE |
| `collect-evidence.sh` | Evidence pack (`BRINGUP=1` optional) |
| `gnb-*.conf` | Optional custom CU/DU (bring-up prefers stock OAI band78) |

## Run

```bash
bash ~/oai-config/path-a2g/patha2g-bringup-du0.sh
BRINGUP=1 bash ~/oai-config/path-a2g/collect-evidence.sh
```

Day-of with monitoring: `bash ~/oai-config/day-of-green.sh`  
Setup cheat sheet: [`A2G_SETUP.md`](../../docs/A2G_SETUP.md) · [`ATG_SETUP.md`](../../ATG_SETUP.md)

## Honesty

RFsim ≠ OTA ATG. Not Rel-18 NR_ATG RF conformance. Grafana UIDs are lab names — see `../../docs/A2G_DASHBOARD_HONESTY.md`.
