<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Loan extends Model
{
    protected $fillable = [
        'user_id',
        'store_id',
        'loan_amount',
        'remaining_amount',
        'interest_rate',
        'repayment_type',
        'collateral_type',
        'collateral_info',
        'monthly_payment',
        'repayment_day',
        'interest_collection',
        'loan_periods',
        'contract_months',
    ];

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function repayments()
    {
        return $this->hasMany(LoanRepayment::class)->orderBy('payment_date', 'desc');
    }
}
