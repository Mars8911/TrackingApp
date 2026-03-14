<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

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

        $user = Auth::user();

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
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'store_id' => $user->store_id,
            ],
        ]);
    }
}
