<?php

/*
|--------------------------------------------------------------------------
| CORS Configuration — NovaX
|--------------------------------------------------------------------------
|
| Autorise Flutter (mobile/web) à appeler l'API Laravel depuis un domaine
| différent (cross-origin). Sans cette config, le navigateur bloque les
| requêtes venant de Flutter Web ou d'un autre port.
|
| En développement : on autorise tout (*)
| En production    : remplacer '*' par le domaine exact de l'app Flutter
|
*/

return [

    /*
     * Chemins concernés par CORS.
     * 'api/*' couvre toutes les routes /api/...
     */
    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    /*
     * Méthodes HTTP autorisées.
     * Flutter utilise GET, POST, PUT, DELETE.
     */
    'allowed_methods' => ['*'],

    /*
     * Origines autorisées.
     * En dev : '*' (tout autoriser)
     * En prod : ['https://votre-app-flutter.com']
     */
    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    /*
     * Headers autorisés dans les requêtes.
     * 'Authorization' est nécessaire pour le token Bearer.
     * 'Content-Type' est nécessaire pour les requêtes JSON.
     */
    'allowed_headers' => ['*'],

    /*
     * Headers exposés dans les réponses.
     */
    'exposed_headers' => [],

    /*
     * Durée de mise en cache des résultats preflight (en secondes).
     * 0 = pas de cache (utile en développement)
     */
    'max_age' => 0,

    /*
     * Autorise l'envoi des cookies dans les requêtes cross-origin.
     * false pour les APIs stateless (JWT/Sanctum tokens)
     */
    'supports_credentials' => false,

];
