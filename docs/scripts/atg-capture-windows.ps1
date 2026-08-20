# Air-to-Ground (ATG) — Windows side for capture
# Run from a PowerShell window. Does not start OAI (that is the Ubuntu VM script).

$ErrorActionPreference = "Continue"
$obs = "C:\Users\sures\OneDrive\Desktop\LTE_5g_ATG_emulation_lab\atg-observability"
if (-not (Test-Path -LiteralPath (Join-Path $obs "docker-compose.yml"))) {
  Write-Host "FAIL: missing $obs"
  exit 1
}
Set-Location -LiteralPath $obs
if (-not (Test-Path .env)) {
  if (Test-Path .env.example) { Copy-Item .env.example .env }
  Write-Host "WARN: created .env from example — set ATG_SIONNA=1 INSTALL_SIONNA=1 for live twin"
}
Write-Host "Starting observability (Grafana / Prometheus / exporter)..."
docker compose up -d --build
Write-Host ""
Write-Host "Air-to-Ground (ATG) Windows URLs:"
Write-Host "  Grafana all-in-one : http://localhost:3000/d/atg-all-in-one"
Write-Host "  Aerial map         : http://localhost:3000/d/atg-orbit"
Write-Host "  Super Ops          : http://localhost:3000/d/atg-lab-super-ops"
Write-Host "  Sionna vs OAI      : http://localhost:3000/d/atg-val"
Write-Host "  Exporter           : http://localhost:9105/metrics"
Write-Host ""
Write-Host "On the VM, run:  bash ~/demo/atg-capture-full-testcase.sh"
Write-Host "Optional log sync:  powershell -ExecutionPolicy Bypass -File tools\sync-oai-logs-from-vm.ps1"
