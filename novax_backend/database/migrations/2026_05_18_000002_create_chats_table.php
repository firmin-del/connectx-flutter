<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Migration : Table chats + chat_participants
 *
 * chats            → une conversation (privée ou groupe)
 * chat_participants → table pivot many-to-many (user ↔ chat)
 */
return new class extends Migration
{
    public function up(): void
    {
        // ── Table chats ───────────────────────────────────────────
        Schema::create('chats', function (Blueprint $table) {
            $table->id();
            $table->string('name')->nullable();                    // Nom du groupe (null si privé)
            $table->boolean('is_group')->default(false);           // true = groupe, false = privé
            $table->foreignId('created_by')                        // Qui a créé la conversation
                  ->constrained('users')
                  ->onDelete('cascade');
            $table->timestamps();
        });

        // ── Table pivot chat_participants ─────────────────────────
        // Relie les utilisateurs aux conversations (many-to-many)
        Schema::create('chat_participants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('chat_id')
                  ->constrained('chats')
                  ->onDelete('cascade');                           // Si le chat est supprimé → supprime les participations
            $table->foreignId('user_id')
                  ->constrained('users')
                  ->onDelete('cascade');                           // Si l'utilisateur est supprimé → supprime ses participations
            $table->timestamps();

            // Un utilisateur ne peut être qu'une fois dans un chat
            $table->unique(['chat_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chat_participants');
        Schema::dropIfExists('chats');
    }
};
