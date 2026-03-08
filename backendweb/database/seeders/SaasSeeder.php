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
        // 1. 最高管理員
        \App\Models\User::create([
            'name' => '最高管理員',
            'email' => 'admin@trackme.com',
            'password' => bcrypt('password'),
            'role' => 'super_admin'
        ]);

        // 2. A店家
        $store = \App\Models\Store::create(['name' => 'A店家', 'branch_name' => '旗艦店']);

        // 2b. 店家管理者 (歸屬 A 店家)
        \App\Models\User::create([
            'name' => '王店長',
            'email' => 'store@trackme.com',
            'password' => bcrypt('password'),
            'role' => 'store_manager',
            'store_id' => $store->id,
        ]);

        // 3. 李大明 (歸屬 A 店家)
        $user = \App\Models\User::create([
            'name' => '李大明',
            'email' => 'li@example.com',
            'password' => bcrypt('password'),
            'role' => 'member',
            'store_id' => $store->id
        ]);

        // 4. 李大明的借貸
        \App\Models\Loan::create([
            'user_id' => $user->id,
            'store_id' => $store->id,
            'loan_amount' => 1384567,
            'remaining_amount' => 1234566,
            'interest_rate' => 8.5,
            'repayment_type' => 'amortization'
        ]);
    }
}
