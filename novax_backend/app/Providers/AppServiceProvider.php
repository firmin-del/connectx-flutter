<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;

/**
 * AppServiceProvider — Point d'entrée des configurations globales Laravel.
 *
 * C'est ici qu'on configure :
 *   - Le Rate Limiting nommé (utilisé dans les routes)
 *   - Les règles de validation personnalisées (si besoin)
 *   - Les macros globales
 */
class AppServiceProvider extends ServiceProvider
{
    /**
     * Enregistre les services de l'application.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap des services — appelé après l'enregistrement de tous les providers.
     */
    public function boot(): void
    {
        // ── Rate Limiters nommés ──────────────────────────────────
        // Ces limiteurs sont référencés dans routes/api.php
        // via Route::middleware('throttle:api') ou 'throttle:auth'

        // Limiter pour les routes d'authentification (login, register)
        // 10 tentatives par minute par IP — protection brute force
        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(10)
                        ->by($request->ip())
                        ->response(function () {
                            return response()->json([
                                'message' => 'Trop de tentatives de connexion. Réessayez dans 1 minute.',
                            ], 429);
                        });
        });

        // Limiter pour les routes API générales
        // 60 requêtes par minute par utilisateur (ou IP si non connecté)
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)
                        ->by($request->user()?->id ?: $request->ip())
                        ->response(function () {
                            return response()->json([
                                'message' => 'Trop de requêtes. Réessayez dans 1 minute.',
                            ], 429);
                        });
        });
    }
}
