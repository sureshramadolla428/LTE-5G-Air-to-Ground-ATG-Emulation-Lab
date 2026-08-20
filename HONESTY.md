# Honesty — LTE / 5G ATG emulation lab (public pack)

Read this before citing ping, Grafana, or handover.

## What this is

Software-only **5G SA ATG / A2G** emulation: OAI CU/DU + nrUE + **RFsimulator** + OAI CN5G, with optional Prometheus/Grafana and ADS-B kinematics.

- **Topology:** TR 38.876 **ground base station ↔ aircraft UE** (not HAPS-as-gNB in the green Path-A2G recipe).
- **Radio:** band **n78**, channel **AWGN**, aircraft altitude **~10 km AGL** in `nrue.a2g.rfsim.conf`.
- **Green RFsim roles:** **UE = server**, DU = client.
- **Verified U-plane:** ping **20/20** via `oaitun_ue1` to **192.168.70.135**, typically **~6–14 ms** RTT.

## Grafana

| Dashboard | Trust |
|-----------|--------|
| **Lab Demo** | Ping UP / RTT = **measured** when the probe uses `oaitun`. Many RF tiles = log / simulator. |
| **Live Aerial Track Map** | ADS-B / lab geometry — **not** OTA GPS of a real ATG cell. |
| **Super Ops / All-in-One** | Mix of measured ping, log RF, and **modeled** A3 / link budget. |

Empty series stay empty. That is intentional. Prefer `atg_*` metric names in new work.

Near-**0 ms** ping is usually host/loopback, not the PDU path.

## Mobility

| Recipe | Honest statement |
|--------|------------------|
| Dual-DU F1 HO (CU CI / telnet) | **Signalling-class** — not measurement-report A3 |
| Modeled A3 on ADS-B | Exporter / map (`procedure=modeled_a3`) — not OAI measGap A3 |
| Authentic dual-cell isolated gate | Opt-in evidence report only — does not start the green stack |

## Explicitly not claimed

- Over-the-air / SDR / licensed ATG spectrum / flight campaign
- Rel-18 NR-ATG RF conformance
- Sionna gauges as OAI RSRP unless `source=sionna` and CIR is finite
- Raw ICAO24 / callsign in public metrics (use `tail_id`)

## Language to use

- **Measured** — `oaitun` ICMP, tunnel presence, containers
- **Log / simulator** — softmodem-parsed RF
- **Model** — TR 36.777 / FSPL / modeled A3 / optional Sionna

Personal research and education. Not affiliated with or endorsed by any operator or vendor.
