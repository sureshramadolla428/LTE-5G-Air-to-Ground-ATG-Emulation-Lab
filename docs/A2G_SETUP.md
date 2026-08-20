# ATG / A2G lab — setup & day-of commands

**Primary path:** Air-to-Ground / ATG (TR 38.876 topology: ground BS ↔ aircraft UE)  
**Radio:** OAI n78 RFsim AWGN · UE = RFsim server · DU = client (Path B recipe) · aircraft altitude in `nrue.a2g.rfsim.conf`  
**ATG lab VM IP:** `192.168.122.133`  
**SSH key:** `C:\Users\sures\.ssh\id_ed25519_ntn`  
**Alias stub:** [`ATG_SETUP.md`](ATG_SETUP.md) → this file

How this guest was cloned/set up: [`docs/A2G_SECOND_VM_SETUP.md`](docs/A2G_SECOND_VM_SETUP.md).  
Other guests on the host (e.g. `192.168.122.132`) are unrelated — do not scp or run ATG bring-up there by mistake.

## One-time: push ATG files to the lab VM (Windows PowerShell)

hgfs often cannot see OneDrive trees — use scp:

```powershell
scp -o IdentitiesOnly=yes -i $env:USERPROFILE\.ssh\id_ed25519_ntn -r `
  C:\Users\sures\oai-a2g-xfer\* `
  sureshramadolla@192.168.122.133:~/oai-a2g-xfer/

ssh -o IdentitiesOnly=yes -i $env:USERPROFILE\.ssh\id_ed25519_ntn sureshramadolla@192.168.122.133
```
On the VM:

```bash
mkdir -p ~/oai-config/path-a2g
cp -a ~/oai-a2g-xfer/path-a2g/* ~/oai-config/path-a2g/
cp -f ~/oai-a2g-xfer/day-of-green.sh ~/oai-config/day-of-green.sh 2>/dev/null || true
chmod 0755 ~/oai-config/path-a2g/*.sh ~/oai-config/day-of-green.sh 2>/dev/null || true
```

## Day-of bring-up

```bash
# Radio only
bash ~/oai-config/path-a2g/patha2g-bringup-du0.sh

# Radio + monitoring helpers
bash ~/oai-config/day-of-green.sh
# or from LAB_ROOT if Makefile visible: make a2g   /   make day-of-green
```

## Evidence pack

```bash
BRINGUP=1 bash ~/oai-config/path-a2g/collect-evidence.sh
# → ~/a2g-evidence/<timestamp>/
```

Verified example: **20/20 ping**, ~**6–14 ms** RTT  
(`~/a2g-evidence/20260804_201942`).

## Make targets (on VM, from lab root if hgfs/Makefile available)

| Target | Meaning |
|--------|---------|
| `make a2g` / `make path-a2g` | ATG bring-up (primary) |
| `make day-of-green` | ATG + monitoring |
| `make path-b` / `path-b-ho` | Terrestrial n78 F1 HO (still valid) |
| `make monitoring-up` | Durable ~/monitoring compose + KPI |
| `make kpi-exporter` | Start `atg_kpi_exporter.py` on :9300 |

## Grafana (Windows browser → `.133`)

| Dashboard | URL |
|-----------|-----|
| Lab Demo | http://192.168.122.133:3000/d/atg-full-lab |
| Ops / ATG vs Diona | http://192.168.122.133:3000/d/atg-lab-super-ops |
| Live Topology | http://192.168.122.133:3000/d/atg-live-topology |

Folder **ATG Lab**. Dashboard files/UIDs use `atg-*`.

## Honesty

- RFsim ≠ OTA ATG flight campaign  
- n78 is an ATG-intended band (TR 38.876 Table 5-1), lab stand-in only  
- Dashboard files/UIDs are `atg-*` — see [`A2G_DASHBOARD_HONESTY.md`](A2G_DASHBOARD_HONESTY.md)  
- Do not publish `docs/3gpp-specifications/**` PDFs/DOC to public GitHub  

See: `oai-config/path-a2g/README.md`
