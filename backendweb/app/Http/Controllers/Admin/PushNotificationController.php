<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PushNotificationLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PushNotificationController extends Controller
{
    /**
     * 發送推播訊息（群體或指定會員）
     */
    public function send(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:100'],
            'body' => ['required', 'string', 'max:500'],
            'target_type' => ['required', 'in:all,single'],
            'user_id' => ['required_if:target_type,single', 'nullable', 'integer', 'exists:users,id'],
        ]);

        $admin = $request->user();
        $query = User::where('role', 'member');

        if ($admin->isStoreManager()) {
            if (! $admin->store_id) {
                return response()->json(['message' => '店家管理者尚未綁定店家'], 400);
            }
            $query->where('store_id', $admin->store_id);
        }

        if ($validated['target_type'] === 'single') {
            $member = $query->findOrFail($validated['user_id']);
            if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
                abort(403);
            }
            $targets = collect([$member]);
        } else {
            $targets = $query->get();
        }

        if ($targets->isEmpty()) {
            return response()->json(['message' => '無符合條件的發送對象'], 400);
        }

        DB::beginTransaction();
        try {
            foreach ($targets as $user) {
                PushNotificationLog::create([
                    'admin_id' => $admin->id,
                    'user_id' => $user->id,
                    'title' => $validated['title'],
                    'body' => $validated['body'],
                    'target_type' => $validated['target_type'],
                ]);
            }
            // TODO: 整合 FCM 實際發送推播，可透過 Queue Job 非同步處理
            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json(['message' => '發送失敗：' . $e->getMessage()], 500);
        }

        $count = $targets->count();
        return response()->json([
            'message' => "推播已發送，共 {$count} 位會員",
            'sent_count' => $count,
        ]);
    }
}
