<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Modèle Message — représente un message dans une conversation.
 *
 * Colonnes :
 *   id, chat_id, sender_id, receiver_id, content, type,
 *   status, media_url, created_at, updated_at
 *
 * Types de message : text | image | video | file | voice
 * Statuts          : sending | sent | delivered | read | failed
 */
class Message extends Model
{
    use HasFactory;

    protected $fillable = [
        'chat_id',
        'sender_id',
        'receiver_id',
        'content',
        'type',
        'status',
        'media_url',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // ── Relations ────────────────────────────────────────────────

    /**
     * La conversation à laquelle appartient ce message.
     */
    public function chat()
    {
        return $this->belongsTo(Chat::class);
    }

    /**
     * L'utilisateur qui a envoyé ce message.
     */
    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * L'utilisateur destinataire (null pour les groupes).
     */
    public function receiver()
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    // ── Accesseurs ───────────────────────────────────────────────

    /**
     * Retourne l'heure formatée pour l'affichage dans les bulles.
     * Format : "14:32"
     */
    public function getFormattedTimeAttribute(): string
    {
        return $this->created_at->format('H:i');
    }

    /**
     * Retourne true si ce message est une image.
     */
    public function getIsImageAttribute(): bool
    {
        return $this->type === 'image';
    }
}
