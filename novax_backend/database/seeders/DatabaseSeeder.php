<?php

namespace Database\Seeders;

use App\Models\Chat;
use App\Models\Message;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

/**
 * DatabaseSeeder — Peuple la base de données avec des données de test.
 *
 * Crée :
 *   - 5 utilisateurs (dont un compte de test connu)
 *   - 3 conversations privées
 *   - Quelques messages dans chaque conversation
 *
 * Lancer avec : php artisan db:seed
 */
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ── Utilisateurs de test ──────────────────────────────────

        // Compte principal (pour se connecter facilement)
        $emmanuel = User::create([
            'name'         => 'Emmanuel GBODOU',
            'email'        => 'emmanuel@novax.com',
            'password'     => Hash::make('password123'),
            'phone_number' => '+22901020304',
            'is_online'    => true,
            'last_seen'    => now(),
        ]);

        // Membres de l'équipe NovaX
        $firmin = User::create([
            'name'         => 'Firmin SAMBIENI',
            'email'        => 'firmin@novax.com',
            'password'     => Hash::make('password123'),
            'phone_number' => '+22905060708',
            'is_online'    => true,
            'last_seen'    => now()->subMinutes(5),
        ]);

        $michael = User::create([
            'name'         => 'Michaël MIWANOU',
            'email'        => 'michael@novax.com',
            'password'     => Hash::make('password123'),
            'is_online'    => false,
            'last_seen'    => now()->subHours(2),
        ]);

        $ulrich = User::create([
            'name'         => 'Ulrich HANKPE',
            'email'        => 'ulrich@novax.com',
            'password'     => Hash::make('password123'),
            'is_online'    => false,
            'last_seen'    => now()->subHours(1),
        ]);

        $kamelia = User::create([
            'name'         => 'Kamélia ABOU',
            'email'        => 'kamelia@novax.com',
            'password'     => Hash::make('password123'),
            'is_online'    => true,
            'last_seen'    => now(),
        ]);

        // ── Conversations ─────────────────────────────────────────

        // Chat Emmanuel ↔ Firmin
        $chat1 = Chat::create(['is_group' => false, 'created_by' => $emmanuel->id]);
        $chat1->participants()->attach([$emmanuel->id, $firmin->id]);

        // Chat Emmanuel ↔ Michaël
        $chat2 = Chat::create(['is_group' => false, 'created_by' => $emmanuel->id]);
        $chat2->participants()->attach([$emmanuel->id, $michael->id]);

        // Groupe Équipe NovaX
        $chat3 = Chat::create(['name' => 'Équipe NovaX 🚀', 'is_group' => true, 'created_by' => $emmanuel->id]);
        $chat3->participants()->attach([$emmanuel->id, $firmin->id, $michael->id, $ulrich->id, $kamelia->id]);

        // ── Messages ──────────────────────────────────────────────

        // Messages dans chat1 (Emmanuel ↔ Firmin)
        $msgs1 = [
            ['sender' => $firmin,   'content' => 'Salut Emmanuel ! Les endpoints API sont prêts ?'],
            ['sender' => $emmanuel, 'content' => 'Oui ! /api/login et /api/register fonctionnent. Je teste /api/chats maintenant.'],
            ['sender' => $firmin,   'content' => 'Super ! Tu peux me donner l\'URL de ton serveur ?'],
            ['sender' => $emmanuel, 'content' => 'http://192.168.1.10:8000/api — on est sur le même WiFi'],
            ['sender' => $firmin,   'content' => 'Parfait, je mets à jour app_constants.dart 👍'],
        ];

        foreach ($msgs1 as $i => $msg) {
            Message::create([
                'chat_id'   => $chat1->id,
                'sender_id' => $msg['sender']->id,
                'content'   => $msg['content'],
                'type'      => 'text',
                'status'    => 'read',
                'created_at'=> now()->subMinutes(count($msgs1) - $i),
            ]);
        }

        // Messages dans chat2 (Emmanuel ↔ Michaël)
        $msgs2 = [
            ['sender' => $michael,  'content' => 'Emmanuel, le serveur Node.js tourne sur le port 3000'],
            ['sender' => $emmanuel, 'content' => 'OK ! J\'ai configuré CORS pour autoriser les requêtes Flutter'],
            ['sender' => $michael,  'content' => 'Le token JWT dans setAuth() est bien vérifié côté Node.js ✅'],
        ];

        foreach ($msgs2 as $i => $msg) {
            Message::create([
                'chat_id'   => $chat2->id,
                'sender_id' => $msg['sender']->id,
                'content'   => $msg['content'],
                'type'      => 'text',
                'status'    => 'delivered',
                'created_at'=> now()->subMinutes(count($msgs2) - $i),
            ]);
        }

        // Messages dans le groupe
        $msgs3 = [
            ['sender' => $emmanuel, 'content' => 'Bonjour l\'équipe ! Backend Laravel opérationnel 🎉'],
            ['sender' => $firmin,   'content' => 'App Flutter prête à se connecter ! 📱'],
            ['sender' => $michael,  'content' => 'Socket.io en ligne sur port 3000 ⚡'],
            ['sender' => $kamelia,  'content' => 'Les maquettes sont dans le dossier Wireframes 🎨'],
            ['sender' => $ulrich,   'content' => 'Pipeline Big Data configuré sur Vertex AI 🤖'],
            ['sender' => $emmanuel, 'content' => 'On est prêts pour la soutenance vendredi ! 🚀'],
        ];

        foreach ($msgs3 as $i => $msg) {
            Message::create([
                'chat_id'   => $chat3->id,
                'sender_id' => $msg['sender']->id,
                'content'   => $msg['content'],
                'type'      => 'text',
                'status'    => 'read',
                'created_at'=> now()->subMinutes(count($msgs3) - $i),
            ]);
        }

        $this->command->info('✅ Base de données peuplée avec succès !');
        $this->command->info('   Compte de test : emmanuel@novax.com / password123');
    }
}
