<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Cache\RateLimiter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * RateLimitMiddleware — Protection contre les attaques DoS / brute force.
 *
 * Principe :
 *   - Chaque IP a un quota de requêtes par minute
 *   - Si le quota est dépassé → réponse 429 (Too Many Requests)
 *   - Les headers X-RateLimit-* informent le client de son quota restant
 *
 * Limites configurées :
 *   - Routes auth (login/register) : 10 tentatives / minute par IP
 *   - Routes API générales         : 60 requêtes / minute par IP
 */
class RateLimitMiddleware
{
    public function __construct(private RateLimiter $limiter) {}

    /**
     * @param string $type 'auth' ou 'api'
     */
    public function handle(Request $request, Closure $next, string $type = 'api'): Response
    {
        // Clé unique par IP + type de route
        $key = $type . ':' . $request->ip();

        // Limite selon le type
        $maxAttempts = match ($type) {
            'auth' => 10,   // 10 tentatives de login par minute
            'api'  => 60,   // 60 requêtes API par minute
            default => 60,
        };

        // Vérifie si la limite est atteinte
        if ($this->limiter->tooManyAttempts($key, $maxAttempts)) {
            $seconds = $this->limiter->availableIn($key);

            return response()->json([
                'message' => "Trop de requêtes. Réessayez dans {$seconds} secondes.",
                'retry_after' => $seconds,
            ], 429, [
                // Headers standards pour informer le client
                'X-RateLimit-Limit'     => $maxAttempts,
                'X-RateLimit-Remaining' => 0,
                'Retry-After'           => $seconds,
            ]);
        }

        // Incrémente le compteur (expire après 60 secondes)
        $this->limiter->hit($key, 60);

        // Continue vers le controller
        $response = $next($request);

        // Ajoute les headers de quota dans la réponse
        $response->headers->set('X-RateLimit-Limit', $maxAttempts);
        $response->headers->set(
            'X-RateLimit-Remaining',
            max(0, $maxAttempts - $this->limiter->attempts($key))
        );

        return $response;
    }
}
