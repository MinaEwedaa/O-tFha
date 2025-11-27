# Quick Start Script for OtFha Flask Server
# Run this with: .\start-server.ps1

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STARTING FLASK SERVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to backend directory
Set-Location -Path (Join-Path $PSScriptRoot "backend")

# Check if venv exists
if (-Not (Test-Path "venv\Scripts\Activate.ps1")) {
    Write-Host "ERROR: Virtual environment not found!" -ForegroundColor Red
    Write-Host "Please run: cd backend && python -m venv venv" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Activate virtual environment
Write-Host "[1/3] Activating virtual environment..." -ForegroundColor Green
& "venv\Scripts\Activate.ps1"

# Set environment variables
Write-Host "[2/3] Setting environment variables..." -ForegroundColor Green
$env:KMP_DUPLICATE_LIB_OK = "TRUE"
$env:HOST = "0.0.0.0"
$env:PORT = "5000"
$env:FLASK_ENV = "development"
$env:FLASK_DEBUG = "True"

# Start Flask
Write-Host "[3/3] Starting Flask server..." -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  FLASK SERVER STARTING" -ForegroundColor Yellow
Write-Host "  Model loading takes 30-60 seconds" -ForegroundColor Yellow
Write-Host "  Look for: 'Running on http://0.0.0.0:5000'" -ForegroundColor Yellow
Write-Host "  Android Emulator: http://10.0.2.2:5000" -ForegroundColor Cyan
Write-Host "  Physical Device: http://YOUR_PC_IP:5000" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Run Flask
python app.py

Write-Host ""
Write-Host "Server stopped." -ForegroundColor Yellow
Read-Host "Press Enter to exit"


