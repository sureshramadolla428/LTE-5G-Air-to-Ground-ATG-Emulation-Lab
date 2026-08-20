# Setup — ATG lab

High-level bring-up. Edit the example VM IP and SSH identity to match your hosts.

**Example Ubuntu guest IP:** `192.168.122.133`  
**SSH key (placeholder):** `~/.ssh/id_ed25519` or set `ATG_SSH_KEY` / `OAI_SSH_KEY`  
**OAI:** clone and build from upstream; this repo ships Path A2G confs and scripts only.

---

## 1. Observability on Windows (Docker)

```powershell
cd atg-observability
copy .env.example .env
# Edit .env: OAI_HOST, OAI_USER, OAI_SSH_KEY if you will sync logs
docker compose up -d --build
```

Local URLs:

| Service | URL |
|---------|-----|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Exporter | http://localhost:9105 |
| Loki | http://localhost:3100 |
| PostGIS | localhost:5432 |

Root README gallery: drop Grafana PNGs in [`screenshots/`](screenshots/README.md) (`atg-all-in-one.png`, `atg-orbit.png`).

Live ADS-B is default (`ATG_MODE=live`). Primary feed: adsb.fi (`configs/adsb_sources.yaml`). OpenSky needs `OPENSKY_USER` / `OPENSKY_PASS` in `.env` — never commit those values.

Optional Sionna (LLVM/CPU; GPU/OptiX not required):

```text
INSTALL_SIONNA=1
ATG_SIONNA=1
ATG_SIONNA_VARIANT=llvm_ad_mono_polarized
```

```powershell
docker compose up -d --build exporter
```

---

## 2. Copy Path A2G files to the Ubuntu VM

hgfs / OneDrive shares are often incomplete. Prefer `scp`.

```powershell
$ip  = "192.168.122.133"   # edit
$key = "$env:USERPROFILE\.ssh\id_ed25519"   # or $env:ATG_SSH_KEY
$user = "YOUR_VM_USER"

scp -o IdentitiesOnly=yes -i $key -r `
  oai-config\path-a2g `
  "${user}@${ip}:~/oai-config/"

scp -o IdentitiesOnly=yes -i $key `
  oai-config\day-of-green.sh `
  "${user}@${ip}:~/oai-config/day-of-green.sh"

ssh -o IdentitiesOnly=yes -i $key "${user}@${ip}"
```

On the VM:

```bash
chmod 0755 ~/oai-config/path-a2g/*.sh ~/oai-config/day-of-green.sh 2>/dev/null || true
```

CN5G + RAN binaries come from your OAI install (typically `~/openairinterface5g` and the CN5G compose tree). Path A2G uses stock OAI band-78 CU/DU recipes plus the aircraft UE conf in `path-a2g/`.

---

## 3. Softmodem bring-up (Ubuntu)

Single UE (UE = RFsim **server**, DU = client):

```bash
bash ~/oai-config/path-a2g/patha2g-bringup-du0.sh
```

Day-of with monitoring helpers on the VM (if you keep a local `~/monitoring` tree):

```bash
bash ~/oai-config/day-of-green.sh
```

Multi-UE (DU = RFsim **server** on `:4043`, UEs = clients):

```bash
MULTI_UE=3 bash ~/oai-config/path-a2g/patha2g-bringup-du0.sh
```

Peer UEs must not point at another UE-as-server.

Evidence target:

```bash
ping -I oaitun_ue1 -c 20 192.168.70.135
```

Expect ~6–14 ms RTT when the PDU path is up. Collect a pack:

```bash
BRINGUP=1 bash ~/oai-config/path-a2g/collect-evidence.sh
```

F1 HO (dual-DU healthy, CU telnet `:9099`):

```bash
bash ~/oai-config/path-a2g/a2g-f1-ho-minimal.sh
# or:
printf 'ci trigger_f1_ho\n' | nc -w 3 127.0.0.1 9099
```

That is **F1 / signalling-class** mobility in RFsim, not measurement-report A3.

---

## 4. Wire logs into the exporter

CU/DU/UE logs on the VM typically land under `/tmp/patha2g/`. Sync into `atg-observability/data/logs/` on Windows:

```powershell
# leave running
powershell -ExecutionPolicy Bypass -File atg-observability\tools\sync-oai-logs-from-vm.ps1
```

Or:

```powershell
cd atg-observability
docker compose --profile oai-sync up -d oai-log-sync
```

Set in `.env`:

```text
OAI_HOST=192.168.122.133
OAI_USER=YOUR_VM_USER
OAI_SSH_KEY=C:/Users/YOU/.ssh/id_ed25519
```

Offline pytest fixtures seed gauges only when `data/logs/` has no live `*.log` files.

---

## 5. Local tests (no external APIs)

```powershell
cd atg-observability
pip install -r requirements.txt
$env:PYTHONPATH = "src"
pytest
```

---

## Non-goals

- No real RF emission; RFsim / emulation only
- Not aviation-safety or ATC decision support
- Do not publish 3GPP/ETSI specification PDFs
- Do not commit `.env` with real OpenSky or SSH material
