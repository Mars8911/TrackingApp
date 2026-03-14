<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SaasSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void {
        // 1. 最高管理員（User 模型有 password hashed cast，直接傳明文即可）
        \App\Models\User::updateOrCreate(
            ['email' => 'admin@trackme.com'],
            ['name' => '最高管理員', 'password' => 'password', 'role' => 'super_admin']
        );

        // 2. A店家
        $store = \App\Models\Store::firstOrCreate(
            ['name' => 'A店家'],
            ['branch_name' => '旗艦店']
        );

        // 2b. 店家管理者 (歸屬 A 店家)
        \App\Models\User::updateOrCreate(
            ['email' => 'store@trackme.com'],
            ['name' => '王店長', 'password' => 'password', 'role' => 'store_manager', 'store_id' => $store->id]
        );

        // 3. 李大明 (歸屬 A 店家，會員資訊範例)
        $user = \App\Models\User::updateOrCreate(
            ['email' => 'li@example.com'],
            [
                'name' => '李大明',
                'password' => 'password',
                'role' => 'member',
                'store_id' => $store->id,
                'member_level' => '一般',
                'points' => 5,
                'id_number' => 'A123456789',
                'phone' => '0912345678',
                'address' => '台北市信義區',
                'emergency_contact' => '李太太',
                'emergency_phone' => '0923456789',
            ]
        );

        // 4. 李大明的借貸
        $loan = \App\Models\Loan::firstOrCreate(
            ['user_id' => $user->id, 'store_id' => $store->id],
            [
                'loan_amount' => 1384567,
                'remaining_amount' => 1234566,
                'interest_rate' => 8.5,
                'repayment_type' => 'amortization',
            ]
        );
        $loan->update([
            'collateral_type' => '汽車',
            'collateral_info' => 'ABC-1234',
            'monthly_payment' => 92592,
            'repayment_day' => '每月5號',
        ]);
    }
}
