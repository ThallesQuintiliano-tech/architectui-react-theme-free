<?php

use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'ok' => true,
        'service' => 'laravel',
        'time' => now()->toIso8601String(),
    ]);
})->name('health');
