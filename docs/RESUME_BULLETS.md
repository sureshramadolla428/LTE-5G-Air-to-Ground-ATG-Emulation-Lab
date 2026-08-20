# Resume bullets — ATG 5G Lab & Observability

Voice: implied third person · past-tense action verbs. Do not invent employers, patents, OTA flight campaigns, or Rel-18 certification claims.

## Selected project (3–4 lines)

**Air-to-Ground (ATG / A2G) 5G NR Emulation & Observability Lab** — Designed and operated an end-to-end ATG lab: OpenAirInterface CN5G + RAN RFsim (ground BS ↔ aircraft UE, band n78), multi-UE softmodem bring-up, and a Dockerized Prometheus/Grafana/PostGIS stack with live ADS-B kinematics. Instrumented authentic F1 handover from CU logs alongside modeled A3 mobility (3 dB offset / 1 dB hysteresis / 320 ms TTT), canonical TR 36.777 link budget, and optional Sionna RT digital-twin validation with explicit modeled-vs-measured labeling. Delivered NOC dashboards (executive, RF, MAC, throughput, mobility, QoS, geometry, validation, aerial map, signaling, all-in-one) with exportable KPIs and AIOps-lite residual rules—without fabricating absent metrics.

## Experience bullets (pick 6–10)

1. **Architected** an ATG-focused 5G NR lab (OAI CN5G + CU/DU/UE RFsim) modeling ground base station ↔ aircraft UE geometry on n78, with verified PDU-plane ping (~6–14 ms RTT) on emulated tunnels.

2. **Built** a production-style observability stack (Python exporter, Prometheus, Grafana, Loki, PostGIS) publishing `atg_*` KPIs from softmodem logs, ADS-B feeds, link-budget models, and optional Sionna RT—enforcing source labels (`oai` vs `sionna`) and honest NODATA behavior.

3. **Implemented** multi-UE RFsim bring-up (up to 3 UEs) with DU-as-RFsim-server role inversion, stable `oaitun_ue{1,2,3}` tunnel renaming, and CU-UE-ID / RNTI → `ue_id` mapping for per-UE Grafana filtering.

4. **Demonstrated** intra-gNB **F1 handover** under dual-DU RFsim and **instrumented** CU RRC completion tokens into Prometheus counters, serving-cell series, and live aerial-map HO flash layers.

5. **Designed** a modeled **A3** mobility controller for live ADS-B tracks across a four-cell ground grid (Off 3 dB, Hys 1 dB, TTT 320 ms), keeping modeled events provenance-separated from OAI F1 signaling demos.

6. **Codified** a canonical ATG link budget (EIRP, pattern gains, TR 36.777 path loss, ITU-R gaseous/rain/scintillation, fuselage mask) aligned to TS 38.215 / 38.214 / 38.331 / 28.552 panel citations.

7. **Integrated** optional **Sionna RT** (LLVM/CPU LoS paths) as a physics twin with residual recording rules (RSRP/SINR delta, validation gates) versus OAI softmodem readings—gauges published only when CIR amplitudes are finite.

8. **Delivered** eleven provisioned Grafana dashboards (including All-in-One Live Operations and Live Aerial Track Map) with GeoJSON CORS overlays, ADS-B integrity/plausibility controls, and CSV-exportable current KPI readings.

9. **Added** AIOps-lite operator views: residual/anomaly flags from Prometheus recording rules, pipeline health (`atg_pipeline_up`), ADS-B reject ratio, and baseline comparison tiles with explicit non-live labeling where applicable.

10. **Documented** lab honesty boundaries (RFsim ≠ OTA, F1 CI ≠ measurement A3, modeled vs measured KPIs) suitable for engineering review and demos.

## Skills keywords

5G NR · ATG / A2G · OpenAirInterface (OAI) · RFsim · multi-UE · mobility / F1 HO · A3 (TS 38.331) · Prometheus · Grafana · PostGIS · ADS-B · Sionna RT · link budget (TR 36.777) · 3GPP KPIs (TS 38.215 / 38.214 / 28.552) · AIOps-lite · Docker observability · FastAPI · Pydantic

## Optional shorter bullets

- Built ATG 5G RFsim lab + Prometheus/Grafana observability with ADS-B aerial map and multi-UE softmodems.
- Separated authentic OAI F1 HO instrumentation from modeled A3 (3 dB / 1 dB / 320 ms) on live tracks.
- Wired Sionna RT twin and TR 36.777 link budget against OAI readings with residual validation rules.
- Shipped NOC dashboards with exportable KPIs and explicit modeled-vs-measured labeling.
