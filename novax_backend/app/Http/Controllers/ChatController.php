<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * ChatController — Gère les conversations et les messages.
 *
 * Endpoints :
 *   GET  /api/chats                    → Liste des conversations de l'utilisateur
 *   POST /api/chats                    → Créer une nouvelle conversation
 *   GET  /api/chats/{id}/messages      → Messages d'une conversation (paginés)
 *   POST /api/chats/{id}/messages      → Envoyer un message
 *   PUT  /api/chats/{id}/messages/read → Marquer les messages comme lus
 */
class ChatController extends Controller
{
    // ── PUT /api/chats/{id} ───────────────────────────────────────

    /**
     * Modifie le nom d'un groupe.
     * Seul le créateur peut modifier le groupe.
     */
    public function update(Request $request, int $chatId): JsonResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'min:1', 'max:255'],
        ]);

        $currentUser = $request->user();
        $chat = $currentUser->chats()->findOrFail($chatId);

        if (!$chat->is_group) {
            return response()->json(['message' => 'Seuls les groupes peuvent être modifiés.'], 422);
        }

        if ($chat->created_by !== $currentUser->id) {
            return response()->json(['message' => 'Seul le créateur peut modifier le groupe.'], 403);
        }

        $chat->update(['name' => $request->name]);
        $chat->load(['participants', 'lastMessage']);

        return response()->json([
            'chat' => $this->formatChat($chat, $currentUser->id),
        ], 200);
    }

    // ── DELETE /api/chats/{id} ────────────────────────────────────

    /**
     * Quitte une conversation (ou la supprime si créateur du groupe).
     */
    public function destroy(Request $request, int $chatId): JsonResponse
    {
        $currentUser = $request->user();
        $chat = $currentUser->chats()->findOrFail($chatId);

        if ($chat->is_group && $chat->created_by === $currentUser->id) {
            // Créateur du groupe → supprime le groupe entier
            $chat->participants()->detach();
            $chat->messages()->delete();
            $chat->delete();
            return response()->json(['message' => 'Groupe supprimé.'], 200);
        }

        // Sinon → quitte simplement la conversation
        $chat->participants()->detach($currentUser->id);
        return response()->json(['message' => 'Vous avez quitté la conversation.'], 200);
    }

    // ── POST /api/chats/{id}/participants ─────────────────────────

    /**
     * Ajoute un membre à un groupe.
     * Corps : { "user_id": 5 }
     */
    public function addParticipant(Request $request, int $chatId): JsonResponse
    {
        $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
        ]);

        $currentUser = $request->user();
        $chat = $currentUser->chats()->findOrFail($chatId);

        if (!$chat->is_group) {
            return response()->json(['message' => 'Impossible d\'ajouter un membre à une conversation privée.'], 422);
        }

        // Vérifie que le membre n'est pas déjà dans le groupe
        if ($chat->participants()->where('user_id', $request->user_id)->exists()) {
            return response()->json(['message' => 'Cet utilisateur est déjà membre du groupe.'], 422);
        }

        $chat->participants()->attach($request->user_id);
        $chat->load(['participants', 'lastMessage']);

        return response()->json([
            'chat' => $this->formatChat($chat, $currentUser->id),
        ], 200);
    }

    // ── DELETE /api/chats/{id}/participants/{userId} ──────────────

    /**
     * Retire un membre d'un groupe.
     * Seul le créateur peut retirer des membres.
     */
    public function removeParticipant(Request $request, int $chatId, int $userId): JsonResponse
    {
        $currentUser = $request->user();
        $chat = $currentUser->chats()->findOrFail($chatId);

        if ($chat->created_by !== $currentUser->id && $userId !== $currentUser->id) {
            return response()->json(['message' => 'Action non autorisée.'], 403);
        }

        $chat->participants()->detach($userId);

        return response()->json(['message' => 'Membre retiré du groupe.'], 200);
    }

    // ── GET /api/chats ────────────────────────────────────────────

    /**
     * Retourne toutes les conversations de l'utilisateur connecté.
     *
     * Réponse (200) — format attendu par Flutter (ChatModel.fromJson) :
     * [
     *   {
     *     "id": "1",
     *     "name": null,
     *     "is_group": false,
     *     "last_message_content": "Salut, ça va ?",
     *     "last_activity": "2026-05-20T14:32:00.000Z",
     *     "unread_count": 2,
     *     "participant_ids": ["1", "2"],
     *     "participants": [
     *       { "id": "2", "name": "Firmin", "is_online": true, ... }
     *     ]
     *   },
     *   ...
     * ]
     */
    public function index(Request $request): JsonResponse
    {
        $currentUser = $request->user();

        // Charge les conversations avec leurs participants et dernier message
        // eager loading (with) évite le problème N+1 (une requête par chat)
        $chats = $currentUser->chats()
            ->with(['participants', 'lastMessage.sender'])
            ->get()
            ->sortByDesc(function ($chat) {
                // Trie par date du dernier message (plus récent en haut)
                return $chat->lastMessage?->created_at ?? $chat->created_at;
            })
            ->values(); // Réindexe le tableau après le tri

        $formatted = $chats->map(function (Chat $chat) use ($currentUser) {
            return $this->formatChat($chat, $currentUser->id);
        });

        return response()->json($formatted, 200);
    }

    // ── POST /api/chats ───────────────────────────────────────────

    /**
     * Crée une nouvelle conversation privée ou de groupe.
     *
     * Corps attendu (JSON) :
     *   {
     *     "participant_ids": [2, 3],   ← IDs des autres participants
     *     "name": "Équipe NovaX",      ← optionnel, pour les groupes
     *     "is_group": false            ← optionnel, défaut false
     *   }
     *
     * Réponse (201) :
     *   { "chat": { ... } }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'participant_ids'   => ['required', 'array', 'min:1'],
            'participant_ids.*' => ['integer', 'exists:users,id'],
            'name'              => ['nullable', 'string', 'max:255'],
            'is_group'          => ['boolean'],
        ]);

        $currentUser = $request->user();
        $isGroup     = $request->boolean('is_group', false);

        // Pour une conversation privée, vérifie si elle existe déjà
        if (! $isGroup && count($request->participant_ids) === 1) {
            $otherId      = $request->participant_ids[0];
            $existingChat = $this->findPrivateChat($currentUser->id, $otherId);

            if ($existingChat) {
                return response()->json([
                    'chat' => $this->formatChat($existingChat, $currentUser->id),
                ], 200);
            }
        }

        // Crée la conversation
        $chat = Chat::create([
            'name'       => $request->name,
            'is_group'   => $isGroup,
            'created_by' => $currentUser->id,
        ]);

        // Ajoute les participants (l'utilisateur courant + les autres)
        $allParticipantIds = array_unique(
            array_merge([$currentUser->id], $request->participant_ids)
        );
        $chat->participants()->attach($allParticipantIds);

        // Recharge avec les relations
        $chat->load(['participants', 'lastMessage']);

        return response()->json([
            'chat' => $this->formatChat($chat, $currentUser->id),
        ], 201);
    }

    // ── GET /api/chats/{id}/messages ──────────────────────────────

    /**
     * Retourne les messages d'une conversation avec pagination.
     *
     * Query params :
     *   ?page=1&per_page=20
     *
     * Réponse (200) — format attendu par Flutter :
     * {
     *   "data": [
     *     {
     *       "id": "1",
     *       "chat_id": "1",
     *       "sender_id": "2",
     *       "receiver_id": "1",
     *       "content": "Salut !",
     *       "type": "text",
     *       "status": "read",
     *       "media_url": null,
     *       "created_at": "2026-05-20T14:32:00.000Z"
     *     },
     *     ...
     *   ],
     *   "current_page": 1,
     *   "last_page": 3,
     *   "total": 58
     * }
     */
    public function messages(Request $request, int $chatId): JsonResponse
    {
        $currentUser = $request->user();

        // Vérifie que l'utilisateur est bien participant de ce chat
        $chat = $currentUser->chats()->findOrFail($chatId);

        $perPage  = min($request->integer('per_page', 20), 50); // Max 50 par page
        $messages = $chat->messages()
            ->with('sender')
            ->orderBy('created_at', 'desc') // Plus récents en premier
            ->paginate($perPage);

        // Formate chaque message pour Flutter
        $formattedMessages = collect($messages->items())->map(function (Message $msg) {
            return $this->formatMessage($msg);
        })->reverse()->values(); // Remet dans l'ordre chronologique

        return response()->json([
            'data'         => $formattedMessages,
            'current_page' => $messages->currentPage(),
            'last_page'    => $messages->lastPage(),
            'total'        => $messages->total(),
        ], 200);
    }

    // ── POST /api/chats/{id}/messages ─────────────────────────────

    /**
     * Enregistre un message envoyé depuis Flutter ou le Web.
     *
     * Corps attendu (JSON) :
     *   {
     *     "content": "Bonjour !",
     *     "type": "text",
     *     "receiver_id": 2,
     *     "media_url": null
     *   }
     *
     * Réponse (201) :
     *   { "message": { ... } }
     */
    public function sendMessage(Request $request, int $chatId): JsonResponse
    {
        $request->validate([
            'content'     => ['required_without:media_url', 'nullable', 'string'],
            'type'        => ['required', 'in:text,image,video,file,voice'],
            'receiver_id' => ['nullable', 'integer', 'exists:users,id'],
            'media_url'   => ['nullable', 'string'],
        ]);

        $currentUser = $request->user();

        // Vérifie que l'utilisateur est participant
        $chat = $currentUser->chats()->findOrFail($chatId);

        // Crée le message en base
        $message = Message::create([
            'chat_id'     => $chat->id,
            'sender_id'   => $currentUser->id,
            'receiver_id' => $request->receiver_id,
            'content'     => $request->content,
            'type'        => $request->type ?? 'text',
            'status'      => 'sent', // Le serveur a reçu le message
            'media_url'   => $request->media_url,
        ]);

        $message->load('sender');

        return response()->json([
            'message' => $this->formatMessage($message),
        ], 201);
    }

    // ── PUT /api/chats/{id}/messages/read ─────────────────────────

    /**
     * Marque tous les messages non lus d'un chat comme "read".
     * Appelé quand l'utilisateur ouvre une conversation.
     *
     * Réponse (200) :
     *   { "message": "Messages marqués comme lus." }
     */
    public function markAsRead(Request $request, int $chatId): JsonResponse
    {
        $currentUser = $request->user();

        // Vérifie que l'utilisateur est participant
        $currentUser->chats()->findOrFail($chatId);

        // Met à jour uniquement les messages reçus (pas les siens)
        Message::where('chat_id', $chatId)
               ->where('sender_id', '!=', $currentUser->id)
               ->whereIn('status', ['sent', 'delivered'])
               ->update(['status' => 'read']);

        return response()->json([
            'message' => 'Messages marqués comme lus.',
        ], 200);
    }

    // ── Méthodes privées ──────────────────────────────────────────

    /**
     * Formate un Chat en tableau JSON pour Flutter.
     * Correspond exactement à ChatModel.fromJson() dans Flutter.
     */
    private function formatChat(Chat $chat, int $currentUserId): array
    {
        $lastMsg = $chat->lastMessage;

        return [
            'id'                   => (string) $chat->id,
            'name'                 => $chat->name,
            'is_group'             => $chat->is_group,
            'last_message_content' => $lastMsg?->content ?? '',
            'last_activity'        => ($lastMsg?->created_at ?? $chat->created_at)->toIso8601String(),
            'unread_count'         => $chat->unreadCountFor($currentUserId),
            'participant_ids'      => $chat->participants->pluck('id')->map(fn($id) => (string) $id)->toArray(),
            'participants'         => $chat->participants->map(fn(User $u) => [
                'id'              => (string) $u->id,
                'name'            => $u->name,
                'email'           => $u->email,
                'phone_number'    => $u->phone_number,
                'profile_picture' => $u->profile_picture_url,
                'is_online'       => $u->is_online,
                'last_seen'       => $u->last_seen?->toIso8601String(),
            ])->toArray(),
        ];
    }

    /**
     * Formate un Message en tableau JSON pour Flutter.
     * Correspond exactement à MessageModel.fromJson() dans Flutter.
     */
    private function formatMessage(Message $message): array
    {
        return [
            'id'          => (string) $message->id,
            'chat_id'     => (string) $message->chat_id,
            'sender_id'   => (string) $message->sender_id,
            'receiver_id' => $message->receiver_id ? (string) $message->receiver_id : null,
            'content'     => $message->content,
            'type'        => $message->type,
            'status'      => $message->status,
            'media_url'   => $message->media_url,
            'created_at'  => $message->created_at->toIso8601String(),
        ];
    }

    /**
     * Cherche une conversation privée existante entre deux utilisateurs.
     */
    private function findPrivateChat(int $userId1, int $userId2): ?Chat
    {
        return Chat::where('is_group', false)
            ->whereHas('participants', fn($q) => $q->where('user_id', $userId1))
            ->whereHas('participants', fn($q) => $q->where('user_id', $userId2))
            ->first();
    }
}
