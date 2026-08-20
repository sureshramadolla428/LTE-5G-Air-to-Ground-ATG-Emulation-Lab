# Sionna RT + Live OAI Wire — Lab Status

**Date:** 2026-08-05 · **Product:** A2G only · **Host:** Windows Docker Desktop + ATG VM `192.168.122.133`

## Sionna

| Item | Status |
|------|--------|
| Package | **`sionna-rt` installed** in exporter image when `INSTALL_SIONNA=1` |
| Backend | **LLVM/CPU** (`llvm_ad_mono_polarized`) — OptiX/`libnvoptix` fails in Docker Desktop Linux VMs even with RTX 5070 passthrough |
| GPU | Host GPU visible via `nvidia-smi` in containers; **not required** for LoS CIR |
| Scene | Minimal empty Mitsuba scene + TX at GS + RX at live ADS-B aircraft (ENU) |
| CIR → KPI | `PathSolver(max_depth=0)` LoS amplitudes → `path_loss_db` / `path_gain_db` → calibrated RSRP/SINR via canonical link budget + scenario EIRP |
| Fabrication | **None** — gauges with `source=sionna` only when Paths amplitudes are finite |
| Verified sample | `atg_rsrp_dbm{source="sionna"}` ≈ **−100 dBm**, `atg_path_loss_db` ≈ **146 dB**, `atg_pipeline_up{sionna}=1`, RT runs success ≥49 |

### Enable

```bash
# .env
INSTALL_SIONNA=1
ATG_SIONNA=1

docker compose up -d --build exporter
```

### Verify

```text
curl -s http://localhost:9105/metrics | findstr /C:"source=\"sionna\""
# Expect finite atg_path_loss_db / atg_rsrp_dbm / atg_pipeline_up{component="sionna"} 1
```

Prometheus: http://localhost:9090/graph?g0.expr=atg_rsrp_dbm%7Bsource%3D%22sionna%22%7D

Grafana validation board: http://localhost:3000/d/atg-val

### Probe evidence (pre-wire)

Docker probe with LLVM variant returned finite LoS field amplitude (~6.1e-7 at 5 km / 10 km ENU, 3.5 GHz) → path gain ≈ −124 dB, consistent with FSPL — real RT, not a stub.

---

## Live OAI softmodem → observability

| Item | Status |
|------|--------|
| VM | `192.168.122.133` (example; set `OAI_USER` / `OAI_SSH_KEY` in `.env`) |
| Softmodems | **Up** — CU + DU0 (band78 rfsim) + NR-UE (`~/oai-config/path-a2g/`) |
| Logs | `/tmp/patha2g/du0.log` (growing), `ue.log`, empty `cu.log` |
| Sync | `tools/sync-oai-logs-from-vm.ps1` **or** compose profile `oai-sync` (`oai-log-sync` sidecar) |
| Parser | Extended for `average RSRP -43`, `BLER … MCS (0) N`, `SNR x.x` → `source=oai` |
| Fixtures | Still present for offline; live `gnb_du0_live.log` / `nrue_ue_live.log` overwrite gauges |

### Keep sync running

```powershell
# Preferred on Windows host (this lab):
powershell -ExecutionPolicy Bypass -File tools\sync-oai-logs-from-vm.ps1

# Or Docker sidecar:
docker compose --profile oai-sync up -d oai-log-sync
```

### Sample live values (from VM softmodem / :9300 at wire time)

| Field | Sample |
|-------|--------|
| RSRP | **-43 dBm** (`average RSRP -43`) — also on Windows exporter `source=oai` |
| SNR (→ SINR) | **~21.9 dB** on exporter (UL SNR from DU stats) |
| MCS UL/DL | **0** |
| BLER | **0.0** |
| PH / PCMAX | 48 dB / 20 dBm |
| RTT (VM :9300 exporter) | ~8.9 ms |

Windows exporter metrics (after sync + ingest):

```text
curl -s http://localhost:9105/metrics | findstr /C:"source=\"oai\"" /C:"atg_rsrp_dbm"
```

Prometheus: http://localhost:9090/graph?g0.expr=atg_rsrp_dbm%7Bsource%3D%22oai%22%7D

### URLs

| What | URL |
|------|-----|
| Exporter metrics | http://localhost:9105/metrics |
| Grafana | http://localhost:3000 (`admin` / `atgadmin`) |
| RF board | http://localhost:3000/d/atg-rf |
| MAC board | http://localhost:3000/d/atg-mac |
| Sionna vs OAI | http://localhost:3000/d/atg-val |
| Prometheus targets | http://localhost:9090/targets |

---

## Notes / gaps

- **OptiX GPU RT** not usable in this Docker Desktop Linux VM (`Could not initialize OptiX`). LLVM path is the supported lab path.
- CU log is empty on the current A2G bring-up; DU0 + UE carry the KPIs.
- Keep this wire on the ATG lab VM only.
- No fabricated `source=sionna` numbers if `INSTALL_SIONNA=0` or import/RT fails — pipeline stays at `atg_pipeline_up{component="sionna"} 0`.
