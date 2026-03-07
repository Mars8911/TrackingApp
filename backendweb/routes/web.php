<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\DashboardController;

Route::get('/', function () {
    return view('welcome');
});


Route::get('/api/dashboard', [DashboardController::class, 'index']);
