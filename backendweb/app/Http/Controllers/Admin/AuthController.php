<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * 處理登入請求（僅允許 super_admin、store_manager）
     * Vue SPA 以 JSON 回應，表單提交則 redirect
     */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $remember = $request->boolean('remember');

        if (! Auth::attempt($credentials, $remember)) {
            throw ValidationException::withMessages([
                'email' => ['帳號或密碼錯誤。'],
            ]);
        }

        $user = Auth::user();

        if (! $user->isAdmin()) {
            Auth::logout();
            throw ValidationException::withMessages([
                'email' => ['此帳號無權限登入管理後台，僅限超級管理者與店家管理者。'],
            ]);
        }

        $request->session()->regenerate();

        if ($request->expectsJson()) {
            return response()->json(['message' => 'ok', 'redirect' => url('/admin/dashboard')]);
        }

        return redirect()->intended(route('admin.dashboard'));
    }

    /**
     * 登出（Vue SPA 以 JSON 回應）
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        if ($request->expectsJson()) {
            return response()->json(['message' => 'ok', 'redirect' => url('/admin/login')]);
        }

        return redirect('/admin/login');
    }
}
