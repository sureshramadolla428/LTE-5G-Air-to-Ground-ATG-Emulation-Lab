#!/usr/bin/env bash
# =============================================================================
# atg-capture-full-testcase.sh — Air-to-Ground (ATG) capture run
# =============================================================================
# One script on the Ubuntu ATG VM to light the stack for a short video + snaps:
#   1) Path A2G OAI (n78 AWGN, aircraft UE, oaitun ping)
#   2) High-rate iperf over the PDU tunnel (background, so you can film)
#   3) Diona baseline (static example CSV — not live Diona RF)
#   4) Sionna ATG artefact / optional live write
#   5) Link-budget print (FSPL / TR 36.777 class numbers for n78 + ~10 km)
#   6) Call-flow ladder :8787
#   7) Dual-DU F1 HO (signalling-class ci trigger_f1_ho — not A3)
#
#   bash ~/demo/atg-capture-full-testcase.sh
#   SKIP_STOP=1 SKIP_HO=1 bash ~/demo/atg-capture-full-testcase.sh
#
# Env:
#   DN=192.168.70.135   IPERF_T=180   PARALLEL=4   UDP_MBPS=   (set e.g. 40 for UDP)
#   SKIP_STOP=1  SKIP_HO=1  SKIP_SIONNA=1  SKIP_DIONA=1  SKIP_CALLFLOW=1
#   VM_IP=192.168.122.133
#
# Honesty: RFsim software air, not OTA ATG. Diona = example baseline.
#          F1 HO is CU CI, not measurement-report A3.
# =============================================================================
set +e
set -u

DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_CANDIDATES=(
  "$HOME/oai-config"
  "$HOME/LTE_5g_ATG_emulation_lab"
  "/mnt/hgfs/LTE_5g_ATG_emulation_lab"
)
LAB_ROOT="${LAB_ROOT:-}"
if [[ -z "$LAB_ROOT" ]]; then
  for c in "${LAB_CANDIDATES[@]}"; do
    if [[ -f "$c/oai-config/path-a2g/patha2g-bringup-du0.sh" ]]; then
      LAB_ROOT="$c"
      break
    fi
    if [[ -f "$c/path-a2g/patha2g-bringup-du0.sh" ]]; then
      LAB_ROOT="$(cd "$c/.." && pwd)"
      break
    fi
  done
fi
[[ -n "${LAB_ROOT:-}" ]] || LAB_ROOT="$(cd "$DEMO_DIR/.." && pwd)"

DN="${DN:-192.168.70.135}"
IPERF_T="${IPERF_T:-180}"
PARALLEL="${PARALLEL:-4}"
UDP_MBPS="${UDP_MBPS:-}"
DN_CTR="${DN_CTR:-oai-ext-dn}"
MON_HOME="${MON_HOME:-$HOME/monitoring}"
TXT="$MON_HOME/textfile"
LOG="${LOG:-/tmp/patha2g}"
PA="${PA:-$HOME/oai-config/path-a2g}"
BRINGUP="$PA/patha2g-bringup-du0.sh"
[[ -s "$BRINGUP" ]] || BRINGUP="$LAB_ROOT/oai-config/path-a2g/patha2g-bringup-du0.sh"
HO_ADD="$PA/a2g-du1-f1-ho.sh"
[[ -s "$HO_ADD" ]] || HO_ADD="$LAB_ROOT/oai-config/path-a2g/a2g-du1-f1-ho.sh"
STOP_ALL="${STOP_ALL:-$DEMO_DIR/stop-all.sh}"
[[ -f "$STOP_ALL" ]] || STOP_ALL="$HOME/demo/stop-all.sh"
ENSURE_MON="${ENSURE_MON:-$MON_HOME/ensure-monitoring-up.sh}"
DIONA_PY="${DIONA_PY:-$MON_HOME/diona_baseline_exporter.py}"
[[ -f "$DIONA_PY" ]] || DIONA_PY="$LAB_ROOT/monitoring/diona_baseline_exporter.py"
DIONA_CSV="${DIONA_CSV:-$MON_HOME/data/diona_baseline.example.csv}"
[[ -f "$DIONA_CSV" ]] || DIONA_CSV="$LAB_ROOT/monitoring/data/diona_baseline.example.csv"
[[ -f "$DIONA_CSV" ]] || DIONA_CSV="$LAB_ROOT/atg-observability/data/diona_baseline.example.csv"
SIONNA_PROM_CANDIDATES=(
  "$LAB_ROOT/ATG_Sionna_Real_Run/sionna_atg.prom"
  "$LAB_ROOT/atg-observability/data/sionna_real_run_atg/sionna_atg.prom"
  "$HOME/sionna-ntn-study/scripts/write_grafana_textfile.py"
)
CALLFLOW="${CALLFLOW:-$LAB_ROOT/tools/callflow/serve_callflow.py}"
IPERF_PROM="${IPERF_PROM:-$LAB_ROOT/monitoring/iperf_to_prom.py}"

