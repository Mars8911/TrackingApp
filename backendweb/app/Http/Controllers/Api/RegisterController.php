<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RegisterController extends Controller
{
    /**
     * 會員註冊（供 APP 使用，無需認證）
     */
    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:20'],
            'id_number' => ['required', 'string', 'max:20'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'store_id' => ['required', 'integer', 'exists:stores,id'],
        ], [
            'email.unique' => '此電子郵箱已被註冊',
            'password.confirmed' => '兩次密碼輸入不一致',
            'store_id.exists' => '所選店家不存在',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => '驗證失敗',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'id_number' => $request->id_number,
            'password' => $request->password,
            'store_id' => $request->store_id,
            'role' => 'member',
            'member_level' => '一般',
            'points' => 0,
        ]);

        return response()->json([
            'message' => '註冊成功',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'store_id' => $user->store_id,
            ],
        ], 201);
    }
}
