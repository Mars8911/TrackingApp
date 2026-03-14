<?php

use App\Http\Controllers\Api\AuthController as ApiAuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\RegisterController;
use App\Http\Controllers\Api\StoreController;
use Illuminate\Support\Facades\Route;

// API 根路徑（供測試用）
Route::get('/', function () {
    return response()->json([
        'app' => 'TrackMe API',
        'version' => '1.0',
        'endpoints' => [
            'GET /api' => '此說明',
            'GET /api/dashboard' => '儀表板統計',
            'GET /api/stores' => '店家列表（註冊用）',
            'POST /api/register' => '會員註冊',
            'POST /api/login' => '會員登入',
            'GET /api/user' => '會員個人資料（需 Bearer Token）',
            'POST /api/change-password' => '更改密碼（需 Bearer Token）',
            'GET /api/notifications' => '推播通知列表（需 Bearer Token）',
        ],
    ]);
});

Route::get('/dashboard', [DashboardController::class, 'index']);

// APP 公開 API（供 Flutter 使用，無需認證）
Route::get('/stores', [StoreController::class, 'index']);
Route::post('/register', [RegisterController::class, 'register']);
Route::post('/login', [ApiAuthController::class, 'login']);

// 會員 API（需 Bearer Token 認證）
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [ApiAuthController::class, 'profile']);
    Route::post('/change-password', [ApiAuthController::class, 'changePassword']);
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
});
