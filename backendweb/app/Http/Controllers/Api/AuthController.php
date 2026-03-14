<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    /**
     * 會員登入（供 APP 使用）
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (! Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => '密碼有誤，請再查詢',
            ], 401);
        }

        $user = Auth::user()->load('store');

        if ($user->role !== 'member') {
            Auth::logout();

            return response()->json([
                'message' => '此帳號無權限登入 APP',
            ], 403);
        }

        $token = $user->createToken('app')->plainTextToken;

        return response()->json([
            'message' => '登入成功',
            'token' => $token,
            'user' => $this->formatUserForResponse($user),
        ]);
    }

    /**
     * 取得當前會員個人資料（需 Bearer Token）
     */
    public function profile(Request $request): JsonResponse
    {
        $user = $request->user()->load('store');
        if ($user->role !== 'member') {
            return response()->json(['message' => '無權限'], 403);
        }

        return response()->json([
            'user' => $this->formatUserForResponse($user),
        ]);
    }

    /**
     * 更改密碼（需 Bearer Token）
     */
    public function changePassword(Request $request): JsonResponse
    {
        $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'confirmed', Password::defaults()],
        ], [
            'current_password.required' => '請輸入目前密碼',
            'password.required' => '請輸入新密碼',
            'password.confirmed' => '兩次密碼輸入不一致',
        ]);

        $user = $request->user();

        if (! Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => '目前密碼錯誤',
            ], 422);
        }

        $user->password = $request->password;
        $user->save();

        return response()->json(['message' => '密碼已更新']);
    }

    /**
     * 格式化會員資料供前端使用
     */
    private function formatUserForResponse($user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone ?? '',
            'id_number' => $user->id_number ?? '',
            'store_id' => $user->store_id,
            'store' => $user->store ? $user->store->name : '',
        ];
    }
}
