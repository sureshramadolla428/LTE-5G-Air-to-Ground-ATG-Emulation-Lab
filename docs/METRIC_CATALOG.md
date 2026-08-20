# ATG Metric Catalog

Catalog written by `exporter.registry.export_metric_catalog_md()`. Do not edit by hand.

| Metric | Type | Labels | Help |
|--------|------|--------|------|
| `atg_a3_margin_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | A3 event margin [dB] (TS 38.331) |
| `atg_a5_thresh1_margin_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | A5 Thresh1 margin [dB] |
| `atg_a5_thresh2_margin_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | A5 Thresh2 margin [dB] |
| `atg_active_pdu_sessions` | Gauge | cell_id,five_qi | Active PDU sessions |
| `atg_active_rrc_connections` | Gauge | cell_id | Active RRC connections |
| `atg_adsb_aircraft_tracked` | Gauge | feed | Aircraft tracked per feed |
| `atg_adsb_crosssource_alt_delta_ft` | Gauge | feed_a,feed_b | Cross-source altitude delta [ft] |
| `atg_adsb_crosssource_horizontal_rmse_m` | Gauge | feed_a,feed_b | Cross-source horizontal RMSE [m] |
| `atg_adsb_feed_up` | Gauge | feed | ADS-B feed up (1) / circuit open (0) |
| `atg_adsb_fetch` | Counter | feed,result | ADS-B fetch attempts; result=ok\|error\|ratelimit\|cache |
| `atg_adsb_fetch_latency_ms` | Histogram | feed | ADS-B fetch latency [ms] |
| `atg_adsb_fetch_total` | Counter | feed,result | ADS-B fetch attempts; result=ok\|error\|ratelimit\|cache |
| `atg_adsb_msg_age_s` | Gauge | feed,tail_id | ADS-B message age [s] |
| `atg_adsb_nac_p` | Gauge | tail_id | NACp |
| `atg_adsb_nac_v` | Gauge | tail_id | NACv |
| `atg_adsb_nic` | Gauge | tail_id | NIC |
| `atg_adsb_ratelimit_hits` | Counter | feed | Token-bucket / 429 hits |
| `atg_adsb_ratelimit_hits_total` | Counter | feed | Token-bucket / 429 hits |
| `atg_adsb_records_ingested` | Counter | feed | Accepted ADS-B records ingested |
| `atg_adsb_records_ingested_total` | Counter | feed | Accepted ADS-B records ingested |
| `atg_adsb_reject` | Counter | cause,feed | Rejected ADS-B samples (legacy alias of rejected_total) |
| `atg_adsb_reject_total` | Counter | cause,feed | Rejected ADS-B samples (legacy alias of rejected_total) |
| `atg_adsb_rejected` | Counter | feed,reason | Rejected ADS-B samples; reason=stale\|on_ground\|nic_low\|teleport\|speed\|vrate\|turnrate\|schema |
| `atg_adsb_rejected_total` | Counter | feed,reason | Rejected ADS-B samples; reason=stale\|on_ground\|nic_low\|teleport\|speed\|vrate\|turnrate\|schema |
| `atg_adsb_sil` | Gauge | tail_id | SIL |
| `atg_adsb_tracks` | Gauge | feed,quality | Accepted ADS-B tracks (legacy; prefer aircraft_tracked) |
| `atg_adsb_version` | Gauge | tail_id | ADS-B version |
| `atg_aircraft_demand_bps` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Aircraft offered demand [bps] |
| `atg_altitude_ft` | Gauge | tail_id | Altitude [ft] |
| `atg_altitude_m` | Gauge | tail_id,cell_id,source | Aircraft HAE altitude [m] (legacy alias) |
| `atg_anomaly_flag` | Gauge | kpi | 1 if \|residual\| exceeds gate; 0 otherwise; NaN if unpaired |
| `atg_azimuth_deg` | Gauge | tail_id,cell_id | Link azimuth [deg] |
| `atg_beam_pointing_error_deg` | Gauge | tail_id | Beam pointing error [deg] |
| `atg_beam_switch` | Counter | cell_id,source | Beam switches |
| `atg_beam_switch_total` | Counter | cell_id,source | Beam switches |
| `atg_beam_thp_bps` | Gauge | cell_id,beam_id,direction,source | Beam throughput [bps] |
| `atg_bler_initial_ratio` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | Initial BLER target ratio |
| `atg_bler_residual_ratio` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | Residual BLER after HARQ |
| `atg_cell_thp_bps` | Gauge | cell_id,direction,source | Cell aggregate throughput [bps] |
| `atg_cho_cancelled` | Counter | cell_id,source | CHO cancelled |
| `atg_cho_cancelled_total` | Counter | cell_id,source | CHO cancelled |
| `atg_cho_condition_met` | Counter | cell_id,source | CHO condition met |
| `atg_cho_condition_met_total` | Counter | cell_id,source | CHO condition met |
| `atg_cho_configured` | Counter | cell_id,source | CHO configured |
| `atg_cho_configured_total` | Counter | cell_id,source | CHO configured |
| `atg_cho_executed` | Counter | cell_id,source | CHO executed |
| `atg_cho_executed_total` | Counter | cell_id,source | CHO executed |
| `atg_clock_skew_ms` | Gauge | component | Clock skew [ms] |
| `atg_code_rate` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | Code rate R |
| `atg_coherence_time_ms` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Clarke coherence time [ms] |
| `atg_coverage_availability_ratio` | Gauge | tail_id | Coverage availability ratio |
| `atg_cp_budget_violation` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Delay spread vs CP budget fail (TS 38.213) |
| `atg_cp_load_per_amf_msgs_per_s` | Gauge | amf_id | CP load per AMF [msgs/s] |
| `atg_cqi` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | CQI index (TS 38.214) |
| `atg_csi_rsrp_dbm` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | CSI-RSRP [dBm] (TS 38.215) |
| `atg_csi_sinr_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | CSI-SINR [dB] (TS 38.215) |
| `atg_daps_ho` | Counter | cell_id,source | DAPS HO events (TS 38.331) |
| `atg_daps_ho_total` | Counter | cell_id,source | DAPS HO events (TS 38.331) |
| `atg_delay_spread_ns` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | RMS delay spread [ns] |
| `atg_doppler_hz` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Geometric Doppler [Hz] |
| `atg_doppler_margin_pct` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Residual Doppler vs SCS [%] (MODULE 3 gate <5) |
| `atg_doppler_precomp_hz` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Pre-compensated Doppler [Hz] |
| `atg_doppler_residual_hz` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Residual Doppler after precomp [Hz] |
| `atg_doppler_swing_hz` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Approach-recede Doppler swing [Hz] |
| `atg_drb_setup_success_ratio` | Gauge | five_qi,direction,source | DRB setup success ratio |
| `atg_eirp_dbm` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | EIRP [dBm] |
| `atg_elevation_angle_deg` | Gauge | tail_id,cell_id | Link elevation [deg] |
| `atg_elevation_deg` | Gauge | tail_id,cell_id,source | Elevation at GS [deg] (legacy alias of elevation_angle_deg) |
| `atg_exporter_build` | Gauge | — | ATG exporter build marker (1=running); product=A2G aerial-track map |
| `atg_exporter_scrape` | Counter | — | Exporter /metrics scrapes served |
| `atg_exporter_scrape_total` | Counter | — | Exporter /metrics scrapes served |
| `atg_f1ap_msg` | Counter | procedure | F1AP messages (TS 38.473) |
| `atg_f1ap_msg_total` | Counter | procedure | F1AP messages (TS 38.473) |
| `atg_fuselage_loss_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Fuselage blockage mask [dB] |
| `atg_fusion_cycle_ms` | Histogram | — | Fusion / link-selector cycle [ms] |
| `atg_gain_rx_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Airborne RX gain [dB] |
| `atg_gain_tx_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | gNB pattern gain [dB] |
| `atg_gaseous_loss_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | ITU-R P.676 gaseous loss [dB] |
| `atg_gbr_compliance_ratio` | Gauge | five_qi,direction,source | GBR compliance ratio |
| `atg_ground_speed_kt` | Gauge | tail_id | Ground speed [kt] |
| `atg_ground_speed_mps` | Gauge | tail_id | Ground speed [m/s] |
| `atg_harq_attempts` | Histogram | tail_id,cell_id,beam_id,source,band,scs_khz,direction | HARQ attempt count distribution (TS 38.321) |
| `atg_harq_fail` | Counter | tail_id,cell_id,beam_id,source,band,scs_khz,direction | HARQ failures (TS 38.321) |
| `atg_harq_fail_total` | Counter | tail_id,cell_id,beam_id,source,band,scs_khz,direction | HARQ failures (TS 38.321) |
| `atg_harq_retx` | Counter | tail_id,cell_id,beam_id,source,band,scs_khz,direction | HARQ retransmissions (TS 38.321) |
| `atg_harq_retx_total` | Counter | tail_id,cell_id,beam_id,source,band,scs_khz,direction | HARQ retransmissions (TS 38.321) |
| `atg_harq_tx` | Counter | tail_id,cell_id,beam_id,source,band,scs_khz,direction | HARQ first transmissions (TS 38.321) |
| `atg_harq_tx_total` | Counter | tail_id,cell_id,beam_id,source,band,scs_khz,direction | HARQ first transmissions (TS 38.321) |
| `atg_heading_deg` | Gauge | tail_id | Heading [deg] |
| `atg_ho_attempt` | Counter | cell_id,source,procedure | HO attempts |
| `atg_ho_attempt_total` | Counter | cell_id,source,procedure | HO attempts |
| `atg_ho_fail` | Counter | cell_id,source,procedure,cause | HO failures |
| `atg_ho_fail_total` | Counter | cell_id,source,procedure,cause | HO failures |
| `atg_ho_interruption_ms` | Histogram | cell_id,source,procedure | HO interruption time [ms] |
| `atg_ho_pingpong` | Counter | cell_id,source,procedure | HO ping-pong |
| `atg_ho_pingpong_total` | Counter | cell_id,source,procedure | HO ping-pong |
| `atg_ho_success` | Counter | cell_id,source,procedure | HO successes |
| `atg_ho_success_total` | Counter | cell_id,source,procedure | HO successes |
| `atg_interference_dbm` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,cause | Interference power [dBm]; cause=intra\|inter\|terrestrial\|ul_aggregate |
| `atg_jain_fairness_index` | Gauge | cell_id,source | Jain fairness index |
| `atg_jitter_ms` | Histogram | five_qi,direction,source | Jitter [ms] |
| `atg_k_factor_refraction` | Gauge | tail_id | Refraction k-factor |
| `atg_lat_deg` | Gauge | tail_id,cell_id,source | Aircraft latitude [deg] (legacy alias) |
| `atg_latency_ms` | Histogram | five_qi,direction,source | User-plane latency [ms] (TS 28.554) |
| `atg_lon_deg` | Gauge | tail_id,cell_id,source | Aircraft longitude [deg] (legacy alias) |
| `atg_los_probability` | Gauge | tail_id,cell_id | LoS probability |
| `atg_los_state` | Gauge | tail_id,cell_id | LoS state 1=LoS 0=NLoS |
| `atg_mcs_index` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | MCS index (TS 38.214) |
| `atg_mimo_rank` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | MIMO rank |
| `atg_model_extrapolated` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | TR 36.777 height extrapolation active |
| `atg_modulation_order` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | Modulation order Qm |
| `atg_ngap_initial_ctx_setup` | Counter | result | NGAP Initial Context Setup (TS 38.413); result=success\|fail |
| `atg_ngap_initial_ctx_setup_total` | Counter | result | NGAP Initial Context Setup (TS 38.413); result=success\|fail |
| `atg_noise_floor_dbm` | Gauge | band,scs_khz | Thermal noise floor [dBm] |
| `atg_num_mpc` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Number of multipath components |
| `atg_oai_parse_errors` | Counter | stage | OAI parse errors by stage |
| `atg_oai_parse_errors_total` | Counter | stage | OAI parse errors by stage |
| `atg_packet_loss_ratio` | Gauge | five_qi,direction,source | Packet loss ratio |
| `atg_paging` | Counter | — | Paging messages |
| `atg_paging_total` | Counter | — | Paging messages |
| `atg_path_gain_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Path gain [dB] |
| `atg_path_loss_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Path loss [dB] |
| `atg_pathloss_model_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,bin_type,bin | Modelled path loss [dB] (TR 36.777 / FSPL / Sionna); bin_type=pathloss_model |
| `atg_pdb_violation_ratio` | Gauge | five_qi,direction,source | PDB violation ratio |
| `atg_pdu_session_estab` | Counter | result | PDU Session Establishment; result=success\|fail |
| `atg_pdu_session_estab_total` | Counter | result | PDU Session Establishment; result=success\|fail |
| `atg_pdu_session_setup_latency_ms` | Histogram | — | PDU session setup latency [ms] |
| `atg_peak_rate_38306_bps` | Gauge | band,scs_khz,direction,source | TS 38.306 peak rate [bps] |
| `atg_pipeline_up` | Gauge | component | Pipeline component up 1/0; component=adsb\|sionna\|oai\|fusion\|exporter\|geo |
| `atg_pitch_deg` | Gauge | tail_id | Pitch [deg] |
| `atg_position_alt_baro_m` | Gauge | tail_id | Barometric altitude [m] |
| `atg_position_alt_geo_m` | Gauge | tail_id | Geometric altitude [m] |
| `atg_position_alt_m` | Gauge | tail_id | Aircraft altitude HAE [m] |
| `atg_position_lat` | Gauge | tail_id | Aircraft latitude [deg] VALUE |
| `atg_position_lon` | Gauge | tail_id | Aircraft longitude [deg] VALUE |
| `atg_prb_total` | Gauge | cell_id,direction,source | PRBs total |
| `atg_prb_used` | Gauge | cell_id,direction,source | PRBs used |
| `atg_propagation_delay_ms` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | One-way prop delay [ms] |
| `atg_radio_horizon_geometric_km` | Gauge | tail_id,cell_id | Geometric radio horizon [km] |
| `atg_radio_horizon_refracted_km` | Gauge | tail_id,cell_id | Refracted radio horizon [km] |
| `atg_rain_loss_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | ITU-R P.618 rain loss [dB] |
| `atg_registration` | Counter | result | NAS registration; result=success\|fail |
| `atg_registration_total` | Counter | result | NAS registration; result=success\|fail |
| `atg_replay_mode` | Gauge | — | 1=replay 0=live |
| `atg_residual_db` | Gauge | kpi,bin_type,bin | Sionna−OAI residual [dB] for paired KPI (absent→NaN) |
| `atg_retainability_ratio` | Gauge | five_qi,direction,source | Retainability ratio (TS 28.552) |
| `atg_rician_k_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Rician K-factor [dB] |
| `atg_rlf` | Counter | cell_id,source,cause | Radio link failures |
| `atg_rlf_total` | Counter | cell_id,source,cause | Radio link failures |
| `atg_roll_deg` | Gauge | tail_id | Roll [deg] |
| `atg_rrc_reestab_attempt` | Counter | cell_id,source | RRC re-establishment attempts (TS 38.331) |
| `atg_rrc_reestab_attempt_total` | Counter | cell_id,source | RRC re-establishment attempts (TS 38.331) |
| `atg_rrc_reestab_success` | Counter | cell_id,source | RRC re-establishment successes |
| `atg_rrc_reestab_success_total` | Counter | cell_id,source | RRC re-establishment successes |
| `atg_rrc_resume_attempt` | Counter | cell_id | RRC Resume attempts |
| `atg_rrc_resume_attempt_total` | Counter | cell_id | RRC Resume attempts |
| `atg_rrc_resume_success` | Counter | cell_id | RRC Resume successes |
| `atg_rrc_resume_success_total` | Counter | cell_id | RRC Resume successes |
| `atg_rrc_setup_attempt` | Counter | cell_id | RRC Setup attempts (TS 38.331) |
| `atg_rrc_setup_attempt_total` | Counter | cell_id | RRC Setup attempts (TS 38.331) |
| `atg_rrc_setup_latency_ms` | Histogram | — | RRC Setup latency [ms] |
| `atg_rrc_setup_success` | Counter | cell_id | RRC Setup successes |
| `atg_rrc_setup_success_total` | Counter | cell_id | RRC Setup successes |
| `atg_rsrp_dbm` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | SS-RSRP [dBm] (TS 38.215) |
| `atg_rsrq_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | SS-RSRQ [dB] (TS 38.215) |
| `atg_rssi_dbm` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | RSSI [dBm] |
| `atg_rtt_ms` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | RTT estimate [ms] |
| `atg_scintillation_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Scintillation loss [dB] |
| `atg_scs_khz_value` | Gauge | band,scs_khz | Numerology SCS [kHz] as value (for Doppler margin PromQL) |
| `atg_serving_cell_info` | Gauge | tail_id,cell_id,beam_id | Serving cell info-style gauge (value=1) |
| `atg_sig_bytes` | Counter | procedure,direction | Signaling bytes |
| `atg_sig_bytes_total` | Counter | procedure,direction | Signaling bytes |
| `atg_sig_load_bytes_per_s` | Gauge | direction | Signaling byte rate [B/s] |
| `atg_sig_load_msgs_per_s` | Gauge | procedure | Signaling message rate [1/s] |
| `atg_sig_msg` | Counter | procedure,direction,cause | Signaling messages (TS 38.331/38.413) |
| `atg_sig_msg_total` | Counter | procedure,direction,cause | Signaling messages (TS 38.331/38.413) |
| `atg_sinr_db` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | SS-SINR [dB] (TS 38.215) |
| `atg_sionna_rt_paths_found` | Gauge | — | Sionna RT paths found |
| `atg_sionna_rt_runs` | Counter | result | Sionna RT runs; result=success\|fail\|skipped |
| `atg_sionna_rt_runs_total` | Counter | result | Sionna RT runs; result=success\|fail\|skipped |
| `atg_sionna_rt_runtime_ms` | Histogram | — | Sionna RT runtime [ms] |
| `atg_slant_range_km` | Gauge | tail_id,cell_id | Slant range [km] |
| `atg_slant_range_m` | Gauge | tail_id,cell_id,source | GS–AC slant range [m] (legacy) |
| `atg_slo_burn_rate` | Gauge | five_qi,direction,source | SLO error budget burn rate |
| `atg_spectral_efficiency_bps_hz` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | Spectral efficiency [bps/Hz] (TS 28.552) |
| `atg_ta_out_of_range` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | TA required beyond N_TA max (TS 38.213) |
| `atg_thp_dl_bps` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | DL UE throughput [bps] (TS 28.552) |
| `atg_thp_efficiency_pct` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz,direction | Thp vs peak [%] |
| `atg_thp_ul_bps` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | UL UE throughput [bps] (TS 28.552) |
| `atg_time_of_stay_predicted_s` | Gauge | tail_id,cell_id,source | Predicted time of stay [s] |
| `atg_time_of_stay_s` | Gauge | tail_id,cell_id,source | Time of stay [s] |
| `atg_timing_advance_us` | Gauge | tail_id,cell_id,beam_id,source,band,scs_khz | Required TA [µs] (TS 38.213) |
| `atg_track_deg` | Gauge | tail_id | Track [deg] |
| `atg_turn_rate_dps` | Gauge | tail_id | Turn rate [deg/s] |
| `atg_val_ba_loa_lower` | Gauge | kpi,bin_type,bin | Bland–Altman LoA lower |
| `atg_val_ba_loa_upper` | Gauge | kpi,bin_type,bin | Bland–Altman LoA upper |
| `atg_val_ba_mean_diff` | Gauge | kpi,bin_type,bin | Bland–Altman mean difference |
| `atg_val_bias` | Gauge | kpi,bin_type,bin | Validation bias |
| `atg_val_delta` | Gauge | kpi,bin_type,bin | Signed residual for heatmaps |
| `atg_val_gate_pass` | Gauge | kpi | Validation gate pass 1/0 |
| `atg_val_gate_pass_ratio` | Gauge | — | Fraction of gates passing |
| `atg_val_ks_d` | Gauge | kpi,bin_type,bin | KS statistic D |
| `atg_val_ks_pvalue` | Gauge | kpi,bin_type,bin | KS p-value |
| `atg_val_mae` | Gauge | kpi,bin_type,bin | Validation MAE |
| `atg_val_mape` | Gauge | kpi,bin_type,bin | Validation MAPE [%] |
| `atg_val_pearson_r` | Gauge | kpi,bin_type,bin | Pearson r |
| `atg_val_r2` | Gauge | kpi,bin_type,bin | R² |
| `atg_val_rmse` | Gauge | kpi,bin_type,bin | Validation RMSE |
| `atg_vertical_rate_fpm` | Gauge | tail_id | Vertical rate [fpm] |
| `atg_xnap_ho_cancel` | Counter | — | XnAP HO cancel |
| `atg_xnap_ho_cancel_total` | Counter | — | XnAP HO cancel |
| `atg_xnap_ho_prep` | Counter | result | XnAP HO preparation; result=success\|fail |
| `atg_xnap_ho_prep_total` | Counter | result | XnAP HO preparation; result=success\|fail |