banner(){ echo; echo "==================== $* ===================="; }
ok(){ echo "OK: $*"; }
warn(){ echo "WARN: $*" >&2; }

mkdir -p "$TXT" "$LOG" "$MON_HOME"

banner "0  AIR-TO-GROUND (ATG) CAPTURE TESTCASE"
echo "  LAB_ROOT=$LAB_ROOT"
echo "  DN=$DN  IPERF_T=${IPERF_T}s  PARALLEL=$PARALLEL  UDP_MBPS=${UDP_MBPS:-tcp}"
echo "  Honesty: n78 AWGN RFsim · aircraft UE · not OTA · not SAT_LEO"

# --- 1 stop ------------------------------------------------------------------
if [[ "${SKIP_STOP:-0}" != "1" ]]; then
  banner "1  STOP stale RAN / iperf"
  if [[ -f "$STOP_ALL" ]]; then
    STOP_RAN=1 STOP_CORE=0 bash "$STOP_ALL" || true
  fi
  sudo pkill -9 -x nr-softmodem 2>/dev/null || true
  sudo pkill -9 -x nr-uesoftmodem 2>/dev/null || true
  pkill -9 -f "iperf3 -c" 2>/dev/null || true
  sleep 2
else
  banner "1  SKIP_STOP=1"
fi

# --- 2 monitoring (VM Grafana if present) ------------------------------------
banner "2  Monitoring helpers (if ~/monitoring exists)"
if [[ -f "$ENSURE_MON" ]]; then
  bash "$ENSURE_MON" || warn "ensure-monitoring-up non-zero"
else
  warn "no $ENSURE_MON — Windows Docker Grafana is enough for snaps"
fi

# --- 3 OAI Path A2G ----------------------------------------------------------
banner "3  Path A2G bring-up (wait for ping)"
[[ -s "$BRINGUP" ]] || { echo "FAIL: missing $BRINGUP" >&2; exit 1; }
bash "$BRINGUP"
if ! ping -I oaitun_ue1 -c 3 -W 3 "$DN" >/dev/null 2>&1; then
  echo "FAIL: oaitun_ue1 -> $DN ping failed. See $LOG/" >&2
  exit 1
fi
ok "PING SUCCESS (air-to-ground PDU path)"
ping -I oaitun_ue1 -c 10 -W 2 "$DN" | tee "$LOG/capture_ping10.txt"

# --- 4 high-rate iperf (background) ------------------------------------------
banner "4  High-rate iperf (background ${IPERF_T}s)"
UE_IP="$(ip -4 -o addr show oaitun_ue1 2>/dev/null | awk '{print $4}' | cut -d/ -f1 || true)"
[[ -n "${UE_IP:-}" ]] || { echo "FAIL: oaitun_ue1 has no IPv4" >&2; exit 1; }
if ! docker ps --format '{{.Names}}' | grep -qx "$DN_CTR"; then
  found="$(docker ps --format '{{.Names}}' | grep -iE 'ext-dn|oai-ext' | head -1 || true)"
  [[ -n "$found" ]] && DN_CTR="$found" && echo "  using DN container $DN_CTR"
fi
docker exec -d "$DN_CTR" iperf3 -s 2>/dev/null \
  || docker exec -d "$DN_CTR" sh -c 'command -v iperf3 >/dev/null || (apt-get update -qq && apt-get install -y -qq iperf3); iperf3 -s' \
  || warn "start iperf3 -s on $DN:5201 yourself"
sleep 1
command -v iperf3 >/dev/null || { echo "FAIL: sudo apt-get install -y iperf3" >&2; exit 1; }
: >/tmp/iperf-client.log
if [[ -n "$UDP_MBPS" ]]; then
  nohup iperf3 -c "$DN" -B "$UE_IP" -R -u -b "${UDP_MBPS}M" -t "$IPERF_T" -i 2 \
    >/tmp/iperf-client.log 2>&1 &
  echo "  UDP DL ${UDP_MBPS}M (RFsim — not OTA ATG capacity)"
