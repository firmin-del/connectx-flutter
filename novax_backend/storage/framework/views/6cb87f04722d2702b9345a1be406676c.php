<?php $__env->startSection('title', 'Connexion'); ?>

<?php $__env->startSection('content'); ?>

<div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-novax-700 to-novax-900 px-4">

    <div class="w-full max-w-md">

        
        <div class="text-center mb-8">
            
            <div class="inline-flex items-center justify-center w-20 h-20 bg-white rounded-full shadow-lg mb-4">
                <svg class="w-10 h-10 text-novax-700" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/>
                </svg>
            </div>
            <h1 class="text-3xl font-bold text-white tracking-wide">NovaX</h1>
            <p class="text-novax-200 mt-1 text-sm">Messagerie instantanée sécurisée</p>
        </div>

        
        <div class="bg-white rounded-2xl shadow-2xl p-8">

            <h2 class="text-xl font-semibold text-gray-800 mb-6 text-center">Se connecter</h2>

            
            <?php if($errors->any()): ?>
                <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                    <?php $__currentLoopData = $errors->all(); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $error): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                        <p class="text-red-600 text-sm"><?php echo e($error); ?></p>
                    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                </div>
            <?php endif; ?>

            
            <?php if(session('success')): ?>
                <div class="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg">
                    <p class="text-green-600 text-sm"><?php echo e(session('success')); ?></p>
                </div>
            <?php endif; ?>

            
            <form method="POST" action="<?php echo e(route('login')); ?>" id="loginForm">
                <?php echo csrf_field(); ?>

                
                <div class="mb-4">
                    <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
                        Adresse email
                    </label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        value="<?php echo e(old('email')); ?>"
                        required
                        autocomplete="email"
                        placeholder="vous@exemple.com"
                        class="w-full px-4 py-3 border border-gray-300 rounded-xl text-gray-800
                               focus:outline-none focus:ring-2 focus:ring-novax-500 focus:border-transparent
                               transition-all duration-200 <?php $__errorArgs = ['email'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?> border-red-400 <?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>"
                    />
                </div>

                
                <div class="mb-6">
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
                        Mot de passe
                    </label>
                    <div class="relative">
                        <input
                            type="password"
                            id="password"
                            name="password"
                            required
                            autocomplete="current-password"
                            placeholder="••••••••"
                            class="w-full px-4 py-3 border border-gray-300 rounded-xl text-gray-800
                                   focus:outline-none focus:ring-2 focus:ring-novax-500 focus:border-transparent
                                   transition-all duration-200 pr-12"
                        />
                        
                        <button
                            type="button"
                            onclick="togglePassword('password')"
                            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                        >
                            <svg id="eye-password" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                      d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                      d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7
                                         -1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                            </svg>
                        </button>
                    </div>
                </div>

                
                <button
                    type="submit"
                    id="submitBtn"
                    class="w-full py-3 px-4 bg-novax-700 hover:bg-novax-800 text-white font-semibold
                           rounded-xl transition-all duration-200 flex items-center justify-center gap-2
                           focus:outline-none focus:ring-2 focus:ring-novax-500 focus:ring-offset-2
                           disabled:opacity-60 disabled:cursor-not-allowed"
                >
                    <span id="btnText">Se connecter</span>
                    
                    <svg id="btnSpinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                        <path class="opacity-75" fill="currentColor"
                              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                    </svg>
                </button>
            </form>

            
            <p class="text-center text-sm text-gray-500 mt-6">
                Pas encore de compte ?
                <a href="<?php echo e(route('register')); ?>"
                   class="text-novax-700 font-semibold hover:underline">
                    S'inscrire
                </a>
            </p>
        </div>

        
        <p class="text-center text-novax-200 text-xs mt-6">
            🔐 Vos messages sont chiffrés de bout en bout
        </p>
    </div>
</div>
<?php $__env->stopSection(); ?>

<?php $__env->startPush('scripts'); ?>
<script>
    // Affiche/masque le mot de passe
    function togglePassword(fieldId) {
        const field = document.getElementById(fieldId);
        field.type = field.type === 'password' ? 'text' : 'password';
    }

    // Affiche le spinner pendant la soumission du formulaire
    document.getElementById('loginForm').addEventListener('submit', function () {
        const btn     = document.getElementById('submitBtn');
        const text    = document.getElementById('btnText');
        const spinner = document.getElementById('btnSpinner');
        btn.disabled  = true;
        text.textContent = 'Connexion...';
        spinner.classList.remove('hidden');
    });
</script>
<?php $__env->stopPush(); ?>

<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH P:\forge_imen_2026\clone_whatsapp_base_code\novax_backend\resources\views/auth/login.blade.php ENDPATH**/ ?>