<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Loan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class LoanController extends Controller
{
    /**
     * 新增貸款案件
     */
    public function store(Request $request, int $memberId): JsonResponse
    {
        $admin = $request->user();
        $member = \App\Models\User::where('role', 'member')->findOrFail($memberId);

        if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
            abort(403);
        }

        if (! $member->store_id) {
            return response()->json(['message' => '會員未歸屬店家'], 422);
        }

        $repaymentType = $request->input('repayment_type', 'amortization');
        if (! in_array($repaymentType, ['interest_only', 'amortization'], true)) {
            return response()->json(['message' => '還款方式必須為純繳息或本利攤'], 422);
        }

        $loan = Loan::create([
            'user_id' => $member->id,
            'store_id' => $member->store_id,
            'loan_amount' => 0,
            'remaining_amount' => 0,
            'interest_rate' => 0,
            'repayment_type' => $repaymentType,
        ]);

        return response()->json(['message' => 'ok', 'loan' => $loan->fresh()]);
    }

    /**
     * 更新貸款案件（店長可編輯）
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $loan = Loan::with('store')->findOrFail($id);

        if ($admin->isStoreManager() && $loan->store_id !== $admin->store_id) {
            abort(403);
        }

        $validated = $request->validate([
            'collateral_type' => ['nullable', Rule::in(['汽車', '機車', '汽車機車', '房屋', '土地', '房屋土地', '其他'])],
            'collateral_info' => ['nullable', 'string'],
            'loan_amount' => ['sometimes', 'numeric', 'min:0'],
            'remaining_amount' => ['sometimes', 'numeric', 'min:0'],
            'interest_rate' => ['nullable', 'numeric', 'min:0'],
            'monthly_payment' => ['nullable', 'numeric', 'min:0'],
            'repayment_day' => ['nullable', 'string', 'max:50'],
            'interest_collection' => ['nullable', 'string', 'max:50'],
            'loan_periods' => ['nullable', 'integer', 'min:0'],
            'contract_months' => ['nullable', 'integer', 'min:0'],
        ]);

        $loan->update($validated);

        return response()->json(['message' => 'ok', 'loan' => $loan->fresh()]);
    }

    /**
     * 刪除貸款案件
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $loan = Loan::findOrFail($id);

        if ($admin->isStoreManager() && $loan->store_id !== $admin->store_id) {
            abort(403);
        }

        $loan->delete();

        return response()->json(['message' => 'ok']);
    }
}
