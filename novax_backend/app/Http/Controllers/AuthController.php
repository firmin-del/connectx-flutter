<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * AuthController — Gère l'authentification des utilisateurs NovaX.
 *
 * Endpoints :
 *   POST /api/login    → Connexion
 *   POST /api/register → Inscription
 *   POST /api/logout   → Déconnexion
 *   GET  /api/me       → Profil de l'utilisateur connecté
 */
class AuthController extends Controller
{
    // ── POST /api/login ───────────────────────────────────────────

    /**
     * Connecte un utilisateur et retourne un token JWT (Sanctum).
     *
     * Corps attendu (JSON) :
     *   { "email": "...", "password": "..." }
     *
     * Réponse succès (200) :
     *   {
     *     "token": "1|abc123...",
     *     "user": {
     *       "id": 1,
     *       "name": "Emmanuel GBODOU",
     *       "email": "emmanuel@novax.com",
     *       "phone_number": "+229...",
     *       "profile_picture": null,
     *       "is_online": true
     *     }
     *   }
     *
     * Réponse erreur (422) :
     *   { "message": "Email ou mot de passe incorrect." }
     */
    public function login(Request $request): JsonResponse
    {
        // Validation des champs obligatoires
        $request->validate([
            'email'    => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        // Vérification des identifiants
        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            // Retourne une erreur 422 avec le message attendu par Flutter
            return response()->json([
                'message' => 'Email ou mot de passe incorrect.',
            ], 422);
        }

        // Marque l'utilisateur comme en ligne
        $user->update([
            'is_online' => true,
            'last_seen' => now(),
        ]);

        // Crée un token Sanctum (équivalent JWT pour Laravel)
        // Le token est stocké en base et envoyé au client
        $token = $user->createToken('novax-mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => $this->formatUser($user),
        ], 200);
    }

    // ── POST /api/register ────────────────────────────────────────

    /**
     * Crée un nouveau compte utilisateur.
     *
     * Corps attendu (JSON) :
     *   {
     *     "name": "Emmanuel GBODOU",
     *     "email": "emmanuel@novax.com",
     *     "password": "motdepasse123",
     *     "password_confirmation": "motdepasse123",
     *     "phone_number": "+22901020304"   ← optionnel
     *   }
     *
     * Réponse succès (201) :
     *   { "token": "...", "user": { ... } }
     *
     * Réponse erreur (422) :
     *   { "message": "...", "errors": { "email": ["L'email est déjà utilisé."] } }
     */
    public function register(Request $request): JsonResponse
    {
        // Validation complète
        $request->validate([
            'name'                  => ['required', 'string', 'min:2', 'max:255'],
            'email'                 => ['required', 'email', 'unique:users,email'],
            'password'              => ['required', 'string', 'min:8', 'confirmed'],
            'phone_number'          => ['nullable', 'string', 'max:20'],
        ], [
            // Messages d'erreur en français
            'name.required'         => 'Le nom est obligatoire.',
            'name.min'              => 'Le nom doit contenir au moins 2 caractères.',
            'email.required'        => 'L\'email est obligatoire.',
            'email.email'           => 'L\'email n\'est pas valide.',
            'email.unique'          => 'Cet email est déjà utilisé.',
            'password.required'     => 'Le mot de passe est obligatoire.',
            'password.min'          => 'Le mot de passe doit contenir au moins 8 caractères.',
            'password.confirmed'    => 'Les mots de passe ne correspondent pas.',
        ]);

        // Création de l'utilisateur
        // Hash::make() chiffre le mot de passe automatiquement
        $user = User::create([
            'name'         => $request->name,
            'email'        => $request->email,
            'password'     => Hash::make($request->password),
            'phone_number' => $request->phone_number,
            'is_online'    => true,
            'last_seen'    => now(),
        ]);

        // Génère un token pour connexion automatique après inscription
        $token = $user->createToken('novax-mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => $this->formatUser($user),
        ], 201);
    }

    // ── POST /api/logout ──────────────────────────────────────────

    /**
     * Déconnecte l'utilisateur : révoque le token actuel.
     *
     * Header requis : Authorization: Bearer {token}
     *
     * Réponse (200) :
     *   { "message": "Déconnexion réussie." }
     */
    public function logout(Request $request): JsonResponse
    {
        // Marque l'utilisateur comme hors ligne
        $request->user()->update([
            'is_online' => false,
            'last_seen' => now(),
        ]);

        // Révoque le token actuel (invalide côté serveur)
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Déconnexion réussie.',
        ], 200);
    }

    // ── GET /api/me ───────────────────────────────────────────────

    /**
     * Retourne le profil de l'utilisateur actuellement connecté.
     *
     * Header requis : Authorization: Bearer {token}
     *
     * Réponse (200) :
     *   { "user": { ... } }
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $this->formatUser($request->user()),
        ], 200);
    }

    // ── Méthode privée ────────────────────────────────────────────

    /**
     * Formate un utilisateur en tableau JSON.
     * Ce format est celui attendu par Flutter (UserModel.fromJson).
     *
     * Noms des champs : snake_case (convention Laravel/API REST)
     * Flutter les convertit en camelCase dans UserModel.fromJson()
     */
    private function formatUser(User $user): array
    {
        return [
            'id'              => $user->id,
            'name'            => $user->name,
            'email'           => $user->email,
            'phone_number'    => $user->phone_number,
            'profile_picture' => $user->profile_picture_url,
            'is_online'       => $user->is_online,
            'last_seen'       => $user->last_seen?->toIso8601String(),
        ];
    }
}
