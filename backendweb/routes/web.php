<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\ApiController as AdminApiController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/api/dashboard', [DashboardController::class, 'index']);

// 管理後台 API（供 Vue 使用，Session 認證）
Route::prefix('api/admin')->middleware(['web', 'auth', 'admin'])->group(function () {
    Route::get('user', [AdminApiController::class, 'user']);
    Route::get('dashboard', [AdminApiController::class, 'dashboard']);
});

// 管理後台（Vue SPA）
Route::prefix('admin')->name('admin.')->group(function () {
    Route::post('login', [AuthController::class, 'login'])->name('login.submit');
    Route::post('logout', [AuthController::class, 'logout'])->name('logout');

    // Vue SPA 掛載點（所有 GET /admin/* 皆回傳同一 view，含 /admin/login）
    Route::get('/{path?}', function () {
        return view('admin.spa');
    })->where('path', '.*')->name('dashboard');
});
