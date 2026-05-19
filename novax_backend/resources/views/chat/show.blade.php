@extends('layouts.app')

@section('title', $displayName)

@section('content')
<div class="h-screen flex overflow-hidden bg-gray-100">

    {{-- SIDEBAR GAUCHE (identique à index.blade.php) --}}
    <aside class="hidden md:flex w-96 flex-col bg-white border-r border-gray-200 flex-shrink-0">
        <div class="flex items-center justify-between px-4 py-3 bg-novax-700">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-novax-500 flex items-center justify-center text-white font-bold text-sm">
                    {{ strtoupper(substr(auth()->user()->name, 0, 1)) }}
                </div>
                <span class="text-white font-medium text-sm">{{ auth()->user()->name }}</span>
            </div>
            <div class="flex items-center gap-2">
                <a href="{{ route('contacts.index') }}" class="p-2 text-white hover:bg-novax-600 rounded-full transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                    </svg>
                </a>
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button type="submit" class="p-2 text-white hover:bg-novax-600 rounded-full transition-colors">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                        </svg>
                    </button>
                </form>
            </div>
        </div>
        <div class="px-3 py-2 bg-gray-50 border-b border-gray-100">
            <input type="text" placeholder="Rechercher..." class="w-full pl-4 pr-4 py-2 bg-white border border-gray-200 rounded-full text-sm focus:outline-none focus:ring-2 focus:ring-novax-300"/>
        </div>
        <div class="flex-1 overflow-y-auto">
            @foreach ($allChats as $c)
                @php $cName = $c->getDisplayNameFor(auth()->id()); @endphp
                <a href="{{ route('chat.show', $c->id) }}"
                   class="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 border-b border-gray-100 transition-colors {{ $c->id === $chat->id ? 'bg-gray-100' : '' }}">
                    <div class="w-12 h-12 rounded-full bg-novax-600 flex items-center justify-center text-white font-bold flex-shrink-0">
                        {{ strtoupper(substr($cName, 0, 1)) }}
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="font-medium text-gray-800 text-sm truncate">{{ $cName }}</p>
                        <p class="text-xs text-gray-400 truncate">{{ Str::limit($c->lastMessage?->content ?? 'Aucun message', 35) }}</p>
                    </div>
                </a>
            @endforeach
        </div>
    </aside>

    {{-- ZONE PRINCIPALE — Conversation --}}
    <main class="flex-1 flex flex-col min-w-0">

        {{-- AppBar du chat --}}
        <div class="flex items-center gap-3 px-4 py-3 bg-novax-700 shadow-sm flex-shrink-0">
            <a href="{{ route('chat.index') }}" class="md:hidden text-white mr-1">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
            </a>
            {{-- Avatar --}}
            <div class="relative">
                <div class="w-10 h-10 rounded-full bg-novax-500 flex items-center justify-center text-white font-bold text-sm">
                    {{ strtoupper(substr($displayName, 0, 1)) }}
                </div>
                @if ($otherUser?->is_online)
                    <span class="absolute bottom-0 right-0 w-2.5 h-2.5 bg-green-400 border-2 border-novax-700 rounded-full"></span>
                @endif
            </div>
            {{-- Nom + statut --}}
            <div class="flex-1">
                <p class="text-white font-semibold text-sm">{{ $displayName }}</p>
                <p class="text-novax-200 text-xs" id="statusText">
                    {{ $otherUser?->is_online ? 'En ligne' : ($otherUser?->last_seen ? 'Vu ' . $otherUser->last_seen->diffForHumans() : 'Hors ligne') }}
                </p>
            </div>
        </div>

        {{-- Zone des messages --}}
        <div class="flex-1 overflow-y-auto px-4 py-4 space-y-1" id="messagesContainer"
             style="background-image: url('data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23b4223f\' fill-opacity=\'0.03\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E');">

            {{-- Messages chargés depuis la base --}}
            @foreach ($messages as $message)
                @php $isMine = $message->sender_id === auth()->id(); @endphp
                <div class="flex {{ $isMine ? 'justify-end' : 'justify-start' }} bubble-animate" data-msg-id="{{ $message->id }}">
                    <div class="max-w-xs lg:max-w-md xl:max-w-lg">
                        {{-- Bulle de message --}}
                        <div class="px-3 py-2 rounded-2xl shadow-sm
                            {{ $isMine
                                ? 'bg-novax-700 text-white rounded-br-sm'
                                : 'bg-white text-gray-800 rounded-bl-sm' }}">

                            @if ($message->type === 'image' && $message->media_url)
                                <img src="{{ $message->media_url }}" alt="Image" class="rounded-xl max-w-full mb-1" />
                            @else
                                <p class="text-sm leading-relaxed break-words">{{ $message->content }}</p>
                            @endif

                            {{-- Heure + statut --}}
                            <div class="flex items-center justify-end gap-1 mt-1">
                                <span class="text-xs {{ $isMine ? 'text-novax-200' : 'text-gray-400' }}">
                                    {{ $message->created_at->format('H:i') }}
                                </span>
                                @if ($isMine)
                                    {{-- Coches de statut --}}
                                    @if ($message->status === 'read')
                                        <span class="text-blue-300 text-xs">✓✓</span>
                                    @elseif ($message->status === 'delivered')
                                        <span class="text-novax-200 text-xs">✓✓</span>
                                    @else
                                        <span class="text-novax-200 text-xs">✓</span>
                                    @endif
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
            @endforeach

            {{-- Indicateur "en train d'écrire" (masqué par défaut) --}}
            <div id="typingIndicator" class="hidden flex justify-start">
                <div class="bg-white rounded-2xl rounded-bl-sm px-4 py-3 shadow-sm flex items-center gap-1">
                    <span class="typing-dot w-2 h-2 bg-gray-400 rounded-full inline-block"></span>
                    <span class="typing-dot w-2 h-2 bg-gray-400 rounded-full inline-block"></span>
                    <span class="typing-dot w-2 h-2 bg-gray-400 rounded-full inline-block"></span>
                </div>
            </div>
        </div>

        {{-- Zone de saisie --}}
        <div class="flex-shrink-0 px-4 py-3 bg-white border-t border-gray-200">
            <form id="messageForm" class="flex items-end gap-2">
                @csrf
                {{-- Bouton emoji (décoratif) --}}
                <button type="button" class="p-2 text-gray-400 hover:text-novax-600 transition-colors flex-shrink-0">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                </button>

                {{-- Champ de saisie --}}
                <div class="flex-1 relative">
                    <textarea
                        id="messageInput"
                        placeholder="Écrire un message..."
                        rows="1"
                        class="w-full px-4 py-2.5 bg-gray-100 border border-transparent rounded-2xl text-sm
                               text-gray-800 placeholder-gray-400 resize-none focus:outline-none
                               focus:ring-2 focus:ring-novax-300 focus:bg-white transition-all"
                        style="max-height: 120px; overflow-y: auto;"
                    ></textarea>
                </div>

                {{-- Bouton envoyer --}}
                <button type="submit" id="sendBtn"
                        class="p-2.5 bg-novax-700 hover:bg-novax-800 text-white rounded-full
                               transition-all duration-200 flex-shrink-0 shadow-sm
                               focus:outline-none focus:ring-2 focus:ring-novax-500 focus:ring-offset-2">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                    </svg>
                </button>
            </form>
        </div>

    </main>
