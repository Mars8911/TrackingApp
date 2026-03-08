<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Store extends Model
{
    // 允許批量寫入的欄位
    protected $fillable = ['name', 'branch_name'];
    // 定義關聯：一家店有很多貸款案
    public function loans()
    {
        return $this->hasMany(Loan::class);
    }

    // 定義關聯：一家店有多位使用者（店家管理者、會員）
    public function users()
    {
        return $this->hasMany(\App\Models\User::class);
    }
}
