<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->string('collateral_type')->nullable()->after('repayment_type'); // 汽車機車/房屋土地/其他
            $table->string('collateral_info')->nullable()->after('collateral_type'); // JSON 或文字
            $table->decimal('monthly_payment', 15, 2)->nullable()->after('collateral_info');
            $table->string('repayment_day')->nullable()->after('monthly_payment'); // 30天一期 或 每月__日
            $table->string('interest_collection')->nullable()->after('repayment_day'); // 前扣__個月/後收
            $table->integer('loan_periods')->nullable()->after('interest_collection'); // 期數(月)
            $table->integer('contract_months')->nullable()->after('loan_periods'); // 綁約月數
        });
    }

    public function down(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->dropColumn([
                'collateral_type', 'collateral_info', 'monthly_payment',
                'repayment_day', 'interest_collection', 'loan_periods', 'contract_months',
            ]);
        });
    }
};
