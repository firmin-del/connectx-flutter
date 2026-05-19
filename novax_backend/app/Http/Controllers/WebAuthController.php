<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

/**
 * WebAuthController — Gère l'authentification pour l'interface Web (sessions).
 *
 * Différent de AuthController (qui gère l'API REST avec tokens pour Flutter).
 * Ce controller utilise les sessions Laravel classiques pour le navigateur.
 */
class WebAuthController extends Controller
{
    // ── GET /login ────────────────────────────────────────────────

    public function showLogin(): View|RedirectResponse
    {
        // Si déjà connecté, redirige vers les chats
        if (Auth::check()) {
            return redirect()->route('chat.index');
        }
        return view('auth.login');
    }

    // ── POST /login ───────────────────────────────────────────────

    public function login(Request $request): RedirectResponse
    {
        $request->validate([
            'email'    => ['required', 'email'],
            'password' => ['required'],
        ], [
            'email.required'    => 'L\'email est obligatoire.',
            'email.email'       => 'L\'email n\'est pas valide.',
            'password.required' => 'Le mot de passe est obligatoire.',
        ]);

        // Tentative de connexion avec les sessions Laravel
        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            $request->session()->regenerate();

            // Marque l'utilisateur comme en ligne
            Auth::user()->update(['is_online' => true, 'last_seen' => now()]);

            // Génère aussi un token API pour Socket.io (stocké en session)
            $token = Auth::user()->createToken('novax-web')->plainTextToken;
            session(['api_token' => $token]);

            return redirect()->intended(route('chat.index'));
        }

        // Identifiants incorrects
        return back()->withErrors([
            'email' => 'Email ou mot de passe incorrect.',
        ])->onlyInput('email');
    }

    // ── GET /register ─────────────────────────────────────────────

    public function showRegister(): View|RedirectResponse
    {
        if (Auth::check()) {
            return redirect()->route('chat.index');
        }
        return view('auth.register');
    }

    // ── POST /register ────────────────────────────────────────────

    public function register(Request $request): RedirectResponse
    {
        $request->validate([
            'name'                  => ['required', 'string', 'min:2', 'max:255'],
            'email'                 => ['required', 'email', 'unique:users,email'],
            'password'              => ['required', 'string', 'min:8', 'confirmed'],
            'phone_number'          => ['nullable', 'string', 'max:20'],
        ], [
            'name.required'      => 'Le nom est obligatoire.',
            'name.min'           => 'Le nom doit contenir au moins 2 caractères.',
            'email.required'     => 'L\'email est obligatoire.',
            'email.unique'       => 'Cet email est déjà utilisé.',
            'password.min'       => 'Le mot de passe doit contenir au moins 8 caractères.',
            'password.confirmed' => 'Les mots de passe ne correspondent pas.',
        ]);

        $user = User::create([
            'name'         => $request->name,
            'email'        => $request->email,
            'password'     => Hash::make($request->password),
            'phone_number' => $request->phone_number,
            'is_online'    => true,
            'last_seen'    => now(),
        ]);

        Auth::login($user);
        $request->session()->regenerate();

        $token = $user->createToken('novax-web')->plainTextToken;
        session(['api_token' => $token]);

        return redirect()->route('chat.index')
                         ->with('success', 'Compte créé avec succès. Bienvenue sur NovaX !');
    }

    // ── POST /logout ──────────────────────────────────────────────

    public function logout(Request $request): RedirectResponse
    {
        // Marque hors ligne
        Auth::user()?->update(['is_online' => false, 'last_seen' => now()]);

        // Révoque le token web
        Auth::user()?->tokens()->where('name', 'novax-web')->delete();

        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}
