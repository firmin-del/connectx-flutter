<!DOCTYPE html>
<html lang="fr" class="h-full">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="csrf-token" content="<?php echo e(csrf_token()); ?>" />
    <title><?php echo $__env->yieldContent('title', 'NovaX'); ?> — Messagerie</title>

    
    <script src="https://cdn.tailwindcss.com"></script>

    
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        // Couleur primaire NovaX (rouge foncé #B4223F)
                        novax: {
                            50:  '#fdf2f4',
                            100: '#fce7eb',
                            200: '#f9d0d8',
                            300: '#f4a8b8',
                            400: '#ec7490',
                            500: '#e04a6e',
                            600: '#cc2a52',
                            700: '#b4223f', // ← couleur principale
                            800: '#961c36',
                            900: '#7e1b32',
                        },
                    },
                    fontFamily: {
                        // Police Questrial (comme Flutter)
                        sans: ['Questrial', 'sans-serif'],
                    },
                },
            },
        }
    </script>

    
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Questrial&display=swap" rel="stylesheet" />

    
    <script src="https://cdn.socket.io/4.7.5/socket.io.min.js"></script>

    <style>
        /* Scrollbar personnalisée (style WhatsApp) */
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #9ca3af; }

        /* Animation de l'indicateur "en train d'écrire" */
        @keyframes typing-dot {
            0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
            30%            { transform: translateY(-6px); opacity: 1; }
        }
        .typing-dot:nth-child(1) { animation: typing-dot 1.2s infinite 0s; }
        .typing-dot:nth-child(2) { animation: typing-dot 1.2s infinite 0.2s; }
        .typing-dot:nth-child(3) { animation: typing-dot 1.2s infinite 0.4s; }

        /* Animation d'apparition des bulles */
        @keyframes bubble-in {
            from { opacity: 0; transform: translateY(8px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }
        .bubble-animate { animation: bubble-in 0.18s ease-out; }
    </style>

    <?php echo $__env->yieldPushContent('styles'); ?>
</head>

<body class="h-full bg-gray-50 font-sans antialiased">

    
    <?php echo $__env->yieldContent('content'); ?>

    <?php echo $__env->yieldPushContent('scripts'); ?>
</body>
</html>
<?php /**PATH P:\forge_imen_2026\clone_whatsapp_base_code\novax_backend\resources\views/layouts/app.blade.php ENDPATH**/ ?>