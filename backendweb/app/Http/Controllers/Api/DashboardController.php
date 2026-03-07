<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Loan;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        // 抓取資料庫數據
        $totalCases = Loan::count();
        $totalAmount = Loan::sum('loan_amount');
        $totalRemaining = Loan::sum('remaining_amount');

        return response()->json([
            'status' => 'success',
            'data' => [
                'summary' => [
                    'total_cases' => (int)$totalCases,
                    'total_loan_amount' => (float)$totalAmount,
                    'total_remaining' => (float)$totalRemaining,
                ]
            ]
        ]);
    }
}
