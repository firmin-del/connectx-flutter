<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * ContactController — Retourne la liste des utilisateurs NovaX.
 *
 * Endpoints :
 *   GET /api/contacts → Tous les utilisateurs sauf soi-même
 */
class ContactController extends Controller
{
    // ── GET /api/contacts ─────────────────────────────────────────

    /**
     * Retourne tous les utilisateurs NovaX (sauf l'utilisateur connecté).
     * Flutter les affiche dans ContactsScreen.
     *
     * Réponse (200) — format attendu par Flutter (ContactModel.fromJson) :
     * [
     *   {
     *     "id": "2",
     *     "name": "Firmin SAMBIENI",
     *     "email": "firmin@novax.com",
     *     "phone_number": "+22901020304",
     *     "profile_picture": null,
     *     "is_online": true,
     *     "last_seen": "2026-05-20T14:32:00.000Z"
     *   },
     *   ...
     * ]
     */
    public function index(Request $request): JsonResponse
    {
        $currentUser = $request->user();

        // Récupère tous les utilisateurs sauf l'utilisateur connecté
        // Triés par nom alphabétique
        $contacts = User::where('id', '!=', $currentUser->id)
            ->orderBy('name', 'asc')
            ->get();

        $formatted = $contacts->map(function (User $user) {
            return [
                'id'              => (string) $user->id,
                'name'            => $user->name,
                'email'           => $user->email,
                'phone_number'    => $user->phone_number,
                'profile_picture' => $user->profile_picture_url,
                'is_online'       => $user->is_online,
                'last_seen'       => $user->last_seen?->toIso8601String(),
            ];
        });

        return response()->json($formatted, 200);
    }
}