else
  nohup iperf3 -c "$DN" -B "$UE_IP" -R -P "$PARALLEL" -t "$IPERF_T" -i 2 \
    >/tmp/iperf-client.log 2>&1 &
  echo "  TCP DL -R -P $PARALLEL (n78 106 PRB / 30 kHz class; RFsim MCS may cap)"
fi
echo $! >/tmp/iperf-client.pid
ok "iperf pid=$(cat /tmp/iperf-client.pid) log=/tmp/iperf-client.log"
if [[ -f "$IPERF_PROM" ]]; then
  python3 "$IPERF_PROM" --server "$DN" --bind "$UE_IP" --out "$TXT/iperf.prom" --seconds 6 \
    && ok "iperf.prom" || warn "iperf_to_prom skipped"
fi

# --- 5 Diona -----------------------------------------------------------------
banner "5  Diona baseline (source=example — not live Diona)"
if [[ "${SKIP_DIONA:-0}" != "1" && -f "$DIONA_PY" && -f "$DIONA_CSV" ]]; then
  python3 "$DIONA_PY" --once --csv "$DIONA_CSV" --out "$TXT/diona_baseline.prom" \
    && ok "$TXT/diona_baseline.prom" || warn "Diona exporter failed"
else
  warn "Diona skip (set files or Windows exporter publishes diona_*)"
fi

# --- 6 Sionna ----------------------------------------------------------------
banner "6  Sionna ATG (twin / prior real-run artefact)"
if [[ "${SKIP_SIONNA:-0}" != "1" ]]; then
  published=0
  if [[ -f "$HOME/sionna-ntn-study/scripts/write_grafana_textfile.py" ]]; then
    ( cd "$HOME/sionna-ntn-study" && python3 scripts/write_grafana_textfile.py --also-monitoring-textfile ) \
      && published=1 && ok "Sionna write_grafana_textfile"
  fi
  if [[ "$published" != 1 ]]; then
    for p in "${SIONNA_PROM_CANDIDATES[@]}"; do
      if [[ -f "$p" && "$p" == *.prom ]]; then
        cp -f "$p" "$TXT/sionna_atg.prom"
        ok "copied prior ATG Sionna run -> $TXT/sionna_atg.prom (not live RT this second)"
        published=1
        break
      fi
    done
  fi
  [[ "$published" = 1 ]] || warn "no Sionna artefact — enable ATG_SIONNA=1 on Windows exporter for live twin"
fi

# --- 7 link budget (n78, ~10 km AGL, 50 km slant example) --------------------
banner "7  Link budget (model print — TR 36.777 / FSPL class)"
python3 - <<'PY' | tee "$LOG/capture_link_budget.txt"
import math
c = 299_792_458.0
fc = 3.5e9
eirp = 46.0
g_rx = 0.0
h_ue_m = 10_000.0
slant_km = 50.0
d = slant_km * 1000.0
fspl = 20*math.log10(d) + 20*math.log10(fc) + 20*math.log10(4*math.pi/c)
# ITU-ish gaseous placeholder (small at S-band / this range)
gas = 0.3
impl = 2.0
rx = eirp + g_rx - fspl - gas - impl
print("air-to-ground link-budget SNAPSHOT (model, not OTA)")
print(f"  fc_n78_GHz={fc/1e9:.2f}  UE_alt_km={h_ue_m/1000:.0f}  example_slant_km={slant_km:.0f}")
print(f"  EIRP_dBm={eirp:.1f}  FSPL_dB={fspl:.1f}  gas_dB={gas:.1f}  impl_dB={impl:.1f}")
print(f"  rx_power_dBm≈{rx:.1f}  (canonical lab uses src/common/link_budget.py on the exporter)")
print("  Grafana: aerial geometry / RF boards — labels [model] vs [oai] vs [sionna]")
PY

# --- 8 call-flow --------------------------------------------------------------
banner "8  Call-flow ladder :8787"
if [[ "${SKIP_CALLFLOW:-0}" != "1" ]]; then
  if curl -sf "http://127.0.0.1:8787/" >/dev/null 2>&1; then
    ok ":8787 already up"
  elif [[ -f "$CALLFLOW" ]]; then
    nohup python3 "$CALLFLOW" --host 0.0.0.0 --port 8787 >"$LOG/callflow.log" 2>&1 &
    echo $! >/tmp/callflow.pid
    sleep 1
    ok "callflow pid=$(cat /tmp/callflow.pid)  http://127.0.0.1:8787/"
  else
    warn "missing $CALLFLOW — Grafana atg-sig / Windows :9105 GeoJSON still usable"
  fi
fi

