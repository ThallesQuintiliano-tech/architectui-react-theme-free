$ErrorActionPreference = "Stop"

Set-Location (Resolve-Path "$PSScriptRoot\..")

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw "Docker não encontrado. Instale o Docker Desktop."
}

try {
  docker info | Out-Null
} catch {
  throw "Docker não está respondendo. Abra o Docker Desktop e aguarde ficar 'Running'."
}

if (-not (Test-Path ".\backend")) {
  New-Item -ItemType Directory -Force -Path ".\backend" | Out-Null
}

if (-not (Test-Path ".\backend\artisan")) {
  Write-Host "Criando Laravel em .\backend (via composer container)..."
  docker run --rm -v "${PWD}\backend:/app" composer:2 create-project laravel/laravel .
}

Set-Location ".\backend"

if (Test-Path ".\.env") {
  (Get-Content ".\.env") `
    -replace "^APP_URL=.*$", "APP_URL=http://localhost:8000" `
    | Set-Content ".\.env"
}

if (-not (Select-String -Path ".\.env" -Pattern "^APP_PORT=" -Quiet)) {
  Add-Content ".\.env" "APP_PORT=8000"
}

Write-Host "Configurando rota /api/health..."

if (-not (Test-Path ".\routes\api.php")) {
  @"
<?php

use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'ok' => true,
        'service' => 'laravel',
        'time' => now()->toIso8601String(),
    ]);
})->name('health');

"@ | Set-Content -Encoding utf8 ".\routes\api.php"
}

$bootstrap = Get-Content ".\bootstrap\app.php" -Raw
if ($bootstrap -notmatch "routes/api\.php") {
  if ($bootstrap -match "->withRouting\(\s*web:") {
    $bootstrap = $bootstrap -replace "(->withRouting\(\s*web:\s*__DIR__\.'/\.\./routes/web\.php',)", "`$1`n        api: __DIR__.'/../routes/api.php',"
    Set-Content ".\bootstrap\app.php" $bootstrap
  }
}

$apiRoutes = Get-Content ".\routes\api.php" -Raw
if ($apiRoutes -notmatch "health") {
  Add-Content ".\routes\api.php" ""
  Add-Content ".\routes\api.php" "Route::get('/health', function () {"
  Add-Content ".\routes\api.php" "    return response()->json(['ok' => true, 'service' => 'laravel', 'time' => now()->toIso8601String()]);"
  Add-Content ".\routes\api.php" "})->name('health');"
}

if (Test-Path ".\config\cors.php") {
  $cors = Get-Content ".\config\cors.php" -Raw

  if ($cors -match "'allowed_origins'\s*=>\s*\[[^\]]*\]") {
    $cors = [regex]::Replace(
      $cors,
      "'allowed_origins'\s*=>\s*\[[^\]]*\]",
      "'allowed_origins' => [env('FRONTEND_URL', 'http://localhost:5173')]"
    )
    Set-Content ".\config\cors.php" $cors
  }
  if (-not (Select-String -Path ".\.env" -Pattern "^FRONTEND_URL=" -Quiet)) {
    Add-Content ".\.env" "FRONTEND_URL=http://localhost:5173"
  }
}

Write-Host "Pronto. Para subir o backend com Sail:"
Write-Host "  cd backend"
Write-Host "  vendor\\bin\\sail up -d"

