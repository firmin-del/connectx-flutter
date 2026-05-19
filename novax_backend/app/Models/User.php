<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

/**
 * Modèle User — représente un utilisateur NovaX.
 *
 * Colonnes :
 *   id, name, email, password, phone_number, profile_picture,
 *   is_online, last_seen, created_at, updated_at
 */
class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Champs autorisés à l'assignation en masse.
     * (Sécurité : empêche l'injection de champs non voulus)
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone_number',
        'profile_picture',
        'is_online',
        'last_seen',
    ];

    /**
     * Champs cachés dans les réponses JSON.
     * (Ne jamais exposer le mot de passe dans l'API)
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Conversions automatiques de types.
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_seen'         => 'datetime',
        'is_online'         => 'boolean',
        'password'          => 'hashed',
    ];

    // ── Relations ────────────────────────────────────────────────

    /**
     * Les conversations auxquelles cet utilisateur participe.
     * Relation many-to-many via la table pivot chat_participants.
     */
    public function chats()
    {
        return $this->belongsToMany(Chat::class, 'chat_participants', 'user_id', 'chat_id')
                    ->withTimestamps();
    }

    /**
     * Les messages envoyés par cet utilisateur.
     */
    public function messages()
    {
        return $this->hasMany(Message::class, 'sender_id');
    }

    // ── Accesseurs ───────────────────────────────────────────────

    /**
     * Retourne l'URL de la photo de profil ou null.
     */
    public function getProfilePictureUrlAttribute(): ?string
    {
        if ($this->profile_picture) {
            return asset('storage/' . $this->profile_picture);
        }
        return null;
    }

    /**
     * Formate last_seen pour l'affichage.
     */
    public function getLastSeenFormattedAttribute(): string
    {
        if ($this->is_online) {
            return 'En ligne';
        }
        if ($this->last_seen) {
            return $this->last_seen->diffForHumans();
        }
        return 'Jamais connecté';
    }
}
