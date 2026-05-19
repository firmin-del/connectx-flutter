<?php

use App\Http\Middleware\RateLimitMiddleware;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

/*
|--------------------------------------------------------------------------
| Bootstrap de l'application Laravel — NovaX
|--------------------------------------------------------------------------
|
| Configure :
|   - Le préfixe /api pour toutes les routes API
|   - Le middleware Rate Limiting sur les routes auth et api
|   - La gestion des exceptions (réponses JSON pour l'API)
|
*/

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        // Routes web (Blade) — interface navigateur
        web: __DIR__ . '/../routes/web.php',
        // Routes API (JSON) — consommées par Flutter
        api: __DIR__ . '/../routes/api.php',
        // Préfixe automatique /api pour toutes les routes dans api.php
        apiPrefix: 'api',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {

        // ── Middleware globaux ────────────────────────────────────
        // CORS : autorise Flutter à appeler l'API depuis un autre domaine
        $middleware->api(prepend: [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        ]);

        // ── Alias de middleware ───────────────────────────────────
        // Permet d'utiliser ->middleware('rate.auth') dans les routes
        $middleware->alias([
            'rate.auth' => RateLimitMiddleware::class . ':auth',
            'rate.api'  => RateLimitMiddleware::class . ':api',
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {

        // ── Réponses JSON pour les erreurs API ────────────────────
        // Si une route /api/* lève une exception → retourne du JSON
        // (pas une page HTML d'erreur)
        $exceptions->render(function (\Illuminate\Auth\AuthenticationException $e, $request) {
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'message' => 'Non authentifié. Token manquant ou invalide.',
                ], 401);
            }
        });

        $exceptions->render(function (\Illuminate\Validation\ValidationException $e, $request) {
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'message' => 'Données invalides.',
                    'errors'  => $e->errors(),
                ], 422);
            }
        });

        $exceptions->render(function (\Illuminate\Database\Eloquent\ModelNotFoundException $e, $request) {
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'message' => 'Ressource introuvable.',
                ], 404);
            }
        });
    })
    ->create();
