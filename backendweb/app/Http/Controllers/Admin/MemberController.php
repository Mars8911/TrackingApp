<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MemberController extends Controller
{
    /**
     * 會員列表（僅 role=member，依 store 隔離）
     */
    public function index(Request $request): JsonResponse
    {
        $admin = $request->user();
        $query = User::with('store')->where('role', 'member');

        if ($admin->isStoreManager()) {
            if (! $admin->store_id) {
                return response()->json(['members' => []]);
            }
            $query->where('store_id', $admin->store_id);
        }

        $members = $query->orderBy('created_at', 'desc')->get();

        return response()->json(['members' => $members]);
    }

    /**
     * 會員詳情（含貸款案件）
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $member = User::with(['store', 'loans' => fn ($q) => $q->with(['store', 'repayments'])])
            ->where('role', 'member')
            ->findOrFail($id);

        if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
            abort(403);
        }

        return response()->json(['member' => $member]);
    }

    /**
     * 更新會員資訊
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $member = User::where('role', 'member')->findOrFail($id);

        if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
            abort(403);
        }

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'member_level' => ['sometimes', Rule::in(['一般', '優質', 'VIP'])],
            'points' => ['sometimes', 'integer', 'min:0'],
            'id_number' => ['nullable', 'string', 'max:20'],
            'phone' => ['nullable', 'string', 'max:20'],
            'address' => ['nullable', 'string'],
            'emergency_contact' => ['nullable', 'string', 'max:100'],
            'emergency_phone' => ['nullable', 'string', 'max:20'],
        ]);

        $member->update($validated);

        return response()->json(['message' => 'ok', 'member' => $member->fresh()]);
    }
}
