<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Store;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class StoreController extends Controller
{
    /**
     * 取得店家列表（供 APP 註冊時選擇，無需認證）
     */
    public function index(): JsonResponse
    {
        try {
            $stores = Store::orderBy('name')->get(['id', 'name', 'branch_name']);

            return response()->json([
                'stores' => $stores,
            ]);
        } catch (\Throwable $e) {
            Log::error('StoreController@index failed: '.$e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'message' => '取得店家列表失敗',
                'stores' => [],
            ], 500);
        }
    }
}
