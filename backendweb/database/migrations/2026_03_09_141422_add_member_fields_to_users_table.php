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
        Schema::table('users', function (Blueprint $table) {
            $table->string('member_level')->default('一般')->after('store_id'); // 一般/優質/VIP
            $table->integer('points')->default(0)->after('member_level');
            $table->string('id_number')->nullable()->after('points');
            $table->string('phone')->nullable()->after('id_number');
            $table->string('address')->nullable()->after('phone');
            $table->string('emergency_contact')->nullable()->after('address');
            $table->string('emergency_phone')->nullable()->after('emergency_contact');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'member_level', 'points', 'id_number', 'phone',
                'address', 'emergency_contact', 'emergency_phone',
            ]);
        });
    }
};
