@extends('layouts.app')

@section('title', 'Conversations')

@section('content')
{{--
    Interface principale NovaX Web — style WhatsApp Web
    Layout : sidebar gauche (liste chats) + zone droite (conversation)
--}}
<div class="h-screen flex overflow-hidden bg-gray-100">

    {{-- ══════════════════════════════════════════════════════════
         SIDEBAR GAUCHE — Liste des conversations
    ══════════════════════════════════════════════════════════ --}}
    <aside class="w-full md:w-96 flex flex-col bg-white border-r border-gray-200 flex-shrink-0">

        {{-- En-tête sidebar --}}
        <div class="flex items-center justify-between px-4 py-3 bg-novax-700">
            {{-- Avatar utilisateur connecté --}}
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-novax-500 flex items-center justify-center text-white font-bold text-sm">
                    {{ strtoupper(substr(auth()->user()->name, 0, 1)) }}
                </div>
                <span class="text-white font-medium text-sm">{{ auth()->user()->name }}</span>
            </div>

            {{-- Actions --}}
            <div class="flex items-center gap-2">
                {{-- Nouveau chat --}}
                <a href="{{ route('contacts.index') }}"
                   title="Nouveau message"
                   class="p-2 text-white hover:bg-novax-600 rounded-full transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                    </svg>
                </a>

                {{-- Déconnexion --}}
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button type="submit" title="Se déconnecter"
                            class="p-2 text-white hover:bg-novax-600 rounded-full transition-colors">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                  d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                        </svg>
                    </button>
                </form>
            </div>
        </div>

        {{-- Barre de recherche --}}
        <div class="px-3 py-2 bg-gray-50 border-b border-gray-100">
            <div class="relative">
                <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"
                     fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
                <input
                    type="text"
                    id="searchInput"
                    placeholder="Rechercher une conversation..."
                    class="w-full pl-9 pr-4 py-2 bg-white border border-gray-200 rounded-full text-sm
                           text-gray-700 placeholder-gray-400 focus:outline-none focus:ring-2
                           focus:ring-novax-300 transition-all"
                />
            </div>
        </div>

        {{-- Liste des conversations --}}
        <div class="flex-1 overflow-y-auto" id="chatList">
            @forelse ($chats as $chat)
                @php
                    // Détermine le nom à afficher
                    $displayName = $chat->getDisplayNameFor(auth()->id());
                    // Initiale pour l'avatar
                    $initial     = strtoupper(substr($displayName, 0, 1));
                    // Dernier message
                    $lastMsg     = $chat->lastMessage;
                    $lastContent = $lastMsg?->content ?? 'Aucun message';
                    // Tronque à 40 caractères
                    if (strlen($lastContent) > 40) {
                        $lastContent = substr($lastContent, 0, 40) . '...';
                    }
                    // Heure formatée
                    $time = $lastMsg
                        ? ($lastMsg->created_at->isToday()
                            ? $lastMsg->created_at->format('H:i')
                            : ($lastMsg->created_at->isCurrentWeek()
                                ? $lastMsg->created_at->locale('fr')->isoFormat('ddd')
                                : $lastMsg->created_at->format('d/m')))
                        : '';
                    // Badge non-lu
                    $unread = $chat->unreadCountFor(auth()->id());
                @endphp

                <a href="{{ route('chat.show', $chat->id) }}"
                   class="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 border-b border-gray-100
                          transition-colors cursor-pointer chat-item
                          {{ request()->route('id') == $chat->id ? 'bg-gray-100' : '' }}"
                   data-name="{{ strtolower($displayName) }}">

                    {{-- Avatar --}}
                    <div class="relative flex-shrink-0">
                        <div class="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold
                                    {{ $chat->is_group ? 'bg-purple-500' : 'bg-novax-600' }}">
                            @if ($chat->is_group)
                                <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
                                </svg>
                            @else
                                {{ $initial }}
                            @endif
                        </div>
                        {{-- Indicateur en ligne --}}
                        @if (!$chat->is_group)
                            @php
                                $otherUser = $chat->participants->firstWhere('id', '!=', auth()->id());
                            @endphp
                            @if ($otherUser?->is_online)
                                <span class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                            @endif
                        @endif
                    </div>

                    {{-- Infos conversation --}}
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center justify-between">
                            <span class="font-medium text-gray-800 text-sm truncate">{{ $displayName }}</span>
                            <span class="text-xs text-gray-400 flex-shrink-0 ml-2">{{ $time }}</span>
                        </div>
                        <div class="flex items-center justify-between mt-0.5">
                            <p class="text-sm text-gray-500 truncate">{{ $lastContent }}</p>
                            {{-- Badge non-lu --}}
                            @if ($unread > 0)
                                <span class="ml-2 flex-shrink-0 w-5 h-5 bg-novax-700 text-white text-xs
                                             rounded-full flex items-center justify-center font-bold">
                                    {{ $unread > 9 ? '9+' : $unread }}
                                </span>
                            @endif
                        </div>
                    </div>
                </a>
            @empty
                {{-- État vide --}}
                <div class="flex flex-col items-center justify-center h-64 text-gray-400">
                    <svg class="w-16 h-16 mb-3 opacity-30" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/>
                    </svg>
                    <p class="text-sm">Aucune conversation</p>
                    <a href="{{ route('contacts.index') }}"
                       class="mt-3 text-novax-700 text-sm font-medium hover:underline">
                        Démarrer une conversation
                    </a>
                </div>
            @endforelse
        </div>
    </aside>

    {{-- ══════════════════════════════════════════════════════════
         ZONE DROITE — Écran d'accueil (aucun chat sélectionné)
    ══════════════════════════════════════════════════════════ --}}
    <main class="hidden md:flex flex-1 flex-col items-center justify-center bg-gray-50">
        <div class="text-center">
            <div class="w-32 h-32 bg-novax-100 rounded-full flex items-center justify-center mx-auto mb-6">
                <svg class="w-16 h-16 text-novax-400" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/>
                </svg>
            </div>
            <h2 class="text-2xl font-semibold text-gray-700 mb-2">NovaX Web</h2>
            <p class="text-gray-400 text-sm max-w-xs">
                Sélectionnez une conversation dans la liste pour commencer à discuter.
            </p>
            <p class="text-gray-300 text-xs mt-4">🔐 Chiffrement de bout en bout activé</p>
        </div>
    </main>

</div>
@endsection

@push('scripts')
<script>
    // Recherche en temps réel dans la liste des conversations
    document.getElementById('searchInput').addEventListener('input', function () {
        const query = this.value.toLowerCase().trim();
        document.querySelectorAll('.chat-item').forEach(function (item) {
            const name = item.getAttribute('data-name') || '';
            item.style.display = name.includes(query) ? 'flex' : 'none';
        });
    });
</script>
@endpush
