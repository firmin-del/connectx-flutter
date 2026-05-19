<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Modèle Chat — représente une conversation (privée ou groupe).
 *
 * Colonnes :
 *   id, name (null si privé), is_group, created_by, created_at, updated_at
 */
class Chat extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'is_group',
        'created_by',
    ];

    protected $casts = [
        'is_group' => 'boolean',
    ];

    // ── Relations ────────────────────────────────────────────────

    /**
     * Les participants de cette conversation.
     * Relation many-to-many via chat_participants.
     */
    public function participants()
    {
        return $this->belongsToMany(User::class, 'chat_participants', 'chat_id', 'user_id')
                    ->withTimestamps();
    }

    /**
     * Tous les messages de cette conversation.
     */
    public function messages()
    {
        return $this->hasMany(Message::class)->orderBy('created_at', 'asc');
    }

    /**
     * Le dernier message de cette conversation.
     * Utilisé pour l'aperçu dans la liste des chats.
     */
    public function lastMessage()
    {
        return $this->hasOne(Message::class)->latestOfMany();
    }

    /**
     * L'utilisateur qui a créé la conversation.
     */
    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    // ── Méthodes utilitaires ─────────────────────────────────────

    /**
     * Retourne le nombre de messages non lus pour un utilisateur donné.
     * Utilisé pour le badge dans la liste des conversations.
     *
     * @param int $userId
     * @return int
     */
    public function unreadCountFor(int $userId): int
    {
        return $this->messages()
                    ->where('sender_id', '!=', $userId)
                    ->where('status', '!=', 'read')
                    ->count();
    }

    /**
     * Retourne le nom à afficher pour un utilisateur donné.
     * - Groupe : retourne le nom du groupe
     * - Privé  : retourne le nom de l'autre participant
     *
     * @param int $currentUserId
     * @return string
     */
    public function getDisplayNameFor(int $currentUserId): string
    {
        if ($this->is_group) {
            return $this->name ?? 'Groupe sans nom';
        }

        $otherParticipant = $this->participants
            ->firstWhere('id', '!=', $currentUserId);

        return $otherParticipant?->name ?? 'Contact inconnu';
    }
}
