<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    /**
     * 僅允許 super_admin、store_manager 進入管理後台
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->user() || ! $request->user()->isAdmin()) {
            if ($request->expectsJson()) {
                return response()->json(['message' => '無權限存取管理後台'], 403);
            }
            return redirect()->route('admin.login');
        }

        return $next($request);
    }
}
