<?php

use App\Http\Controllers\WebAuthController;
use App\Http\Controllers\WebChatController;
use App\Http\Controllers\ContactController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes — NovaX Interface Web
|--------------------------------------------------------------------------
|
| Routes pour l'interface navigateur (Blade + TailwindCSS).
| Utilisent les sessions Laravel (pas les tokens Bearer).
|
*/

// ── Redirection racine ────────────────────────────────────────────────────
Route::get('/', fn() => redirect()->route('chat.index'));

// ── Routes d'authentification (publiques) ────────────────────────────────
Route::get('/login',    [WebAuthController::class, 'showLogin'])->name('login');
Route::post('/login',   [WebAuthController::class, 'login']);
Route::get('/register', [WebAuthController::class, 'showRegister'])->name('register');
Route::post('/register',[WebAuthController::class, 'register']);

// ── Routes protégées (session requise) ───────────────────────────────────
Route::middleware('auth')->group(function () {

    // Déconnexion
    Route::post('/logout', [WebAuthController::class, 'logout'])->name('logout');

    // Conversations
    Route::get('/chats',      [WebChatController::class, 'index'])->name('chat.index');
    Route::get('/chats/{id}', [WebChatController::class, 'show'])->name('chat.show');

    // Contacts (vue web)
    Route::get('/contacts', function () {
        $contacts = \App\Models\User::where('id', '!=', auth()->id())
            ->orderBy('name')->get();
        return view('contacts.index', compact('contacts'));
    })->name('contacts.index');

    // Démarrer une conversation depuis la page contacts
    // POST /chats/start → crée ou retrouve le chat privé → redirige vers /chats/{id}
    Route::post('/chats/start', function (\Illuminate\Http\Request $request) {
        $request->validate([
            'participant_ids'   => ['required', 'array', 'min:1'],
            'participant_ids.*' => ['integer', 'exists:users,id'],
        ]);

        $currentUser = auth()->user();
        $otherId     = $request->participant_ids[0];

        // Cherche une conversation privée existante
        $existing = \App\Models\Chat::where('is_group', false)
            ->whereHas('participants', fn($q) => $q->where('user_id', $currentUser->id))
            ->whereHas('participants', fn($q) => $q->where('user_id', $otherId))
            ->first();

        if ($existing) {
            return redirect()->route('chat.show', $existing->id);
        }

        // Crée une nouvelle conversation
        $chat = \App\Models\Chat::create([
            'is_group'   => false,
            'created_by' => $currentUser->id,
        ]);
        $chat->participants()->attach([$currentUser->id, $otherId]);

        return redirect()->route('chat.show', $chat->id);
    })->name('chat.start');
});
