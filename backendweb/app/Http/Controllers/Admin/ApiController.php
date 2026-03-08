<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Loan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ApiController extends Controller
{
    /**
     * 取得當前登入的管理者資訊（供 Vue 前端驗證）
     */
    public function user(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user || ! $user->isAdmin()) {
            return response()->json(['message' => '未授權'], 401);
        }
        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'store' => $user->store ? [
                'id' => $user->store->id,
                'name' => $user->store->name,
            ] : null,
        ]);
    }

    /**
     * 儀表板資料（JSON API）
     */
    public function dashboard(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Loan::with('store');

        if ($user->isStoreManager()) {
            if (! $user->store_id) {
                return response()->json([
                    'summary' => ['total_cases' => 0, 'total_loan_amount' => 0, 'total_remaining' => 0],
                    'loans' => [],
                ]);
            }
            $query->where('store_id', $user->store_id);
        }

        $loans = $query->get();
        $summary = [
            'total_cases' => $loans->count(),
            'total_loan_amount' => $loans->sum('loan_amount'),
            'total_remaining' => $loans->sum('remaining_amount'),
        ];

        return response()->json(compact('summary', 'loans'));
    }
}
