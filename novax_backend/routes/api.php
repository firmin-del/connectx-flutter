<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\ContactController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — NovaX
|--------------------------------------------------------------------------
|
| Toutes les routes API consommées par :
|   - L'application Flutter (mobile)
|   - L'interface Web (Blade + JS)
|
| Préfixe automatique : /api (configuré dans bootstrap/app.php)
|
| Authentification : Laravel Sanctum (tokens Bearer)
|   → Routes publiques  : pas de middleware
|   → Routes protégées  : middleware auth:sanctum
|
*/

// ── Routes PUBLIQUES (sans authentification) ──────────────────────────────
// throttle:auth = 10 tentatives par minute par IP (protection brute force)

Route::middleware('throttle:auth')->group(function () {
    Route::post('/login',    [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
});


// ── Routes PROTÉGÉES (authentification requise) ───────────────────────────
// throttle:api = 60 requêtes par minute par utilisateur
// auth:sanctum  = vérifie le token Bearer dans le header Authorization

Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {

    // ── Authentification ──────────────────────────────────────────
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);
    Route::put('/me',      [AuthController::class, 'updateProfile']); // Modifier profil
    Route::delete('/me',   [AuthController::class, 'deleteAccount']); // Supprimer compte

    // ── Contacts ──────────────────────────────────────────────────
    Route::get('/contacts', [ContactController::class, 'index']);

    // ── Conversations ─────────────────────────────────────────────
    Route::get('/chats',        [ChatController::class, 'index']);
    Route::post('/chats',       [ChatController::class, 'store']);
    Route::put('/chats/{id}',   [ChatController::class, 'update']);   // Modifier groupe
    Route::delete('/chats/{id}',[ChatController::class, 'destroy']);  // Quitter/supprimer

    // ── Membres du groupe ─────────────────────────────────────────
    Route::post('/chats/{id}/participants',          [ChatController::class, 'addParticipant']);
    Route::delete('/chats/{id}/participants/{userId}',[ChatController::class, 'removeParticipant']);

    // ── Messages ──────────────────────────────────────────────────
    Route::get('/chats/{id}/messages',      [ChatController::class, 'messages']);
    Route::post('/chats/{id}/messages',     [ChatController::class, 'sendMessage']);
    Route::put('/chats/{id}/messages/read', [ChatController::class, 'markAsRead']);
});
