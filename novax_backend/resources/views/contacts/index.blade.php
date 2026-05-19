@extends('layouts.app')

@section('title', 'Contacts')

@section('content')
<div class="h-screen flex overflow-hidden bg-gray-100">

    {{-- Sidebar --}}
    <aside class="w-full md:w-96 flex flex-col bg-white border-r border-gray-200">
        <div class="flex items-center gap-3 px-4 py-3 bg-novax-700">
            <a href="{{ route('chat.index') }}" class="text-white">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
            </a>
            <div>
                <h2 class="text-white font-semibold">Nouveau message</h2>
                <p class="text-novax-200 text-xs">{{ $contacts->count() }} contact(s)</p>
            </div>
        </div>

        {{-- Recherche --}}
        <div class="px-3 py-2 bg-gray-50 border-b border-gray-100">
            <input type="text" id="contactSearch" placeholder="Rechercher un contact..."
                   class="w-full px-4 py-2 bg-white border border-gray-200 rounded-full text-sm
                          focus:outline-none focus:ring-2 focus:ring-novax-300"/>
        </div>

        {{-- Liste des contacts --}}
        <div class="flex-1 overflow-y-auto">
            @forelse ($contacts as $contact)
                <form method="POST" action="{{ route('chat.start') }}" class="contact-item"
                      data-name="{{ strtolower($contact->name) }}">
                    @csrf
                    <input type="hidden" name="participant_ids[]" value="{{ $contact->id }}"/>
                    <button type="submit"
                            class="w-full flex items-center gap-3 px-4 py-3 hover:bg-gray-50
                                   border-b border-gray-100 transition-colors text-left">
                        <div class="relative flex-shrink-0">
                            <div class="w-12 h-12 rounded-full bg-novax-600 flex items-center justify-center text-white font-bold">
                                {{ strtoupper(substr($contact->name, 0, 1)) }}
                            </div>
                            @if ($contact->is_online)
                                <span class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                            @endif
                        </div>
                        <div class="flex-1 min-w-0">
                            <p class="font-medium text-gray-800 text-sm">{{ $contact->name }}</p>
                            <p class="text-xs text-gray-400">
                                {{ $contact->is_online ? 'En ligne' : ($contact->last_seen ? 'Vu ' . $contact->last_seen->diffForHumans() : 'Hors ligne') }}
                            </p>
                        </div>
                    </button>
                </form>
            @empty
                <div class="flex flex-col items-center justify-center h-64 text-gray-400">
                    <p class="text-sm">Aucun contact disponible</p>
                </div>
            @endforelse
        </div>
    </aside>

    {{-- Zone droite vide --}}
    <main class="hidden md:flex flex-1 items-center justify-center bg-gray-50">
        <p class="text-gray-400 text-sm">Sélectionnez un contact pour démarrer une conversation</p>
    </main>
</div>
@endsection

@push('scripts')
<script>
    document.getElementById('contactSearch').addEventListener('input', function () {
        const q = this.value.toLowerCase();
        document.querySelectorAll('.contact-item').forEach(el => {
            el.style.display = el.dataset.name.includes(q) ? 'block' : 'none';
        });
    });
</script>
@endpush
