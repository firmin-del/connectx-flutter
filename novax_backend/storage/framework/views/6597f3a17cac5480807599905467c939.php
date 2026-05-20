<?php $__env->startSection('title', 'Inscription'); ?>

<?php $__env->startSection('content'); ?>
<div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-novax-700 to-novax-900 px-4 py-8">

    <div class="w-full max-w-md">

        
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-20 h-20 bg-white rounded-full shadow-lg mb-4">
                <svg class="w-10 h-10 text-novax-700" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/>
                </svg>
            </div>
            <h1 class="text-3xl font-bold text-white tracking-wide">NovaX</h1>
            <p class="text-novax-200 mt-1 text-sm">Créer votre compte</p>
        </div>

        
        <div class="bg-white rounded-2xl shadow-2xl p-8">

            <h2 class="text-xl font-semibold text-gray-800 mb-6 text-center">Inscription</h2>

            
            <?php if($errors->any()): ?>
                <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                    <?php $__currentLoopData = $errors->all(); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $error): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                        <p class="text-red-600 text-sm"><?php echo e($error); ?></p>
                    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                </div>
            <?php endif; ?>

            <form method="POST" action="<?php echo e(route('register')); ?>" id="registerForm">
                <?php echo csrf_field(); ?>

                
                <div class="mb-4">
                    <label for="name" class="block text-sm font-medium text-gray-700 mb-1">
                        Nom complet <span class="text-red-500">*</span>
                    </label>
                    <input
                        type="text"
                        id="name"
                        name="name"
                        value="<?php echo e(old('name')); ?>"
                        required
                        minlength="2"
                        placeholder="Emmanuel GBODOU"
                        class="w-full px-4 py-3 border border-gray-300 rounded-xl text-gray-800
                               focus:outline-none focus:ring-2 focus:ring-novax-500 focus:border-transparent
                               transition-all duration-200 <?php $__errorArgs = ['name'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?> border-red-400 <?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>"
                    />
                </div>

                
                <div class="mb-4">
                    <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
                        Adresse email <span class="text-red-500">*</span>
                    </label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        value="<?php echo e(old('email')); ?>"
                        required
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

                
                <div class="mb-4">
                    <label for="phone_number" class="block text-sm font-medium text-gray-700 mb-1">
                        Numéro de téléphone
                        <span class="text-gray-400 font-normal">(optionnel)</span>
                    </label>
                    <input
                        type="tel"
                        id="phone_number"
                        name="phone_number"
                        value="<?php echo e(old('phone_number')); ?>"
                        placeholder="+229 01 02 03 04"
                        class="w-full px-4 py-3 border border-gray-300 rounded-xl text-gray-800
                               focus:outline-none focus:ring-2 focus:ring-novax-500 focus:border-transparent
                               transition-all duration-200"
                    />
                </div>

                
                <div class="mb-4">
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
                        Mot de passe <span class="text-red-500">*</span>
                    </label>
                    <div class="relative">
                        <input
                            type="password"
                            id="password"
                            name="password"
                            required
                            minlength="8"
                            placeholder="Minimum 8 caractères"
                            class="w-full px-4 py-3 border border-gray-300 rounded-xl text-gray-800
                                   focus:outline-none focus:ring-2 focus:ring-novax-500 focus:border-transparent
                                   transition-all duration-200 pr-12 <?php $__errorArgs = ['password'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?> border-red-400 <?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>"
                        />
                        <button type="button" onclick="togglePassword('password')"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                      d="M15 12a3 3 0 11-6 0 3 3 0 016 0zM2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                            </svg>
                        </button>
                    </div>
                    
                    <div class="mt-2 flex gap-1" id="strengthBars">
                        <div class="h-1 flex-1 rounded bg-gray-200" id="bar1"></div>
                        <div class="h-1 flex-1 rounded bg-gray-200" id="bar2"></div>
                        <div class="h-1 flex-1 rounded bg-gray-200" id="bar3"></div>
                        <div class="h-1 flex-1 rounded bg-gray-200" id="bar4"></div>
                    </div>
                    <p class="text-xs text-gray-400 mt-1" id="strengthText"></p>
                </div>

                
                <div class="mb-6">
                    <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-1">
                        Confirmer le mot de passe <span class="text-red-500">*</span>
                    </label>
                    <div class="relative">
                        <input
                            type="password"
                            id="password_confirmation"
                            name="password_confirmation"
                            required
                            placeholder="Répétez le mot de passe"
                            class="w-full px-4 py-3 border border-gray-300 rounded-xl text-gray-800
                                   focus:outline-none focus:ring-2 focus:ring-novax-500 focus:border-transparent
                                   transition-all duration-200 pr-12"
                        />
                        <button type="button" onclick="togglePassword('password_confirmation')"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                      d="M15 12a3 3 0 11-6 0 3 3 0 016 0zM2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                            </svg>
                        </button>
                    </div>
                </div>

                
                <button
                    type="submit"
                    id="submitBtn"
                    class="w-full py-3 px-4 bg-novax-700 hover:bg-novax-800 text-white font-semibold
                           rounded-xl transition-all duration-200 flex items-center justify-center gap-2
                           focus:outline-none focus:ring-2 focus:ring-novax-500 focus:ring-offset-2"
                >
                    <span id="btnText">Créer mon compte</span>
                    <svg id="btnSpinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                    </svg>
                </button>
            </form>

            <p class="text-center text-sm text-gray-500 mt-6">
                Déjà un compte ?
                <a href="<?php echo e(route('login')); ?>" class="text-novax-700 font-semibold hover:underline">
                    Se connecter
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
    function togglePassword(fieldId) {
        const field = document.getElementById(fieldId);
        field.type = field.type === 'password' ? 'text' : 'password';
    }

    // Indicateur de force du mot de passe
    document.getElementById('password').addEventListener('input', function () {
        const val    = this.value;
        const bars   = [document.getElementById('bar1'), document.getElementById('bar2'),
                        document.getElementById('bar3'), document.getElementById('bar4')];
        const text   = document.getElementById('strengthText');
        let strength = 0;

        if (val.length >= 8)                          strength++;
        if (/[A-Z]/.test(val))                        strength++;
        if (/[0-9]/.test(val))                        strength++;
        if (/[^A-Za-z0-9]/.test(val))                 strength++;

        const colors  = ['bg-red-400', 'bg-orange-400', 'bg-yellow-400', 'bg-green-500'];
        const labels  = ['Très faible', 'Faible', 'Moyen', 'Fort'];

        bars.forEach((bar, i) => {
            bar.className = 'h-1 flex-1 rounded ' + (i < strength ? colors[strength - 1] : 'bg-gray-200');
        });
        text.textContent = strength > 0 ? labels[strength - 1] : '';
        text.className   = 'text-xs mt-1 ' + (strength >= 3 ? 'text-green-600' : 'text-orange-500');
    });

    document.getElementById('registerForm').addEventListener('submit', function () {
        document.getElementById('submitBtn').disabled = true;
        document.getElementById('btnText').textContent = 'Création...';
        document.getElementById('btnSpinner').classList.remove('hidden');
    });
</script>
<?php $__env->stopPush(); ?>

<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH P:\forge_imen_2026\clone_whatsapp_base_code\novax_backend\resources\views/auth/register.blade.php ENDPATH**/ ?>