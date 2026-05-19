<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Migration : Table users
 *
 * Stocke tous les utilisateurs NovaX.
 * Colonnes supplémentaires par rapport à la table Laravel par défaut :
 *   - phone_number    : numéro de téléphone (optionnel)
 *   - profile_picture : chemin vers la photo de profil (storage/)
 *   - is_online       : statut de connexion en temps réel
 *   - last_seen       : dernière activité (pour "vu à 14:32")
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();                                           // Clé primaire auto-incrémentée
            $table->string('name');                                 // Nom complet
            $table->string('email')->unique();                      // Email unique (identifiant)
            $table->timestamp('email_verified_at')->nullable();     // Vérification email (optionnel)
            $table->string('password');                             // Mot de passe hashé (bcrypt)
            $table->string('phone_number', 20)->nullable();        // Numéro de téléphone
            $table->string('profile_picture')->nullable();         // Chemin photo de profil
            $table->boolean('is_online')->default(false);          // En ligne / hors ligne
            $table->timestamp('last_seen')->nullable();            // Dernière connexion
            $table->rememberToken();                               // Token "se souvenir de moi"
            $table->timestamps();                                  // created_at, updated_at
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
