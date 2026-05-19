<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Migration : Table messages
 *
 * Stocke tous les messages de toutes les conversations.
 * Le contenu peut être chiffré (E2EE) — le serveur ne déchiffre pas.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();

            // Clés étrangères
            $table->foreignId('chat_id')
                  ->constrained('chats')
                  ->onDelete('cascade');                           // Supprime les messages si le chat est supprimé

            $table->foreignId('sender_id')
                  ->constrained('users')
                  ->onDelete('cascade');                           // Supprime les messages si l'expéditeur est supprimé

            $table->unsignedBigInteger('receiver_id')->nullable(); // null pour les groupes
            $table->foreign('receiver_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('set null');

            // Contenu du message
            // TEXT (pas VARCHAR) car les messages chiffrés peuvent être longs
            $table->text('content')->nullable();                   // Texte (peut être chiffré AES-256)
            $table->string('type', 20)->default('text');           // text | image | video | file | voice
            $table->string('media_url')->nullable();               // URL du fichier média (si type != text)

            // Statut de livraison (comme WhatsApp)
            // sending → sent → delivered → read | failed
            $table->string('status', 20)->default('sent');

            $table->timestamps();

            // Index pour accélérer les requêtes fréquentes
            $table->index('chat_id');                              // Récupérer les messages d'un chat
            $table->index('sender_id');                            // Messages d'un utilisateur
            $table->index('created_at');                           // Tri chronologique
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