# --- 9 F1 HO (do not tear down Path A2G) -------------------------------------
banner "9  Dual-DU F1 HO (signalling-class — skip get_single_rnti)"
if [[ "${SKIP_HO:-0}" = "1" ]]; then
  warn "SKIP_HO=1"
else
  BUILD="${OAI_ROOT:-$HOME/openairinterface5g}/cmake_targets/ran_build/build"
  CONF="${OAI_ROOT:-$HOME/openairinterface5g}/targets/PROJECTS/GENERIC-NR-5GC/CONF"
  DU1="$CONF/gnb-du.sa.band78.106prb.rfsim.pci1.conf"
  export LD_LIBRARY_PATH="$BUILD:${LD_LIBRARY_PATH:-}"
  if [[ ! -f "$DU1" ]]; then
    warn "stock DU1 conf missing — skip HO"
  elif ! pgrep -f 'gnb-cu.sa.f1.conf' >/dev/null; then
    warn "CU not running — skip HO"
  else
    sudo ip addr add 127.0.0.5/8 dev lo 2>/dev/null || true
    sed -i -E 's/(local_n_portd[[:space:]]*=[[:space:]]*)[0-9]+/\12153/' "$DU1"
    sed -i -E 's/(remote_n_portd[[:space:]]*=[[:space:]]*)[0-9]+/\12153/' "$DU1"
    sed -i -E 's/serveraddr[[:space:]]*=[[:space:]]*"server"/serveraddr = "127.0.0.1"/' "$DU1"
    if ! pgrep -f 'rfsim.pci1.conf' >/dev/null; then
      : >"$LOG/du1.log"
      sudo -E env LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
        "$BUILD/nr-softmodem" --rfsim -O "$DU1" \
        --rfsimulator.[0].serveraddr 127.0.0.1 >>"$LOG/du1.log" 2>&1 &
      ok "DU1 started"
      sleep 12
    else
      ok "DU1 already up"
    fi
    echo "HO_BOUNDARY $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$LOG/cu.log" "$LOG/ho_events.log"
    echo "=== ci trigger_f1_ho (no get_single_rnti) ==="
    printf 'ci trigger_f1_ho\n' | nc -w 3 127.0.0.1 9099
    sleep 12
    grep -iE 'handover|Handover|PathSwitch|ReconfigurationComplete|trigger_f1' "$LOG/cu.log" 2>/dev/null \
      | sed 's/\x1b\[[0-9;]*m//g' | tee -a "$LOG/ho_events.log" | tail -30
    ping -I oaitun_ue1 -c 5 -W 2 "$DN" | tee "$LOG/capture_ping_post_ho.txt"
    ok "F1 HO trigger done — claim signalling-class, not A3"
  fi
fi

# --- 10 URLs / shot list ------------------------------------------------------
VM_IP="${VM_IP:-$(hostname -I 2>/dev/null | awk '{print $1}')}"
VM_IP="${VM_IP:-192.168.122.133}"
banner "10  FILM NOW — Air-to-Ground (ATG) dashboards"
cat <<EOF | tee "$LOG/CAPTURE_READY.txt"

Air-to-Ground (ATG) stack is up. Take video + snaps (Win+Shift+S / Grafana).

  Ping / iperf:   oaitun_ue1 -> $DN   iperf log=/tmp/iperf-client.log
  Lab Demo:       http://$VM_IP:3000/d/atg-full-lab
  Super Ops:      http://$VM_IP:3000/d/atg-lab-super-ops
  Aerial map:     http://$VM_IP:3000/d/atg-live-topology   or  /d/atg-orbit
  All-in-one:     http://$VM_IP:3000/d/atg-all-in-one
  Sionna vs OAI:  http://$VM_IP:3000/d/atg-val
  Call-flow:      http://$VM_IP:8787/   and  /d/atg-sig
  Prometheus:     http://$VM_IP:9090/targets

Windows Docker Grafana (if you film from the laptop):
  http://localhost:3000/d/atg-all-in-one
  http://localhost:3000/d/atg-orbit
  http://localhost:9105/metrics

Shot order (60–90 s): terminal OK lines -> ping -> iperf climbing -> Lab Demo ->
map -> Super Ops (Diona vs ATG) -> Sionna board -> call-flow / HO lines.

Caption: Air-to-Ground 5G (ATG) software emulation — OAI RFsim n78 AWGN,
aircraft UE, not over-the-air.

Kill iperf: kill \$(cat /tmp/iperf-client.pid)  or  bash ~/demo/stop-all.sh
======== ATG CAPTURE TESTCASE DONE ========
EOF
