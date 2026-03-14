<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Loan;
use App\Models\LoanRepayment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class LoanRepaymentController extends Controller
{
    /**
     * 取得某案件的繳款明細
     */
    public function index(Request $request, int $loanId): JsonResponse
    {
        $admin = $request->user();
        $loan = Loan::with('repayments')->findOrFail($loanId);

        if ($admin->isStoreManager() && $loan->store_id !== $admin->store_id) {
            abort(403);
        }

        return response()->json(['repayments' => $loan->repayments]);
    }

    /**
     * 新增還款
     */
    public function store(Request $request, int $loanId): JsonResponse
    {
        $admin = $request->user();
        $loan = Loan::findOrFail($loanId);

        if ($admin->isStoreManager() && $loan->store_id !== $admin->store_id) {
            abort(403);
        }

        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:0'],
            'payment_date' => ['required', 'date'],
            'status' => ['nullable', Rule::in(['準時', '提前', '延遲'])],
            'notes' => ['nullable', 'string', 'max:500'],
        ]);

        $repayment = $loan->repayments()->create($validated);

        return response()->json(['message' => 'ok', 'repayment' => $repayment->fresh()]);
    }

    /**
     * 刪除還款
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $repayment = LoanRepayment::with('loan')->findOrFail($id);

        if ($admin->isStoreManager() && $repayment->loan->store_id !== $admin->store_id) {
            abort(403);
        }

        $repayment->delete();

        return response()->json(['message' => 'ok']);
    }
}
