# Air-to-Ground (ATG) capture — shot list + testcase

Use this when filming a **short video and Grafana snaps**. Do **not** push large `.mp4` until you pick stills. Runtime is the **Ubuntu ATG VM** plus optional **Windows Docker** Grafana.

**VM (example):** `192.168.122.133`  
**PDU proof:** `ping -I oaitun_ue1 192.168.70.135` → **~6–14 ms**  
**Radio:** n78 AWGN RFsim, aircraft UE, **ground base station → air UE** (TR 38.876). Not OTA.

---

## 1. Copy the script to the VM (Windows PowerShell)

```powershell
$ip  = "192.168.122.133"
$key = "$env:USERPROFILE\.ssh\id_ed25519_ntn"
$user = "sureshramadolla"
$lab = "C:\Users\sures\OneDrive\Desktop\LTE_5g_ATG_emulation_lab"

scp -o IdentitiesOnly=yes -i $key `
  "$lab\demo\atg-capture-full-testcase.sh" `
  "${user}@${ip}:~/demo/atg-capture-full-testcase.sh"

ssh -o IdentitiesOnly=yes -i $key "${user}@${ip}" "chmod 0755 ~/demo/atg-capture-full-testcase.sh"
```

Also keep Path A2G confs on the VM (`~/oai-config/path-a2g/`).

---

## 2. Optional: Windows observability (Diona + live Sionna twin + map)

In `LTE_5g_ATG_emulation_lab\atg-observability`:

```powershell
cd C:\Users\sures\OneDrive\Desktop\LTE_5g_ATG_emulation_lab\atg-observability
# .env: ATG_SIONNA=1  INSTALL_SIONNA=1   (optional live twin)
docker compose up -d --build
```

Then:

- Grafana http://localhost:3000  (`admin` / password from `.env`)
- Metrics http://localhost:9105/metrics
- Sync logs: `tools\sync-oai-logs-from-vm.ps1` or compose profile `oai-sync`

Diona tiles are **example/csv**, not a live Diona radio.

---

## 3. One command on the VM (high data rate)

```bash
# default: TCP downlink, 4 streams, 180 s, then F1 HO
bash ~/demo/atg-capture-full-testcase.sh

# already green — skip teardown
SKIP_STOP=1 bash ~/demo/atg-capture-full-testcase.sh

# UDP “high rate” visual (RFsim, not OTA capacity)
UDP_MBPS=40 IPERF_T=180 bash ~/demo/atg-capture-full-testcase.sh

# ping + iperf only (no HO)
SKIP_HO=1 bash ~/demo/atg-capture-full-testcase.sh
```

Watch for: `OK: CN5G` → `OK: CU` → `OK: oaitun_ue1` → `OK: PING SUCCESS` → iperf pid → Diona/Sionna → link-budget print → call-flow → `ci trigger_f1_ho`.

---

## 4. What to capture (60–90 s video + stills)

| # | Shot | Where |
|---|------|--------|
| 1 | Terminal `OK:` lines + `PING SUCCESS` | SSH / VM terminal |
| 2 | `ping -I oaitun_ue1 -c 4 192.168.70.135` (~6–14 ms) | same |
| 3 | iperf climbing (`/tmp/iperf-client.log`) | same |
| 4 | **Lab Demo** | `http://192.168.122.133:3000/d/atg-full-lab` or localhost:3000 |
| 5 | **Aerial map** (air-to-ground geometry) | `/d/atg-orbit` or `/d/atg-live-topology` |
| 6 | **Super Ops** (ATG vs Diona) | `/d/atg-lab-super-ops` |
| 7 | **Sionna vs OAI / link budget** | `/d/atg-val` + RF board |
| 8 | **Call-flow / HO** | `http://192.168.122.133:8787/` and `/d/atg-sig` |
| 9 | All-in-one | `/d/atg-all-in-one` |

Save stills as:

`docs/screenshots/atg-all-in-one.png`, `atg-orbit.png`, `atg-callflow.png`, `atg-signalling.png`

Grafana: **Last 15 minutes**, refresh **5s**. Do not show ICAO24, callsigns, or `.env`.

---

## 5. Honesty caption (on-screen or voiceover)

> Air-to-Ground (ATG) 5G software emulation: OpenAirInterface RFsim, ground gNB and aircraft UE, band n78 AWGN. Ping and iperf are measured on `oaitun`. Diona is a static baseline. Sionna is a twin when enabled. Dual-DU handover here is F1 signalling (`ci trigger_f1_ho`), not measurement-report A3. Not over-the-air.

---

## 6. After filming

```bash
kill "$(cat /tmp/iperf-client.pid)" 2>/dev/null
# optional full stop:
# bash ~/demo/stop-all.sh
```

Drop PNGs into `github-atg-lab/docs/screenshots/`. **Later** we can commit and push (skip large video unless you want it).
