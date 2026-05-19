<?php

use Laravel\Sanctum\Sanctum;

return [

    /*
    |--------------------------------------------------------------------------
    | Stateful Domains — Laravel Sanctum
    |--------------------------------------------------------------------------
    |
    | Ces domaines reçoivent des cookies de session Sanctum (pour les SPA).
    | Pour Flutter mobile (tokens Bearer), cette config n'est pas utilisée.
    | Pour l'interface Web Blade, on utilise les sessions Laravel classiques.
    |
    */
    'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', implode(',', [
        'localhost',
        'localhost:3000',
        'localhost:8000',
        '127.0.0.1',
        '127.0.0.1:8000',
        '::1',
    ]))),

    /*
    |--------------------------------------------------------------------------
    | Sanctum Guards
    |--------------------------------------------------------------------------
    |
    | 'web'  → sessions (interface Blade)
    | 'api'  → tokens Bearer (Flutter mobile)
    |
    */
    'guard' => ['web'],

    /*
    |--------------------------------------------------------------------------
    | Expiration des tokens (en minutes)
    |--------------------------------------------------------------------------
    |
    | null = les tokens n'expirent jamais (pratique pour le dev)
    | Pour la prod : mettre 10080 (7 jours) ou 43200 (30 jours)
    |
    */
    'expiration' => null,

    /*
    |--------------------------------------------------------------------------
    | Token Prefix
    |--------------------------------------------------------------------------
    */
    'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),

    /*
    |--------------------------------------------------------------------------
    | Sanctum Middleware
    |--------------------------------------------------------------------------
    */
    'middleware' => [
        'authenticate_session' => Laravel\Sanctum\Http\Middleware\AuthenticateSession::class,
        'encrypt_cookies'      => Illuminate\Cookie\Middleware\EncryptCookies::class,
        'validate_csrf_token'  => Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
    ],

];
