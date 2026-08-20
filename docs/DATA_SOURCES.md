# DATA_SOURCES — licence / ToS register (§9.13)
#
# For every entry: name, URL, licence, commercial-use (y/n), attribution,
# retrieval date, local path, checksum (sha256 prefix when downloaded).

| Name | URL | Licence | Commercial use | Attribution | Retrieved | Local path | Checksum |
|---|---|---|---|---|---|---|---|
| adsb.fi open data | https://opendata.adsb.fi | Community aggregator ToS | **n** — check ToS before redistribution | Attribute adsb.fi | 2026-08-05 | (live API / `data/cache/adsbfi`) | n/a live |
| OpenSky Network REST | https://opensky-network.org | Free for non-commercial / academic research | **n** (research; follow OpenSky terms) | Cite OpenSky Network | 2026-08-05 | `data/cache/opensky` | n/a live |
| OpenSky historical (`state_vectors_data4`) | OpenSky Trino / Impala | Same as OpenSky research terms | **n** | Cite OpenSky + query window | 2026-08-05 | `data/replay/<session>/` via `opensky_history.py` | per session manifest |
| airplanes.live | https://api.airplanes.live | Community API; ~1 req/s | **n** — check ToS | Attribute airplanes.live | 2026-08-05 | `data/cache/airplaneslive` | n/a live |
| dump1090 / readsb local | Local `aircraft.json` | Operator-owned receiver data | **y** (your data) | Local lab | 2026-08-05 | `data/readsb/aircraft.json` | n/a |
| ADSBExchange (RapidAPI) | https://adsbexchange.com | Paid tiers; config-gated OFF | **check** paid licence | — | — | disabled by default | — |
| ADSBHub | https://www.adsbhub.org | Feed-to-access | **check** | — | — | disabled | — |
| OpenSky Zenodo dumps | Zenodo DOI (OpenSky) | Dataset-specific | **check** DOI licence | Cite DOI | — | `data/static/opensky_zenodo/` (placeholder) | — |
| Eurocontrol R&D Archive | Eurocontrol | Research registration | **n** research | Cite Eurocontrol | — | `data/static/eurocontrol/` | — |
| FAA SWIM / ASDI | FAA | Registration required | **check** | Cite FAA | — | disabled | — |
| OurAirports CSV | https://ourairports.com/data/ | OurAirports licence (permissive + attribution) | **y** w/ attribution | OurAirports | placeholder | `data/static/ourairports/` | pending download |
| OpenFlights / OpenAIP | https://openflights.org / https://www.openaip.net | Respective licences | **check** | Cite source | placeholder | `data/static/openflights/` | pending |
| Copernicus DEM GLO-30 / SRTM / ASTER | Copernicus / NASA | Copernicus / public | **y** per programme terms | Cite Copernicus/NASA | placeholder | `data/static/dem/` | pending |
| OpenStreetMap + blender-osm | https://www.openstreetmap.org | ODbL | **y** w/ share-alike | © OpenStreetMap contributors | placeholder | `data/static/osm/` | pending |
| Natural Earth / GADM | https://www.naturalearthdata.com | Public domain (NE) / GADM licence | **y** (NE) / **check** (GADM) | Natural Earth | placeholder | `data/static/basemap/` | pending |
| ITU-R P.676/P.618/P.835/P.453 | ITU | ITU copyright — formulas only | Spec text **n**; eng. approx OK | Cite ITU-R | 2026-08-05 | implemented in `src/common/spec3gpp/itu_atmos.py` | n/a |
| IGRA / ERA5 | NOAA / CDS | Programme terms | **check** | Cite NOAA/CDS | placeholder | `data/static/atmosphere/` | pending |
| Sionna | NVIDIA Sionna | Apache-2.0 (verify package) | **y** (Apache-2.0) | NVIDIA Sionna | 2026-08-05 | optional pip | — |
| OpenAirInterface | openairinterface.org | OAI Public License | **check** | Cite OAI | 2026-08-05 | external / profile `oai` | — |
| 3GPP TS/TR | 3gpp.org | 3GPP copyright — citations only | Spec PDFs **n** | Cite clause IDs | 2026-08-05 | inline comments in `src/common/spec3gpp/` | n/a |
| Demo replay session | bundled | Lab synthetic | **y** | ATG lab | 2026-08-05 | `data/replay/demo/` | see `manifest.json` |

**Policy:** live API calls use token bucket + full-jitter backoff + disk cache + circuit breaker + ETag. HTTP 429 never stalls the exporter. Raw `icao24`↔`tail_id` mapping file is gitignored (`data/icao_tail_map.json`).
