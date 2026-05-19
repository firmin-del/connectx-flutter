<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use Illuminate\Http\Request;
use Illuminate\View\View;

/**
 * WebChatController — Gère les vues Blade de l'interface Web.
 *
 * Différent de ChatController (qui gère l'API REST pour Flutter).
 * Ce controller retourne des vues HTML pour le navigateur.
 */
class WebChatController extends Controller
{
    /**
     * GET /chats — Liste des conversations (vue Blade).
     */
    public function index(Request $request): View
    {
        $user = $request->user();

        // Charge toutes les conversations avec participants et dernier message
        $chats = $user->chats()
            ->with(['participants', 'lastMessage'])
            ->get()
            ->sortByDesc(fn($c) => $c->lastMessage?->created_at ?? $c->created_at)
            ->values();

        return view('chat.index', compact('chats'));
    }

    /**
     * GET /chats/{id} — Affiche une conversation (vue Blade).
     */
    public function show(Request $request, int $id): View
    {
        $user = $request->user();

        // Vérifie que l'utilisateur est participant
        $chat = $user->chats()
            ->with(['participants', 'messages.sender'])
            ->findOrFail($id);

        // Nom à afficher dans l'AppBar
        $displayName = $chat->getDisplayNameFor($user->id);

        // L'autre participant (pour le statut en ligne)
        $otherUser = $chat->participants->firstWhere('id', '!=', $user->id);

        // Messages triés chronologiquement (les plus anciens en haut)
        $messages = $chat->messages->sortBy('created_at')->values();

        // Toutes les conversations pour la sidebar
        $allChats = $user->chats()
            ->with(['participants', 'lastMessage'])
            ->get()
            ->sortByDesc(fn($c) => $c->lastMessage?->created_at ?? $c->created_at)
            ->values();

        // Marque les messages comme lus
        $chat->messages()
             ->where('sender_id', '!=', $user->id)
             ->whereIn('status', ['sent', 'delivered'])
             ->update(['status' => 'read']);

        return view('chat.show', compact(
            'chat', 'displayName', 'otherUser', 'messages', 'allChats'
        ));
    }
}
