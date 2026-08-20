# LinkedIn posts — ATG 5G Lab & Observability

First person · technical · ATG only. Do not invent employers, patents, OTA certification, or conversion narratives.

---

## 1) Long-form post

I spent the last stretch of lab time building something I wish more 5G demos had: an **Air-to-Ground (ATG)** stack that stays honest about what is measured, what is modeled, and what is only a signaling exercise.

Topology is straightforward on paper—**ground base station ↔ aircraft UE**—and messy in practice. I run OpenAirInterface CN5G + RAN in RFsim (n78 AWGN) on an Ubuntu VM, and a Docker observability plane on Windows: exporter, Prometheus, Grafana, Loki, PostGIS. Live ADS-B feeds the aerial map and geometry KPIs. Softmodem logs sync into `source=oai` gauges. Optional Sionna RT (LLVM/CPU) publishes a physics twin only when path amplitudes are finite.

A few details that matter to radio people:

• Multi-UE bring-up (3 UEs) with DU as RFsim server, stable `oaitun_ue1..3` tunnels, and CU-UE-ID → `$ue_id` dashboard filtering
• Authentic **F1 HO** from dual-DU CU logs (live map flash + counters)—not claimed as measurement-driven A3
• Modeled **A3** for the ADS-B mobility story: 3 dB offset, 1 dB hysteresis, 320 ms TTT, provenance-labeled
• Canonical link budget (TR 36.777 + ITU-R atmospherics) cited beside TS 38.215 / 38.214 / 38.331 panels
• “All-in-One Live Operations” + Live Aerial Track Map, exportable KPI CSV, AIOps-lite residuals from recording rules—not decorative zeros

Non-goals I keep on the README: no real RF emission, no ATC decision support, no fabricated KPIs. RFsim is not an OTA flight campaign—and saying that clearly is part of the engineering.

If you work ATG planning, softmodem labs, or KPI validation, I am happy to compare notes on provenance labeling and mobility honesty.

#5G #NR #ATG #A2G #OpenAirInterface #Observability #Prometheus #Grafana #Sionna #3GPP

---

## 2) Shorter teaser

Lab note: I put together an **ATG / Air-to-Ground 5G** observability stack I trust enough to show another radio engineer.

OAI RFsim (ground BS ↔ aircraft UE) + Prometheus/Grafana/PostGIS + live ADS-B map. Multi-UE tunnels, F1 HO from real CU log tokens, modeled A3 (3 dB / 1 dB / 320 ms) for ADS-B mobility—clearly separated. Link budget and optional Sionna RT twin stay labeled; empty series stay empty.

Full write-up on Medium.

#5G #ATG #OAI #Observability

---

## 3) Optional carousel — slide titles

1. ATG 5G Lab: Ground BS ↔ Aircraft UE
2. Why Honest Observability Beats Pretty Gauges
3. Architecture: OAI RFsim + Exporter + Prometheus + Grafana
4. Live ADS-B Tracks Meet Softmodem KPIs
5. Multi-UE: Three Tunnels, One `$ue_id` Filter
6. F1 Handover: What the CU Log Actually Proves
7. Modeled A3: 3 dB / 1 dB / 320 ms on Aerial Tracks
8. Link Budget & 3GPP-Aligned KPI Citations
9. Sionna Twin vs OAI — Residuals, Not Fiction
10. All-in-One Live Operations

---

## 4) Comment-ready FAQ

**Q: Is this over-the-air?**  
A: No—OAI RFsim / emulation only. ADS-B is live kinematics; RF path is softmodem + models/Sionna.

**Q: Did you implement measurement-based A3 in OAI?**  
A: Lab F1 HO is CI/signaling-triggered. A3 on the map/metrics for ADS-B is a modeled controller with explicit labels.

**Q: Why n78?**  
A: ATG-intended band context (TR 38.876 Table 5-1); lab stand-in, not Rel-18 NR-ATG conformance.

**Q: Is this Rel-18 NR-ATG RF conformance?**  
A: No — software RFsim lab on n78, not an OTA conformance campaign.
