<?php

namespace App\Models;

use Laravel\Sanctum\HasApiTokens; // 必須有這行
// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'store_id',
        'member_level',   // 一般/優質/VIP
        'points',
        'id_number',
        'phone',
        'address',
        'emergency_contact',
        'emergency_phone',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /** 關聯：使用者所屬店家 */
    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    /** 關聯：會員的貸款案件 */
    public function loans()
    {
        return $this->hasMany(Loan::class);
    }

    /** 是否為超級管理者 */
    public function isSuperAdmin(): bool
    {
        return $this->role === 'super_admin';
    }

    /** 是否為店家管理者 */
    public function isStoreManager(): bool
    {
        return $this->role === 'store_manager';
    }

    /** 是否為管理員（超級或店家） */
    public function isAdmin(): bool
    {
        return in_array($this->role, ['super_admin', 'store_manager']);
    }
}