</div>
@endsection

@push('scripts')
<script>
// ══════════════════════════════════════════════════════════════
// NovaX Web — Script de messagerie temps réel
// Connexion Socket.io + envoi/réception de messages
// ══════════════════════════════════════════════════════════════

const CHAT_ID      = {{ $chat->id }};
const CURRENT_USER = {
    id:   {{ auth()->id() }},
    name: "{{ auth()->user()->name }}"
};
const SOCKET_URL   = "{{ config('app.socket_url', 'http://localhost:3000') }}";
const API_TOKEN    = "{{ session('api_token') }}";  // Token Sanctum stocké en session

// ── Connexion Socket.io ───────────────────────────────────────
const socket = io(SOCKET_URL, {
    auth: { token: API_TOKEN },
    transports: ['websocket'],
    reconnection: true,
    reconnectionDelay: 1000,
});

socket.on('connect', () => {
    console.log('[Socket] ✅ Connecté au serveur NovaX');
    // Rejoint la room de cette conversation
    socket.emit('join_chat', { chat_id: CHAT_ID });
});

socket.on('disconnect', () => {
    console.log('[Socket] ❌ Déconnecté');
});

// ── Réception d'un nouveau message ───────────────────────────
socket.on('new_message', (data) => {
    if (data.chat_id == CHAT_ID) {
        appendMessage(data, false);  // false = message reçu (bulle gauche)
        scrollToBottom();
        // Notifie le serveur que le message a été lu
        socket.emit('message_read', { chat_id: CHAT_ID, message_id: data.id });
    }
});

// ── Indicateur "en train d'écrire" ───────────────────────────
socket.on('typing', (chatId) => {
    if (chatId == CHAT_ID) {
        document.getElementById('typingIndicator').classList.remove('hidden');
        scrollToBottom();
    }
});

socket.on('stop_typing', (chatId) => {
    if (chatId == CHAT_ID) {
        document.getElementById('typingIndicator').classList.add('hidden');
    }
});

// ── Statut en ligne ───────────────────────────────────────────
socket.on('user_online', (userId) => {
    if (userId == {{ $otherUser?->id ?? 'null' }}) {
        document.getElementById('statusText').textContent = 'En ligne';
    }
});

socket.on('user_offline', (userId) => {
    if (userId == {{ $otherUser?->id ?? 'null' }}) {
        document.getElementById('statusText').textContent = 'Hors ligne';
    }
});

// ── Envoi d'un message ────────────────────────────────────────
const messageForm  = document.getElementById('messageForm');
const messageInput = document.getElementById('messageInput');
let typingTimer    = null;

messageForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const content = messageInput.value.trim();
    if (!content) return;

    // Affiche immédiatement (Optimistic Update)
    const tempId = 'temp_' + Date.now();
    appendMessage({
        id:         tempId,
        sender_id:  CURRENT_USER.id,
        content:    content,
        type:       'text',
        status:     'sending',
        created_at: new Date().toISOString(),
    }, true);

    messageInput.value = '';
    messageInput.style.height = 'auto';
    scrollToBottom();

    // Arrête l'indicateur de frappe
    socket.emit('stop_typing', CHAT_ID);
    clearTimeout(typingTimer);

    try {
        // Envoie via l'API REST Laravel (persistance en base)
        const response = await fetch(`/api/chats/${CHAT_ID}/messages`, {
            method: 'POST',
            headers: {
                'Content-Type':  'application/json',
                'Authorization': `Bearer ${API_TOKEN}`,
                'X-CSRF-TOKEN':  document.querySelector('meta[name="csrf-token"]').content,
            },
            body: JSON.stringify({ content, type: 'text' }),
        });

        const data = await response.json();

        if (response.ok) {
            // Met à jour le message temporaire avec l'ID réel
            const tempEl = document.querySelector(`[data-msg-id="${tempId}"]`);
            if (tempEl) {
                tempEl.setAttribute('data-msg-id', data.message.id);
                const statusEl = tempEl.querySelector('.msg-status');
                if (statusEl) statusEl.textContent = '✓';
            }
            // Émet via Socket.io pour que les autres reçoivent en temps réel
            socket.emit('send_message', data.message);
        }
    } catch (err) {
        console.error('[NovaX] Erreur envoi message:', err);
        // Marque le message comme échoué
        const tempEl = document.querySelector(`[data-msg-id="${tempId}"]`);
        if (tempEl) {
            const statusEl = tempEl.querySelector('.msg-status');
            if (statusEl) { statusEl.textContent = '✗'; statusEl.classList.add('text-red-300'); }
        }
    }
});

// ── Indicateur de frappe ──────────────────────────────────────
messageInput.addEventListener('input', () => {
    // Auto-resize du textarea
    messageInput.style.height = 'auto';
    messageInput.style.height = Math.min(messageInput.scrollHeight, 120) + 'px';

    // Émet "typing" et arrête après 2 secondes d'inactivité
    socket.emit('typing', CHAT_ID);
    clearTimeout(typingTimer);
    typingTimer = setTimeout(() => socket.emit('stop_typing', CHAT_ID), 2000);
});

// Envoyer avec Entrée (Shift+Entrée = nouvelle ligne)
messageInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        messageForm.dispatchEvent(new Event('submit'));
    }
});

// ── Fonctions utilitaires ─────────────────────────────────────

/**
 * Crée et insère une bulle de message dans le DOM.
 * @param {Object} msg    - Données du message
 * @param {boolean} isMine - true = bulle droite (envoyé), false = bulle gauche (reçu)
 */
function appendMessage(msg, isMine) {
    const container = document.getElementById('messagesContainer');
    const typingEl  = document.getElementById('typingIndicator');

    const time = new Date(msg.created_at).toLocaleTimeString('fr-FR', {
        hour: '2-digit', minute: '2-digit'
    });

    const statusIcon = msg.status === 'read'      ? '<span class="msg-status text-blue-300 text-xs">✓✓</span>'
                     : msg.status === 'delivered'  ? '<span class="msg-status text-novax-200 text-xs">✓✓</span>'
                     : msg.status === 'sending'    ? '<span class="msg-status text-novax-200 text-xs opacity-60">⏳</span>'
                     :                               '<span class="msg-status text-novax-200 text-xs">✓</span>';

    const bubbleHtml = `
        <div class="flex ${isMine ? 'justify-end' : 'justify-start'} bubble-animate" data-msg-id="${msg.id}">
            <div class="max-w-xs lg:max-w-md xl:max-w-lg">
                <div class="px-3 py-2 rounded-2xl shadow-sm
                    ${isMine ? 'bg-novax-700 text-white rounded-br-sm' : 'bg-white text-gray-800 rounded-bl-sm'}">
                    <p class="text-sm leading-relaxed break-words">${escapeHtml(msg.content)}</p>
                    <div class="flex items-center justify-end gap-1 mt-1">
                        <span class="text-xs ${isMine ? 'text-novax-200' : 'text-gray-400'}">${time}</span>
                        ${isMine ? statusIcon : ''}
                    </div>
                </div>
            </div>
        </div>`;

    // Insère avant l'indicateur de frappe
    typingEl.insertAdjacentHTML('beforebegin', bubbleHtml);
}

/** Fait défiler vers le bas de la conversation */
function scrollToBottom() {
    const container = document.getElementById('messagesContainer');
    container.scrollTop = container.scrollHeight;
}

/** Échappe le HTML pour éviter les injections XSS */
function escapeHtml(text) {
    const div = document.createElement('div');
    div.appendChild(document.createTextNode(text));
    return div.innerHTML;
}

// Scroll initial vers le bas
scrollToBottom();

// Quitte la room quand on ferme la page
window.addEventListener('beforeunload', () => {
    socket.emit('leave_chat', { chat_id: CHAT_ID });
});
</script>
@endpush
